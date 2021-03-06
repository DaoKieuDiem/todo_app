class BottomNavigationBarTitle {
  static const String allTasks = 'All';
  static const String completedTask = 'Done';
  static const String uncompletedTask = 'Undone';
}

class AlertContentString {
  static const String alertTitle = 'Are you sure?';
  static const String alertContent = 'Do you really want to exit?';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String deleteListTitle = 'Delete this list?';
  static const String deleteListContent = 'Delete this list will also delete';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String deleteTasksContent =
      'Do you really want to delete all complete tasks';
}

class HiveBoxName {
  static const String tasks = 'alltasks';
  static const String taskList = 'tasklist';
}

class ImageAssetUrl {
  static const String avatarImage = 'assets/images/avatar.PNG';
  static const String appIconImage = 'assets/images/icon.png';
  static const String backgroundImage = 'assets/images/background3.jpg';
}

const String defaultList = 'Default';
enum TypeRepeat { day, week, month, year }
enum DayRepeat {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday
}
enum OrdinalNumbers { first, second, third, fourth, last }
