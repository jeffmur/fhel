import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page/home.dart';
import 'page/settings.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
        create: (context) => SessionChanges(), 
        child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
