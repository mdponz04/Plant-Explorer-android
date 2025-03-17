import 'package:flutter/material.dart';
import 'result_screen.dart';

class QuestionScreen extends StatefulWidget {
  final String quizTitle;

  QuestionScreen({required this.quizTitle});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0; // Điểm số của người dùng

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Flutter là gì?",
      "options": [
        "Framework",
        "Ngôn ngữ lập trình",
        "Database",
        "Hệ điều hành"
      ],
      "correctIndex": 0,
    },
    {
      "question": "Widget trong Flutter là gì?",
      "options": ["Component UI", "Cơ sở dữ liệu", "API", "Ngôn ngữ"],
      "correctIndex": 0,
    },
    {
      "question": "StatelessWidget khác StatefulWidget thế nào?",
      "options": [
        "Stateless không thay đổi",
        "Stateful không thể thay đổi",
        "Không có sự khác biệt",
        "Stateful nhanh hơn"
      ],
      "correctIndex": 0,
    },
  ];

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == questions[_currentQuestionIndex]["correctIndex"]) {
      _score++; // Cộng điểm nếu đúng
    }

    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Khi hoàn thành, chuyển sang màn hình kết quả
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(score: _score, total: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questions[_currentQuestionIndex]["question"],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...List.generate(4, (index) {
              return ElevatedButton(
                onPressed: () => _answerQuestion(index),
                child: Text(questions[_currentQuestionIndex]["options"][index]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
