import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AboutPageState();
  }
}

class _AboutPageState extends State<AboutPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static const platform = const MethodChannel("com.a011.statusforever");

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFEFEFEF),
            iconTheme: IconThemeData(color: Colors.black),
            title: Text(
              "About",
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Container(
            color: Color(0xFFEFEFEF),
            child: Center(
              child: ListView(
                padding: EdgeInsets.only(top: 40.0, left: 40, right: 40),
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Status Forever',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.35, top: 5.0),
                    child: Container(
                      height: 5,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Text('Version',
                        style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                  ),
                  Container(
                    child: Text('1.0',
                        style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Text('Last Update',
                        style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                  ),
                  Container(
                    child: Text('July 2019',
                        style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Text('Developer',
                        style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                  ),
                  Container(
                    child: Text('Rohit Raj, 011',
                        style: TextStyle(color: Colors.black, fontSize: 20.0)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Developed using',
                            style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                        SizedBox(
                          width: 150,
                          child: FlutterLogo(
                            colors: Colors.green,
                            size: 100.0,
                            style: FlutterLogoStyle.horizontal,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top:5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Icon(FontAwesomeIcons.github,color: Colors.grey,size: 40.0,),
                          color: Colors.transparent,
                          onPressed: (){
                            platform.invokeMethod("openGitHub");
                          },
                        ),
                        FlatButton(
                          child: Icon(FontAwesomeIcons.linkedinIn,color: Colors.grey,size: 40.0,),
                          color: Colors.transparent,
                          onPressed: (){
                            platform.invokeMethod("openLinkedIn");
                          },
                        ),
                        FlatButton(
                          child: Icon(FontAwesomeIcons.facebook,color: Colors.grey,size: 40.0,),
                          color: Colors.transparent,
                          onPressed: (){
                            platform.invokeMethod("openFacebook");
                          },
                        )
                      ],
                    ),
                  ),
                  // Container(
                  //   child: Text('https://github.com/RohitRajP',
                  //       style: TextStyle(color: Colors.black, fontSize: 25.0)),
                  // ),
                  // Container(
                  //   child: Text('',
                  //       style: TextStyle(color: Colors.black, fontSize: 25.0)),
                  // )
                ],
              ),
            ),
          ),
        ));
  }
}