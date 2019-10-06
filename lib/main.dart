import 'package:flutter/material.dart';

import './pages/aboutPage.dart';
import './pages/homePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  void refreshApp(){
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light
      ),
      title: "Status Forever",

      routes: {
        '/aboutPage': (BuildContext context) => AboutPage()
      },

      home: HomePage(refreshApp),
    );
  }
}