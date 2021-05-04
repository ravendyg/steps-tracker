import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:steps_tracker/data/BootsPair.dart';
import 'package:steps_tracker/data/DayRecord.dart';
import 'package:collection/collection.dart';
import 'package:steps_tracker/utils/fileUtils.dart';

class BootsState extends ChangeNotifier {
  final String _storageFile = 'state.json';
  final List<BootsPair> pairs = [];
  final List<DayRecord> days = [];
  bool loading = true;
  double totalDistance = 0.0;

  BootsState() {
    readFromFile(_storageFile).then((value) {
      var js = json.decode(value);
      for (var i = 0; i < js['pairs'].length; i++) {
        var e = js['pairs'][i];
        var p = BootsPair(e['id'], e['name']);
        p.total = e['total'];
        pairs.add(p);
      }
      for (var i = 0; i < js['days'].length; i++) {
        var e = js['days'][i];
        var bm = Map<String, double>.from(e['bootsMap']);
        var d = DayRecord.fromJson(e['day'], bm);
        days.add(d);
        var first = DayRecord(DateTime.now());
        // Make sure that the current day is always present.
        if (days.length == 0 || days[0].day != first.day) {
          days.insert(0, first);
        }
      }
      totalDistance = js['totalDistance'];
      loading = false;
      notifyListeners();
    });
  }

  void addPair(BootsPair pair) {
    pairs.add(pair);
    _performUpdate();
  }

  void updateDistance(DateTime date, String bootsId, String distance) {
    var pair = pairs.firstWhereOrNull((e) => e.id == bootsId);
    if (pair == null) {
      return;
    }
    double _distance = 0.0;

    var i = 0;
    try {
      _distance = double.parse(distance);
    } catch (e) {}
    var nextRecordDate = DateTime.parse(days[i].day);
    DayRecord? dayRecord;
    for (; i < days.length; i++) {
      var recordDate = nextRecordDate;
      if (recordDate == date) {
        dayRecord = days[i];
        break;
      }
      // The list ended, days is not found.
      if (i + 1 >= days.length) break;
      nextRecordDate = DateTime.parse(days[i + 1].day);
      // A new day between two existing.
      if (recordDate.compareTo(date) == 1 &&
          nextRecordDate.compareTo(date) == -1) {
        break;
      }
    }
    if (dayRecord == null) {
      dayRecord = DayRecord(date);
      dayRecord.bootsMap[bootsId] = _distance;
      days.insert(i + 1, dayRecord);
    } else {
      // if replacing subtract previous distance
      var oldDistance = dayRecord.bootsMap[bootsId];
      if (oldDistance != null) {
        pair.total -= oldDistance;
        totalDistance -= oldDistance;
      }
      dayRecord.bootsMap[bootsId] = _distance;
    }
    pair.total += _distance;
    totalDistance += _distance;

    _performUpdate();
  }

  DayRecord? getDayRecord(String day) {
    return days.firstWhereOrNull((e) => e.day == day);
  }

  double getDayBootsDistance(String day, String bootsId) {
    var record = getDayRecord(day);
    if (record == null) return 0.0;
    var p = record.bootsMap[bootsId];
    return p == null ? 0.0 : p;
  }

  void _performUpdate() {
    notifyListeners();
    writeToFile(json.encode(this), 'state.json');
  }

  Map<String, dynamic> toJson() {
    return {
      'pairs': [...pairs.map((e) => e.toJson())],
      'days': [...days.map((e) => e.toJson())],
      'totalDistance': totalDistance,
    };
  }
}
