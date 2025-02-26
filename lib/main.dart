import 'package:flutter/material.dart';
import 'package:perceptron/core/configs/theme/app_theme.dart';
import 'package:perceptron/firebase_options.dart';
import 'package:perceptron/presentation/home/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rosenblatt\'s perceptron',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
