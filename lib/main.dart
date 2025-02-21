import 'package:flutter/material.dart';
import 'package:perceptron/core/configs/theme/app_theme.dart';
import 'package:perceptron/presentation/home/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
