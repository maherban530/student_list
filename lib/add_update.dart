import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:image_picker/image_picker.dart';

class StudentAddUpdate extends StatefulWidget {
  const StudentAddUpdate({
    Key key,
    this.docId,
    this.name,
    this.subA,
    this.subB,
    this.subC,
    this.dbname,
  }) : super(key: key);
  final docId;
  final name;
  final subA;
  final subB;
  final subC;
  final dbname;

  @override
  _StudentAddUpdateState createState() => _StudentAddUpdateState();
}

class _StudentAddUpdateState extends State<StudentAddUpdate> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController subAController = TextEditingController();
  final TextEditingController subBController = TextEditingController();
  final TextEditingController subCController = TextEditingController();

  void initState() {
    super.initState();
    if (widget.docId == null) {
      Container();
    } else {
      nameController.text = widget.name;
      subAController.text = widget.subA.toString();
      subBController.text = widget.subB.toString();
      subCController.text = widget.subC.toString();
    }
  }

  final _formKey = GlobalKey<FormState>();

  File _image;
  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

//
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.docId == null ? "Add Details" : "Update Details"),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 50,
                height: 50,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.grey[800],
                  size: 50,
                ),
              ),
            ),
            _image != null ? Image.file(_image) : Container(),
            TextField(
              textFieldController: nameController,
              name: "Name",
            ),
            TextField(
              textFieldController: subAController,
              name: "subA",
            ),
            TextField(
              textFieldController: subBController,
              name: "subB",
            ),
            TextField(
              textFieldController: subCController,
              name: "subC",
            ),
          ],
        ),
      )),
      actions: <Widget>[
        ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                widget.docId == null
                    ? db.collection("${widget.dbname}").add({
                        "name": nameController.text,
                        "subA": int.parse(subAController.text),
                        "subB": int.parse(subBController.text),
                        "subC": int.parse(subCController.text),
                        "url": _image.toString(),
                        "time": DateTime.now(),
                      })
                    : db
                        .collection("${widget.dbname}")
                        .doc(widget.docId)
                        .update({
                        "name": nameController.text,
                        "subA": int.parse(subAController.text),
                        "subB": int.parse(subBController.text),
                        "subC": int.parse(subCController.text),
                        "url": _image.toString(),
                      });
                widget.docId == null
                    ? showTopSnackBar(
                        context,
                        CustomSnackBar.success(
                          message: "Add Successful",
                        ),
                      )
                    : showTopSnackBar(
                        context,
                        CustomSnackBar.info(
                          message: "Update Successful",
                        ),
                      );
                Navigator.pop(context);
                nameController.clear();
                subAController.clear();
                subBController.clear();
                subCController.clear();
              }
            },
            child: Text(widget.docId == null ? "Add" : "Update"))
      ],
    );
  }
}

class TextField extends StatelessWidget {
  const TextField({
    Key key,
    @required this.textFieldController,
    @required this.name,
  }) : super(key: key);

  final TextEditingController textFieldController;
  final String name;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all((5)),
      // height: 38,
      width: MediaQuery.of(context).size.width,
      padding:
          EdgeInsets.only(top: 0.0, bottom: 0.0, left: (16.0), right: (16.0)),
      color: Colors.blueGrey.shade50,
      child: TextFormField(
        controller: textFieldController,
        cursorColor: Colors.blueGrey,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        validator: (value) => value == '' ? 'Please enter value' : null,
        decoration: InputDecoration(
          icon: Icon(
            Icons.signal_cellular_alt_outlined,
            color: Colors.blueGrey,
          ),
          border: InputBorder.none,
          hintText: name,
          hintStyle: TextStyle(
            color: Colors.blueGrey.shade300,
          ),
        ),
      ),
    );
  }
}
