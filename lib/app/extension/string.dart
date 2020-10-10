extension CapExtension on String {
  //first letter only
  String get inCaps => '${this[0].toUpperCase()}${substring(1)}';
  //all letter in string
  String get allInCaps => toUpperCase();
  //first letter for each word in a string
  String get titleCase => split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}