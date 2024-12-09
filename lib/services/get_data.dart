
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class DatabaseAccess {
  static const String _newDBName = "data.db"; // The new database name
  static const String _oldDBName =
      "old_data.db"; // The old database name (if applicable)

  Future<Database> openDatabaseConnection() async {
    var path = join(await getDatabasesPath(), _newDBName);
    var exists = await databaseExists(path);

    // If the database does not exist, copy it from assets
    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Load the database from assets
      ByteData data = await rootBundle.load(join("assets", _newDBName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);

      var oldPath = join(await getDatabasesPath(), _oldDBName);
      exists = await databaseExists(oldPath);
      if (exists) {
        await deleteDatabase(oldPath); // Ensure async deletion
      }
    }

    // Open the database
    Database db = await openDatabase(path);
    return db;
  }

  Future<String> searchWords(String query, bool isEnglish) async {
    Database db = await openDatabaseConnection();
    String column = isEnglish ? 'en' : 'ar';
    String sql =
        "SELECT * FROM words_list WHERE $column LIKE '$query' LIMIT 50";
    List<Map<String, dynamic>> translationList = await db.rawQuery(sql);
    String translations = translationList.map((trans) {
      // Assuming 'en' is the English translation and 'ar' is the Arabic translation
      return '${trans['en']} - ${trans['ar']}'; // Customize the format as needed
    }).join('\n');
    return translations;
  }
}
