// import 'dart:html';
// import 'dart:html';
// import 'dart:io';

import 'dart:typed_data';
// import 'package:extended_image/extended_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart' as imgUtils;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kchat/pages/home_page.dart';

import 'package:kchat/pages/home_page_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirstSignup extends StatefulWidget{

  State createState() => FirstSignupState();

}

class FirstSignupState extends State<FirstSignup>{
  SharedPreferences prefs;
  bool _isphotoSelected=false;
  var _pickedImages ;
  String _imageInfo = '';
  bool _isloading=true;
  var imagePath=null;
  final picker = ImagePicker();
  var img;

  TextEditingController nameController ;
  TextEditingController aboutController ;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _intsharedPreference();
  }

  _intsharedPreference() async{

    prefs= await SharedPreferences.getInstance();
    nameController = TextEditingController(text: prefs.getString("displayName"));
    aboutController = TextEditingController(text: "vibing");
    print(prefs.getString("photoUrl"));
    setState(() {
      _isloading=false;
    });
  }
  final _formKey = GlobalKey<FormState>();


  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imagePath= pickedFile.path;
        pickedFile.readAsBytes().then((value) {_pickedImages=value;
          // final file = File.fromRawPath(_pickedImages);
          // img = imgUtils.decodeImage(file.readAsBytesSync());
        });
        print("path "+imagePath.toString());

        _isphotoSelected=true;
      } else {
        print('No image selected.');
      }
    });
  }


  Future uploadFile(name,about,id,avatarImageFile) async {
    String fileName = id;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask;
    // if(avatarImageFile.runtimeType==Uint8List) {
    //   print("string d");
    uploadTask = reference.putData(avatarImageFile);
    // }
    // else{
    //   print("string p");
    //   uploadTask = reference.putFile(avatarImageFile);}
    TaskSnapshot storageTaskSnapshot;
    await uploadTask.then((value) {
      if (value != null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          var photoUrl = downloadUrl;
          FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .update({
            'displayName': name,
            'aboutMe': about,
            'photoUrl': photoUrl,
          }).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              _isloading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              _isloading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            _isloading = false;
          });
          Fluttertoast.showToast(msg: err.toString());
        });
      } else {
        setState(() {
          _isloading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        _isloading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }


  @override
  Widget build(BuildContext context)  {
    // TODO: implement build
    // prefs =  SharedPreferences.getInstance() as SharedPreferences;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body:_isloading?Center(
        child: CircularProgressIndicator(),
      ):Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .2,
          ),

          Center(
            child: prefs!=null ?
            InkWell(
              // image= await picker.pickImage(source:ImageSource.gallery);
              onTap: () async {
                // _pickImage();
                // _getImgFile();

                getImage();
              },
              child: _isphotoSelected ? CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(imagePath),
              ):CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(prefs.getString("photoUrl")),
              ),
            ) : Container() ,
          ),
          SizedBox(height: 30,),
          Container(
            width: 500,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Add TextFormFields and ElevatedButton here.
                  TextFormField(
                    // initialValue: prefs.getString("displayName"),
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'UserName',


                      labelStyle: TextStyle(
                        color: Theme.of(context).textSelectionColor,
                        fontSize: 17,
                      ),),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: aboutController,
                    // initialValue: "Vibing",
                    decoration: InputDecoration(labelText: 'About',
                      labelStyle: TextStyle(
                        color: Theme.of(context).textSelectionColor,
                        fontSize: 17,
                      ),),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(

                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Processing Data')));
                        }

                        uploadFile(nameController.text,aboutController.text,prefs.getString("email"),imagePath!=null ? _pickedImages:prefs.getString("photoUrl"));
                        Navigator.pushReplacement(context, new MaterialPageRoute(
                            builder: (BuildContext context) => new HomePage()));
                      },
                      child: Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          )


        ],
      ) ,
    );
  }

}
