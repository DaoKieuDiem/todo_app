class ValidationUtils {
  static bool validHour(int hour) {
    return hour >= 0 && hour <= 24;
  }

  static bool validMinute(int minute) {
    return 0 <= minute && minute <= 60;
  }
}
