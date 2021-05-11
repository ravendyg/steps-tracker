// import 'package:steps_tracker/utils/formatDate.dart';

import 'package:steps_tracker/utils/dateUtils.dart';

class DayRecord {
  // Do not expect number of DayRecors to exceed several thousands.
  // And most of the writes will be in the beginning.
  DateTime day = DateTime.now();
  Map<String, double> bootsMap = {};

  DayRecord(DateTime day) {
    this.day = DateTime.parse(formatDateForStorage(day));
  }

  DayRecord.fromJson(day, this.bootsMap) {
    this.day = DateTime.parse(day);
  }

  String displayDate() {
    return formatDateWithWeekDay(day);
  }

  double getDistance(String bootsId) {
    var r = bootsMap[bootsId];
    if (r == null) {
      return 0.0;
    }
    return r;
  }

  Map<String, dynamic> toJson() {
    return {
      'day': formatDateForStorage(day),
      'bootsMap': bootsMap,
    };
  }
}
