String formatDateForStorage(DateTime date) {
  return date.toIso8601String().substring(0, 10);
}

const WEEKDAY_NAMES = {
  1: 'пн',
  2: 'вт',
  3: 'ср',
  4: 'чт',
  5: 'пт',
  6: 'сб',
  7: 'вс'
};

String formatDateWithWeekDay(DateTime date) {
  var res =
      '${formatNum(date.day)}-${formatNum(date.month)} (${WEEKDAY_NAMES[date.weekday]})';
  // if (date.day == 1) {
  //   res += ' ' + '${date.year}'.substring(2);
  // }
  return res;
}

String formatNum(int numb) {
  if (numb >= 10) {
    return '$numb';
  }
  return '0$numb';
}
