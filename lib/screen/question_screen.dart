import 'package:flutter/material.dart';
import 'package:plant_explore/core/providers/question_provider.dart';
import 'package:plant_explore/core/providers/option_provider.dart';
import 'package:provider/provider.dart';
import 'result_screen.dart';

class QuestionScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuestionScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      await Provider.of<QuestionProvider>(context, listen: false)
          .fetchQuestions(widget.quizId);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _answerQuestion(int selectedIndex) {
    final questionProvider =
        Provider.of<QuestionProvider>(context, listen: false);
    if (_currentQuestionIndex >= questionProvider.questions.length) return;

    final question = questionProvider.questions[_currentQuestionIndex];
    final selectedOption = question.options[selectedIndex];

    if (selectedOption.isCorrect) {
      _score += question.point;
    }

    if (_currentQuestionIndex < questionProvider.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            total: questionProvider.questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final optionProvider = Provider.of<OptionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError || questionProvider.questions.isEmpty
              ? const Center(
                  child: Text(
                    "No questions available.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        questionProvider.questions[_currentQuestionIndex].name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        questionProvider
                            .questions[_currentQuestionIndex].options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                            onPressed: () => _answerQuestion(index),
                            child: Text(
                              questionProvider.questions[_currentQuestionIndex]
                                  .options[index].context,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
