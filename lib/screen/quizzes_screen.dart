import 'package:flutter/material.dart';
import 'package:plant_explore/core/providers/quiz_provider.dart';
import 'package:plant_explore/screen/question_screen.dart';
import 'package:provider/provider.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  _QuizzesScreenState createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quizzes")),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quizProvider.quizzes.isEmpty) {
            return const Center(child: Text("No quizzes available"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizProvider.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizProvider.quizzes[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundImage: (quiz.imageUrl?.isNotEmpty ?? false)
                        ? NetworkImage(quiz.imageUrl!)
                        : null,
                    child: (quiz.imageUrl?.isEmpty ?? true)
                        ? const Icon(Icons.quiz)
                        : null,
                  ),
                  title: Text(
                    quiz.name ?? "Unnamed Quiz",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Tap to start quiz"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionScreen(
                          quizId: quiz.id,
                          quizTitle: quiz.name ?? "Quiz",
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
