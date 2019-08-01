import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/homePageW.dart';
import '../widgets/typeAheadWidget.dart';

class HomePage extends StatefulWidget {
  Function refreshApp;
  HomePage(this.refreshApp);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  // declaring variable to hold platform channel name
  static const platform = const MethodChannel("com.a011.statusforever");
  bool _permissionStatus = true, _isLoading = false,_fabShow = false,_noContent = false;
  var scaffoldKey = new GlobalKey<ScaffoldState>();
  String appBarMessage = "Permission Request", contact;
  List _fileList = new List();
  List _contacts = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checks permission Status
    _checkPermission();
  }

  // handles callback from native side after permission action
  Future<dynamic> _handlerMethod(MethodCall call) async {
    switch (call.method) {
      case "permissionGranted":
        // if permission is granted
        if (call.arguments == "true") {
          setState(() {
            _fabShow = true;
            appBarMessage = "Status Forever";
            _isLoading = true;
            _permissionStatus = true;
          });
          _fetchStatuses();
        }
        return new Future.value("");
    }
  }

  void viewImageUnSaved(index) {
    platform.invokeMethod("viewImageUnSaved", {"fileName": _fileList[index]});
  }

  void viewVideoUnSaved(index) {
    platform.invokeMethod("viewVideoUnSaved", {"fileName": _fileList[index]});
  }

  // gets current permission status using method channels
  void _checkPermission() async {
    // gets "Granted" or "Denied"
    String result = await platform.invokeMethod("checkPermission");

    if (result == "Granted") {
      _fetchStatuses();
      // updates app to show content or request button
      setState(() {
        _fabShow = true;
        appBarMessage = "Status Forever";
      });
    }
    setState(() {
      _permissionStatus = (result == "Granted") ? true : false;
    });
  }

  // invokes function to get permission
  void _getPermissions() async {
    String result = await platform.invokeMethod("getPermission");
  }

  // fetches list of statuses in internal storage
  void _fetchStatuses() async {
    // invokes native function to get list of viewed statuses
    List result = await platform.invokeMethod("fetchFileList");

    // check if there are statuses to display
    if (result != null) {
      _fileList = result;
      setState(() {
        // disable loading
        _isLoading = false;
      });
    }
    else{
      setState(() {
        _isLoading = false;
        _noContent = true;
      });
    }
  }

  // sets contact from typeAheadWidget
  void setContact(String value) {
    contact = value;
  }

  void copyFile(contact, fileIndex) async {
    String result = await platform.invokeMethod(
        "copyFile", {"contact": contact, "fileName": _fileList[fileIndex]});
    if (result == "Copied") {
      _snakbarShow(1);
    }
    else if(result == "AlreadyExists"){
      _snakbarShow(2);
    }
    else{
      _snakbarShow(3);
    }
  }

  void _snakbarShow(int mode){
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: (mode == 1)?Text("Success! Status Saved to device"):(mode == 2)?Text("Status already exists in device\nYou can find it in your gallery"):Text("Error! File could not be saved.\n Please contact developer"),
      backgroundColor: (mode == 1)?Colors.green:(mode == 2)?Colors.orange:Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

  Widget buildUI() {
    return Container(
        padding: EdgeInsets.only(top: 0, left: 0.0, right: 0.0),
        child: GridView.count(
            crossAxisCount: 5,
            scrollDirection: Axis.horizontal,
            children: List<Widget>.generate(_fileList.length, (index) {
              return new GridTile(
                child: Card(
                  borderOnForeground: true,
                  elevation: 10.0,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: (_fileList[index].toString().substring(32) == ".mp4")
                      ? videoView(index, _fileList, showOptions)
                      : imageView(index, _fileList, showOptions),
                ),
              );
            })));
  }

  // permission ask button
  Widget _permissionBtn() {
    return Container(
      margin: EdgeInsets.only(top: 5.0, right: 40.0, left: 40.0),
      child: RaisedButton(
        padding: EdgeInsets.all(20.0),
        child: Text("Grant Permission"),
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          _getPermissions();
        },
        color: Colors.indigo,
        textColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }

  Widget showNoContent(){
    return Center(
      child: Text("No Content to show\nWhat happened to people?",style: TextStyle(fontSize: 18.0,),textAlign: TextAlign.center,),
    );
  }

  // collection of elements present in permission asking view
  Widget _permissionAskingView() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          permissionMessage(context),
          SizedBox(
            height: 25.0,
          ),
          _permissionBtn()
        ],
      ),
    );
  }

  void _getContacts() async {
    _contacts = await platform.invokeMethod("getContacts");
  }

  void _getUserName(index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFEFEFEF),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            title: Text("Save As"),
            content: Container(
              padding: EdgeInsets.only(bottom: 200),
              child: TypeAheadWidget(
                  _contacts, widget.refreshApp, setContact, _fileList[index]),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  copyFile(contact, index);
                  Navigator.pop(context);
                },
                textColor: Colors.teal,
                color: Color(0xFFEFEFEF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
                textColor: Colors.red,
                color: Color(0xFFEFEFEF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              )
            ],
          );
        });
  }

  // shows operations to do on file
  // 1 - video, 0 - Image
  void showOptions(index, fileType) {
    _getContacts();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFEFEFEF),
            title: Text("Actions"),
            content: Text("Please specify operation to perform"),
            actions: <Widget>[
              FlatButton(
                child: Text("View"),
                onPressed: () {
                  (fileType == 0)
                      ? viewImageUnSaved(index)
                      : viewVideoUnSaved(index);
                },
                textColor: Colors.indigo,
                color: Color(0xFFEFEFEF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
              FlatButton(
                child: Text("Save to device"),
                onPressed: () {
                  Navigator.pop(context);
                  _getUserName(index);
                },
                textColor: Colors.teal,
                color: Color(0xFFEFEFEF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Native -> Flutter call handler
    platform.setMethodCallHandler(_handlerMethod);
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButton: (_fabShow)?FloatingActionButton.extended(
          onPressed: () {
            _fetchStatuses();
          },
          icon: Icon(Icons.refresh),
          label: Text("Refresh"),
          backgroundColor: Colors.green,
        ):null,
        appBar: appBarW(appBarMessage, context),
        body: Container(
          padding: EdgeInsets.only(top: 5.0),
          color: Color(0xFFEFEFEF),
          child: (_permissionStatus)
              ? (_isLoading)
                  ? loadingView("Fetching every status...", context)
                  : (_noContent)?showNoContent():buildUI()
              : _permissionAskingView(),
        ),
      ),
    );
  }
}
