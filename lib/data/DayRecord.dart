import 'package:steps_tracker/utils/formatDate.dart';

class DayRecord {
  // Do not expect number of DayRecors to exceed several thousands.
  // And most of the writes will be in the beginning.
  String day = '';
  Map<String, double> bootsMap = {};

  DayRecord(DateTime day) {
    this.day = formaDate(day);
  }

  DayRecord.fromJson(this.day, this.bootsMap);

  double getDistance(String bootsId) {
    var r = bootsMap[bootsId];
    if (r == null) {
      return 0.0;
    }
    return r;
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'bootsMap': bootsMap,
    };
  }
}
