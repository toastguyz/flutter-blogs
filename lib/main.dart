import 'package:flutter/material.dart';
import 'package:flutter_blogs/screens/blog_home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: 'Flutter Blogs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlogHomeScreen(),
    );
  }
}
