import 'package:flutter/material.dart';

class TypeAheadWidget extends StatefulWidget {
  List contacts;
  String fileName;
  Function refreshApp, setContact;
  TypeAheadWidget(this.contacts,this.refreshApp, this.setContact,this.fileName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TypeAheadWidgetState();
  }
}

class _TypeAheadWidgetState extends State<TypeAheadWidget> {
  // focus node to listen for focus changes and dummy focus node to temporarily remove focus
  // this is done so as to disable the overlay once an option is clicked
  final FocusNode _focusNode = FocusNode(),_dummyFocusNode = FocusNode();

  // to help the box follow the text field
  final LayerLink _layerLink = LayerLink();

  // overlay entry to manage overlays
  OverlayEntry _overlayEntry;

  List _contacts, _customContacts = ["Enter Contact Name"], _customContacts2 = new List();
  final myController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checking for focus
    _focusNode.addListener(() {
      // if the field has focus, show renderBox
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      }
      // else remove it
      else {
        this._overlayEntry.remove();
      }
    });
  }


  Widget _contactListBuilder(int index){
    return ListTile(
      onTap: (){
        myController.text = _customContacts[index];
        widget.setContact(_customContacts[index]);
        FocusScope.of(context).requestFocus(_dummyFocusNode);
      },
      title: Text(_customContacts[index]),
    );
  }


  // overlay creation
  OverlayEntry _createOverlayEntry() {
    _contacts = widget.contacts.toSet().toList();
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: this._layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4.0,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: <Widget>[
                    _contactListBuilder(0),
                  ],
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CompositedTransformTarget(
        link: this._layerLink,
        child: TextField(
          autofocus: true,
          controller: myController,
          focusNode: this._focusNode,
          onChanged: (value){

            // gets back focus on the user has started typing again
            FocusScope.of(context).requestFocus(_focusNode);
            if(value.length>0){
              _customContacts2.clear();
              _contacts.forEach((contact){
                if(contact.toString().trim().toLowerCase().startsWith(value.toLowerCase())){
                  _customContacts2.add(contact);
                }
              });
              _customContacts = _customContacts2;
              //print("Tag:"+_customContacts.toString());
              if(_customContacts.length==0){
                _customContacts = ["Enter Contact Name"];
              }
              widget.refreshApp();
            }
          },
          decoration: InputDecoration(labelText: 'Status Contact'),
        ));
  }
}
