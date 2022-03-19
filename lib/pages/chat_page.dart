
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kchat/models/channelModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget{

  ChannelModel channel;

  ChatPage({Key key, @required this.channel}) : super(key: key);

  State createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  bool _adding=false;
  final _formKey = GlobalKey<FormState>();
  int selectedIndex=-1;
  SharedPreferences prefs;
  bool _isloading=false;
  List<QueryDocumentSnapshot<Object>> chatData;

  ChannelModel selectedChannel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _intsharedPreference();
    selectedChannel=widget.channel;
  }

  _intsharedPreference() async{

    prefs= await SharedPreferences.getInstance();

    print(prefs.getString("photoUrl"));
    setState(() {
      // _isloading=false;
    });
  }

  @override
  Widget  build(BuildContext context){

    final _msgKey = GlobalKey<FormState>();
    TextEditingController msgCntrl = TextEditingController();

    var _pickedImages ;
    String _imageInfo = '';
    bool _isloading=true;
    var imagePath=null;
    final picker = ImagePicker();



    Future uploadFile(id,avatarImageFile) async {


      DocumentReference ref=FirebaseFirestore.instance.collection('chats').doc(selectedChannel.channelId).collection('chatData').doc();

      Reference reference = FirebaseStorage.instance.ref().child(id).child(ref.id);
      UploadTask uploadTask;
      uploadTask = reference.putData(avatarImageFile);

      TaskSnapshot storageTaskSnapshot;
      await uploadTask.then((value) {
        if (value != null) {
          storageTaskSnapshot = value;
          storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            var photoUrl = downloadUrl;

            ref.set(
                {
                  // 'text':msgCntrl.text,
                  'sender':prefs.getString('email'),
                  'photoUrl':photoUrl,
                  'timeStamp':FieldValue.serverTimestamp(),
                  'id':ref.id,
                  'type':'image',
                }

            ).then((data) async {
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

    Future getImage() async {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          imagePath= pickedFile.path;
          pickedFile.readAsBytes().then((value) {_pickedImages=value;
          // final file = File.fromRawPath(_pickedImages);
          // img = imgUtils.decodeImage(file.readAsBytesSync());
          uploadFile(selectedChannel.channelId, _pickedImages);
          });
          print("path "+imagePath.toString());

          // _isphotoSelected=true;
        } else {
          print('No image selected.');
        }
      });
    }
    print("chat window "+ selectedChannel.channelId);
    var ref= FirebaseFirestore.instance.collection('chats').doc(selectedChannel.channelId).collection('chatData').orderBy('timeStamp',descending: true).limit(20);

    return Scaffold(
      backgroundColor: Theme.of(context).focusColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AppBar(
            leading: Container(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(selectedChannel.photoUrl),
              ),
            ),
            title: Text(selectedChannel.name),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot==null) {
                  return Center(
                      child: CircularProgressIndicator());
                } else {
                  print("new");
                  // print(snapshot.data.docs);
                  // print(snapshot.data.docs.runtimeType.toString());
                  var snapData =snapshot.data;
                  if(snapData!=null) {
                    chatData=<QueryDocumentSnapshot<Object>>[];
                    snapData.docs.forEach((element) {
                      chatData.add(element);
                    });
                  }
                  // if(snapData!=null)
                  //   {
                  //     var chatdata=snapData.data();
                  //     print(chatdata);
                  //
                  //   }
                  if(chatData!=null){
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        if(snapshot!=null)
                        {
                          // print("why "+selectedChannel.channelId);
                          // chatData= documentSnapshot.data();
                          // print(chatData['type']);

                          return Align(
                            alignment: chatData[index]['sender']==prefs.getString('email')? Alignment.centerRight:Alignment.centerLeft,
                            child: chatData[index]['type']=='text'?Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child:
                              Text(chatData[index]['text']),
                            ):
                            Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Image(image: NetworkImage(chatData[index]['photoUrl'],scale: 2))
                              // Container(
                              //   height: 250.0,
                              //   width: 350.0,
                              //
                              //   decoration: BoxDecoration(
                              //     image: DecorationImage(
                              //       image: NetworkImage(chatData['photoUrl'])
                              //     )
                              //   ),
                              // ),
                            ),
                          );
                        }

                        return Container(

                        ) ;
                      },
                      itemCount: chatData.length,
                      reverse: true,
                      // controller: listScrollController,
                    );}
                  else
                    return Container();
                }
              },
            ),
            // PaginateFirestore(
            //   reverse: true,
            //   // shrinkWrap: true,
            //   itemBuilderType:PaginateBuilderType.listView, //Change types accordingly
            //   itemBuilder: (index, context, documentSnapshot) {
            //        if(documentSnapshot!=null)
            //          {
            //            print("why "+selectedChannel.channelId);
            //            chatData= documentSnapshot.data();
            //            print(chatData['type']);
            //
            //            return Align(
            //              alignment: chatData['sender']==prefs.getString('email')? Alignment.centerRight:Alignment.centerLeft,
            //              child: chatData['type']=='text'?Container(
            //                padding: EdgeInsets.all(10),
            //                margin: EdgeInsets.all(10),
            //                decoration: BoxDecoration(
            //                  color: Theme.of(context).accentColor,
            //                  borderRadius: BorderRadius.all(Radius.circular(20)),
            //                ),
            //                child:
            //                Text(chatData['text']),
            //              ):
            //              Container(
            //                padding: EdgeInsets.all(10),
            //                margin: EdgeInsets.all(10),
            //                decoration: BoxDecoration(
            //                  color: Theme.of(context).accentColor,
            //                  borderRadius: BorderRadius.all(Radius.circular(20)),
            //                ),
            //                child: Image(image: NetworkImage(chatData['photoUrl'],scale: 2))
            //                // Container(
            //                //   height: 250.0,
            //                //   width: 350.0,
            //                //
            //                //   decoration: BoxDecoration(
            //                //     image: DecorationImage(
            //                //       image: NetworkImage(chatData['photoUrl'])
            //                //     )
            //                //   ),
            //                // ),
            //              ),
            //            );
            //          }
            //
            //     return Container(
            //
            //     ) ;
            //   },
            //   // orderBy is compulsory to enable pagination
            //   query: FirebaseFirestore.instance.collection('chats').doc(selectedChannel.channelId)
            //       .collection('chatData').orderBy('timeStamp',descending: true),
            //   // to fetch real-time data
            //   isLive: true,
            //
            // )
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white70,
              padding: EdgeInsets.all(5),
              // decoration: BoxDecoration(
              //   color: Theme.of(context).focusColor,
              //   borderRadius: BorderRadius.all(Radius.circular(20)),
              // ),
              child: Row(

                children: [
                  GestureDetector(
                    onTap:(){
                      getImage();

                    },
                    child: CircleAvatar(
                      // backgroundColor: ,
                      child: Icon(Icons.photo,size: 15,color: Colors.white70,),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(child:
                  Form(
                    key: _msgKey,
                    child: Container(
                      padding: EdgeInsets.only(left: 8,right: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).focusColor,
                          borderRadius: BorderRadius.all(Radius.circular(25))
                      ),
                      child: TextFormField(
                        // key: _msgKey,
                        controller: msgCntrl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value){
                          if (_msgKey.currentState.validate()) {
                            _msgKey.currentState.save();
//               var result = await auth.sendPasswordResetEmail(_email);
//               print(result);
//                      print(_email);
//                      Navigator.of(context).pop();

                            print(selectedChannel.channelId);
                            DocumentReference ref=FirebaseFirestore.instance.collection('chats').doc(selectedChannel.channelId).collection('chatData')
                                .doc();
                            ref.set(
                                {
                                  'text':msgCntrl.text,
                                  'sender':prefs.getString('email'),
                                  // 'photoUrl':prefs.getString('photoUrl'),
                                  'timeStamp':FieldValue.serverTimestamp(),
                                  'id':ref.id,
                                  'type':'text',
                                }

                            );
                            msgCntrl.clear();
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type message",
                          hintStyle: TextStyle(
                            color: Theme.of(context).textSelectionColor,
                            fontSize: 17,
                          ),),

                      ),
                    ),
                  )),

                ],
              ),
            ),
          )


        ],
      )
      ,
    );

  }

}