String formaDate(DateTime date) {
  return date.toIso8601String().substring(0, 10);
}
