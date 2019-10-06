import 'dart:io';
import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

final Shader linearGradient = LinearGradient(
  colors: <Color>[Color(0xff96c93d),Color(0xff00b09b)],
).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

var name_textStyle = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
  foreground: Paint()..shader = linearGradient,
);

var message_textStyle =
    TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

var permission_textStyle = TextStyle(
    fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.deepOrange);

Widget appBarW(appBarMessage,context,fetchStatuses) {
  return AppBar(
    backgroundColor: Color(0xFFEFEFEF),
    actions: <Widget>[
        PopupMenuButton<String>(
          padding: EdgeInsets.only(right: 25.0),
          elevation: 30.0,
          icon: Icon(FontAwesomeIcons.cogs,color: Colors.black,),
          onSelected: (choice){
            if(choice.compareTo("refresh")==0){
              fetchStatuses();
            }
            else if(choice.compareTo("info")==0){
              Navigator.pushNamed(context, '/aboutPage');
            }
          },
          itemBuilder: (context)=>[
            PopupMenuItem(
              value: "refresh",
              child: ListTile(
                title: Text("Refresh"),
                leading: Icon(FontAwesomeIcons.sync),
              )
            ),
            PopupMenuItem(
              value: "info",
              child: ListTile(
                title: Text("About"),
                leading: Icon(FontAwesomeIcons.infoCircle),
              )
            )
          ],
        )
    ],
    title: Text(
      appBarMessage,
      style: TextStyle(
        foreground: Paint()..shader = linearGradient,
        fontWeight: FontWeight.bold,
        fontSize: 25.0,
      ),
    ),
    elevation: 0,
    centerTitle: true,

  );
}

Widget permissionMessage(context) {
  return Container(
    margin: EdgeInsets.only(left: 30.0, right: 30.0),
    alignment: Alignment.center,
    child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            // set the default style for the children TextSpans
            style: Theme.of(context).textTheme.headline,
            children: [
              TextSpan(text: 'Status Forever ', style: name_textStyle),
              TextSpan(text: 'requires ', style: message_textStyle),
              TextSpan(
                  text: '\nstorage permission ', style: permission_textStyle),
              TextSpan(
                  text: 'to save and serve statuses and ', style: message_textStyle),
              TextSpan(
                  text: 'contacts permission ', style: permission_textStyle),
              TextSpan(
                  text: 'to help you categorize them ', style: message_textStyle),
            ])),
  );
}

Widget videoView(index, _fileList, showOptions) {
  return GestureDetector(
    onTap: (){
      // 1 - video
      showOptions(index,1);
    },
    child: Stack(
      children: <Widget>[
        Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                File("/storage/emulated/0/StatusForever/" +
                    _fileList[index].toString().substring(0, 32) +
                    ".jpg"),fit: BoxFit.cover
              )),
            )
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              FontAwesomeIcons.video,
              size: 20.0,
              color: Colors.white,
            ),
          ),
        )
      ],
    ),
  );
}

Widget imageView(index, _fileList,showOptions){
  return GestureDetector(
    onTap: (){
      // 0 - Image
      showOptions(index,0);
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.file(
        File("/storage/emulated/0/WhatsApp/Media/.Statuses/" +
            _fileList[index]),fit: BoxFit.cover,
      ),
    ),
  );
}

// CircularLoader with custom message functionality
Widget loadingView(message,context) {
  return Container(
    height: MediaQuery.of(context).size.height,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(message)
        ],
      ),
    ),
  );
}