import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(TriviaApp());
}

class TriviaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List categories = [];
  String? selectedCategory;
  String selectedDifficulty = 'easy';
  int questionAmount = 10;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.111:8000/api/categories/?format=json'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
        print('Categories fetched: $categories');
      } else {
        print(
            'Failed to load categories with status code: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  void startQuiz() {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (questionAmount < 1 || questionAmount > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please enter a number of questions between 1 and 50')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QuizPage(
                category: selectedCategory!,
                difficulty: selectedDifficulty,
                amount: questionAmount,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trivia App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              hint: Text('Select Category'),
              items: categories.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value as String?;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              hint: Text('Select Difficulty'),
              items: ['easy', 'medium', 'hard'].map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value as String;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Number of Questions'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  questionAmount = int.parse(value);
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startQuiz,
              child: Text('Go!'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String category;
  final String difficulty;
  final int amount;

  QuizPage(
      {required this.category, required this.difficulty, required this.amount});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List questions = [];
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.111:8000/api/questions/?amount=${widget.amount}&category=${widget.category}&difficulty=${widget.difficulty}'));
    if (response.statusCode == 200) {
      setState(() {
        questions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void answerQuestion(String selectedAnswer) {
    if (selectedAnswer == questions[currentQuestionIndex]['correct_answer']) {
      correctAnswers++;
    } else {
      incorrectAnswers++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            totalQuestions: questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];
    final options = List<String>.from(question['incorrect_answers']);
    options.add(question['correct_answer']);
    options.shuffle();

    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            Text(
              question['question'],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ...options.map((option) => ElevatedButton(
                  onPressed: () => answerQuestion(option),
                  child: Text(option),
                )),
          ],
        ),
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;

  QuizResultPage(
      {required this.correctAnswers,
      required this.incorrectAnswers,
      required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total Questions: $totalQuestions',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Correct Answers: $correctAnswers',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              'Incorrect Answers: $incorrectAnswers',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
