import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._getInstance();
  static Database? _database;
  List<String> words = [];

  DatabaseHelper._getInstance();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'word_game.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          '''
        CREATE TABLE words(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT
        )
        ''');
    });
  }

  Future<int> insertWord(String word) async {
    final db = await instance.database;
    return await db.insert('words', {'word': word});
  }

  Future<List<String>> getWords() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (index) => maps[index]['word']);
  }

  Future<void> fetchWordList() async {
    final response = await http
        .get(Uri.parse('https://www.mit.edu/~ecprice/wordlist.10000'));
    if (response.statusCode == 200) {
      words = response.body.split('\n');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
