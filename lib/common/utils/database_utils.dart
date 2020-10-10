import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseUtils {
  static Future<void> initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
  }

  /// To remove all local storage content.
  static Future<void> clearDatabase() async {
    await Hive.deleteFromDisk();
  }
}
