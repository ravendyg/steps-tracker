import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:steps_tracker/data/BootsPair.dart';
import 'package:steps_tracker/data/DayRecord.dart';
import 'package:collection/collection.dart';
import 'package:steps_tracker/utils/fileUtils.dart';

const STEPS_IN_KM = 1200;

class BootsState extends ChangeNotifier {
  final String _storageFile = 'state.json';
  final List<BootsPair> pairs = [];
  final List<DayRecord> days = [];
  bool loading = true;
  double totalDistance = 0.0;

  BootsState() {
    readFromFile(_storageFile).then((value) {
      if (value != null) {
        var js = json.decode(value);
        for (var i = 0; i < js['pairs'].length; i++) {
          var e = js['pairs'][i];
          var p = BootsPair(e['id'], e['name']);
          p.total = e['total'];
          pairs.add(p);
        }
        for (var i = 0; i < js['days'].length; i++) {
          var dayRecordJson = js['days'][i];
          var bootsMapJson =
              Map<String, double>.from(dayRecordJson['bootsMap']);
          var dayRecord =
              DayRecord.fromJson(dayRecordJson['day'], bootsMapJson);
          days.add(dayRecord);
        }
        totalDistance = js['totalDistance'];
      }
      var first = DayRecord(DateTime.now());
      // Make sure that the current day is always present.
      if (days.length == 0 || days[0].day != first.day) {
        days.insert(0, first);
      }
      loading = false;
      notifyListeners();
    });
  }

  void addPair(BootsPair pair) {
    pairs.insert(0, pair);
    _performUpdate();
  }

  void updateDistance(
      int dayId, DateTime date, String bootsId, String distance) {
    var updatedPair = pairs.firstWhereOrNull((e) => e.id == bootsId);
    if (updatedPair == null) {
      return;
    }

    double _distance = 0.0;
    try {
      _distance = double.parse(distance);
      if (_distance > 100) {
        _distance = (_distance / STEPS_IN_KM * 100).round() / 100;
      }
    } catch (e) {
      return;
    }

    if (dayId >= 0) {
      var updatedDay = days[dayId];
      // remove the old value
      var oldDistance = updatedDay.bootsMap[bootsId];
      if (oldDistance != null) {
        updatedPair.total -= oldDistance;
        totalDistance -= oldDistance;
      }
      updatedDay.bootsMap[bootsId] = 0.0;

      // date has not been changed, just set the new value
      if (updatedDay.day == date) {
        updatedDay.bootsMap[bootsId] = _distance;
        updatedPair.total += _distance;
        totalDistance += _distance;
        _performUpdate();
        return;
      }
      // if the date has been change
      // can now proceed to inserting as if it was a new one
    }

    var dayIndex = 0;
    var nextRecordDate = days[dayIndex].day;
    DayRecord? dayRecord;
    for (; dayIndex < days.length; dayIndex++) {
      var recordDate = nextRecordDate;
      if (recordDate == date) {
        dayRecord = days[dayIndex];
        break;
      }
      // The list ended, days is not found.
      if (dayIndex + 1 >= days.length) break;
      nextRecordDate = days[dayIndex + 1].day;
      // A new day between two existing.
      if (recordDate.compareTo(date) == 1 &&
          nextRecordDate.compareTo(date) == -1) {
        break;
      }
    }
    if (dayRecord == null) {
      dayRecord = DayRecord(date);
      dayRecord.bootsMap[bootsId] = _distance;
      days.insert(dayIndex + 1, dayRecord);
    } else {
      // @todo: maybe need different pages for adding and editing
      // also somehow notify the users on the editor page that he is going
      // to overwrite an existing value
      // if replacing subtract previous distance
      var oldDistance = dayRecord.bootsMap[bootsId];
      if (oldDistance != null) {
        updatedPair.total -= oldDistance;
        totalDistance -= oldDistance;
      }
      dayRecord.bootsMap[bootsId] = _distance;
    }
    updatedPair.total += _distance;
    totalDistance += _distance;

    // put the updated pair in the front
    if (pairs[0] != updatedPair) {
      pairs.remove(updatedPair);
      pairs.insert(0, updatedPair);
    }

    _performUpdate();
  }

  DayRecord? getDayRecord(DateTime day) {
    return days.firstWhereOrNull((e) => e.day == day);
  }

  double getDayBootsDistance(DateTime day, String bootsId) {
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
