import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:news_app/pages/list_news.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  await Hive.openBox('favorites_news');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ListNews(),
    );
  }
}

