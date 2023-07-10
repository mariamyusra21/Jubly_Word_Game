import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'database.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> usedWords = [];
  TextEditingController wordController = TextEditingController();
  bool isPlayer1Turn = true;
  int player1Score = 0;
  int player2Score = 0;

  List<String> words = [];

  @override
  void initState() {
    super.initState();
    _fetchWordList();
    _loadUsedWords();
  }

  Future<void> _fetchWordList() async {
    final response = await http
        .get(Uri.parse('https://www.mit.edu/~ecprice/wordlist.10000'));
    if (response.statusCode == 200) {
      setState(() {
        words = LineSplitter().convert(response.body);
      });
    }
  }

  Future<void> _loadUsedWords() async {
    List<String> loadedWords = await DatabaseHelper.instance.getWords();
    setState(() {
      usedWords = loadedWords;
    });
  }

  Future<void> _addWord() async {
    String word = wordController.text.trim();
    if (word.isNotEmpty && !usedWords.contains(word)) {
      if (usedWords.isEmpty ||
          word.startsWith(usedWords.last
              .substring(usedWords.last.length - 1)
              .toLowerCase())) {
        setState(() {
          if (isPlayer1Turn) {
            player1Score += word.length;
          } else {
            player2Score += word.length;
          }
          usedWords.add(word);
          isPlayer1Turn = !isPlayer1Turn;
          wordController.clear();
          DatabaseHelper.instance.insertWord(word);
        });
      } else {
        _showSnackBar('Invalid word! Start with the correct letter.');
      }
    } else {
      _showSnackBar('Word already used!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 103, 48, 28),
        centerTitle: true,
        title: Text("Jubly Spell Game"),
        titleTextStyle: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text('Words Already Used',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 103, 48, 28))),
          Expanded(
            child: ListView.builder(
              itemCount: usedWords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    usedWords[index],
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              enableSuggestions: true,
              style: TextStyle(
                  fontSize: 22, color: Color.fromARGB(255, 103, 48, 28)),
              controller: wordController,
              cursorColor: Color.fromARGB(255, 103, 48, 28),
              decoration: InputDecoration(
                labelStyle: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 103, 48, 28)),
                labelText: 'Enter a word ',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addWord,
            child: Text(
              'Add Word',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 103, 48, 28)),
          ),
          SizedBox(height: 10),
          Text(
            'Player 1 Score: $player1Score',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 103, 48, 28)),
          ),
          SizedBox(height: 10),
          Text(
            'Player 2 Score: $player2Score',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 103, 48, 28)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    wordController.dispose();
    DatabaseHelper.instance.close();
    super.dispose();
  }
}
