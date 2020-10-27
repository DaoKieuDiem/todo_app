import 'package:todo_app/common/common_constant.dart';

class AppUtils {
  static String parserTypeRepeat(TypeRepeat code, int times) {
    switch (code) {
      case TypeRepeat.day:
        return (times > 1) ? 'days' : 'day';
      case TypeRepeat.month:
        return (times > 1) ? 'months' : 'month';
      case TypeRepeat.week:
        return (times > 1) ? 'weeks' : 'week';
      case TypeRepeat.year:
        return (times > 1) ? 'years' : 'year';
      default:
        return (times > 1) ? 'weeks' : 'week';
    }
  }

  static TypeRepeat parseToTypeRepeat(String value) {
    switch (value) {
      case 'day':
      case 'days':
        return TypeRepeat.day;
      case 'week':
      case 'weeks':
        return TypeRepeat.day;
      case 'month':
      case 'months':
        return TypeRepeat.day;
      case 'year':
      case 'years':
        return TypeRepeat.day;
      default:
        return TypeRepeat.week;
    }
  }

  static String parserDayRepeat(DayRepeat code) {
    switch (code) {
      case DayRepeat.sunday:
        return 'sunday';
      case DayRepeat.monday:
        return 'monday';
      case DayRepeat.tuesday:
        return 'tuesday';
      case DayRepeat.wednesday:
        return 'wednesday';
      case DayRepeat.thursday:
        return 'thursday';
      case DayRepeat.friday:
        return 'friday';
      case DayRepeat.saturday:
        return 'saturday';
      default:
        return 'monday';
    }
  }

  static DayRepeat parseToDayRepeat(String value) {
    switch (value) {
      case 'monday':
      case 'Mon':
        return DayRepeat.monday;
      case 'tuesday':
      case 'Tue':
        return DayRepeat.tuesday;
      case 'wednesday':
      case 'Wed':
        return DayRepeat.wednesday;
      case 'thursday':
      case 'Thu':
        return DayRepeat.thursday;
      case 'friday':
      case 'Fri':
        return DayRepeat.friday;
      case 'Sat':
      case 'saturday':
        return DayRepeat.saturday;
      case 'Sun':
      case 'sunday':
        return DayRepeat.sunday;
      default:
        return DayRepeat.monday;
    }
  }

  static String standForDayRepeat(DayRepeat day) {
    switch (day) {
      case DayRepeat.sunday:
      case DayRepeat.saturday:
        return 'S';
      case DayRepeat.monday:
        return 'M';
      case DayRepeat.thursday:
      case DayRepeat.tuesday:
        return 'T';
      case DayRepeat.wednesday:
        return 'W';
      case DayRepeat.friday:
        return 'F';
      default:
        return 'M';
    }
  }

  static String abbreviatedDayRepeat(DayRepeat day) {
    switch (day) {
      case DayRepeat.sunday:
        return 'Sun';
      case DayRepeat.saturday:
        return 'Sat';
      case DayRepeat.monday:
        return 'Mon';
      case DayRepeat.thursday:
        return 'Thu';
      case DayRepeat.tuesday:
        return 'Tue';
      case DayRepeat.wednesday:
        return 'Wed';
      case DayRepeat.friday:
        return 'Fri';
      default:
        return 'Mon';
    }
  }

  static String parserOrdinalNumbers(OrdinalNumbers numbers) {
    switch (numbers) {
      case OrdinalNumbers.first:
        return 'First';
      case OrdinalNumbers.second:
        return 'Second';
      case OrdinalNumbers.third:
        return 'Third';
      case OrdinalNumbers.fourth:
        return 'Fourth';
      case OrdinalNumbers.last:
        return 'Last';
      default:
        return 'First';
    }
  }

  static OrdinalNumbers parseToOrdinalNumbers(String numbers) {
    switch (numbers) {
      case 'First':
        return OrdinalNumbers.first;
      case 'Second':
        return OrdinalNumbers.second;
      case 'Third':
        return OrdinalNumbers.third;
      case 'Fourth':
        return OrdinalNumbers.fourth;
      default:
        return OrdinalNumbers.last;
    }
  }
}
