import 'package:flutter/material.dart';
import 'package:plant_explore/core/providers/auth_provider.dart';
import 'package:plant_explore/core/providers/home_provider.dart';
import 'package:plant_explore/core/providers/option_provider.dart';
import 'package:plant_explore/core/providers/question_provider.dart';
import 'package:plant_explore/core/providers/user_provider.dart';
import 'package:plant_explore/core/providers/quiz_provider.dart'; // Import UserProvider
import 'package:plant_explore/screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'core/providers/plant_provider.dart';
import 'screen/home_screen.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) => HomeProvider(
                  Provider.of<AuthProvider>(context,
                      listen: false), // Pass AuthProvider
                )),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
            create: (context) => QuizProvider(
                  Provider.of<AuthProvider>(context, listen: false),
                )),
        ChangeNotifierProvider(
            create: (context) => QuestionProvider(
                  Provider.of<AuthProvider>(context, listen: false),
                )),
        ChangeNotifierProvider(create: (context) => OptionProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Explore',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),
    );
  }
}
