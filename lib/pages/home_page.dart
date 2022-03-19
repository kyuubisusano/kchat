import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kchat/models/UserModel.dart';
import 'package:kchat/models/channelModel.dart';
import 'package:kchat/pages/options_page.dart';
import 'package:kchat/provider/channel_provider.dart';
import 'package:kchat/widget/channel_list.dart';

import 'package:kchat/widget/user_image_widget.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';



class HomePage extends StatefulWidget {

  State createState() => HomePageState();

}

class HomePageState extends State<HomePage>{
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
  }

  _intsharedPreference() async{

    prefs= await SharedPreferences.getInstance();

    print(prefs.getString("photoUrl"));
    setState(() {
      // _isloading=false;
    });
  }
  buildLoading(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        });
  }
  Widget _searchPeople()
  {
    TextEditingController emailCntrl =TextEditingController();
    return Scaffold(
      body: Column(
        children: [

          AppBar(
            leading: GestureDetector(
              onTap: (){
                setState(() {
                  _adding=false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  // radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.arrow_back,size: 15, color: Colors.black),
                ),
              ),
            ),
          ),

          SizedBox(height: 200,),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailCntrl,
                    decoration: InputDecoration(labelText: 'Add Friend',
                      hintText: "email",

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
                          _addChannel( emailCntrl.text );
                          setState(() {
                            _adding=false;
                          });
                        }


                      },
                      child: Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    )
    ;
  }

  Future<UserModel>  _getUsersDetails(id)
  async {
    var user;
    await FirebaseFirestore.instance.collection('users').doc(id).get().then((value) {
      print("check1");
      var snap = value.data();

      user = UserModel(
        uid: snap['id'],
        email: id,
        displayName: snap['displayName'],
        photoUrl: snap['photoUrl'],
      );


    });
    return user;
  }

  _addChannel(id) async {
    var userid =prefs.getString('email');
    var groupChatId;
    await _getUsersDetails(id).then((value){

      var l=value;
      print("jjikk "+value.displayName);
      if ( userid.hashCode <= id.hashCode) {
        groupChatId = '$userid-$id';
      } else {
        groupChatId = '$id-$userid';
      }



      var list = [{'channelId': groupChatId,
        'peerEmail' :id,
        'name':l.displayName,
        'photoUrl':l.photoUrl}];
      FirebaseFirestore.instance
          .collection('users').doc(prefs.getString("email")).update(
          {
            'channels': FieldValue.arrayUnion(list)
          }
      ).then((value) {

        var list2 =[{'channelId': groupChatId,
          'peerEmail' : prefs.getString('email'),
          'name': prefs.getString('displayName'),
          'photoUrl': prefs.getString('photoUrl')
        }];

        FirebaseFirestore.instance
            .collection('users').doc(id).update(
            {
              'channels': FieldValue.arrayUnion(list)
            });

      });
    });

  }




  @override
  Widget build(BuildContext context) {

    // Provider.of<ChannelProvider>(context).selectedChannel;

    return Scaffold(
      body: Row(
        children: [
          Expanded(child: _adding? _searchPeople():buildChats(context)),
          // VerticalDivider(indent: 0, endIndent: 0, thickness: 0.5, width: 0.5,color: Theme.of(context).focusColor,),
          // Expanded(flex: 3, child: buildChat()),
          // _isloading?buildLoading(context):Container()
        ],
      ),
    );
  }

  Widget buildChats(BuildContext context) => Column(
    children: [
      AppBar(
        leading: InkWell(
            onTap:(){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Options(),
                  ));
            },child: UserImageWidget()),
        title: Text('K-Chats',style: TextStyle(color: Theme.of(context).accentColor),),
        actions: [
          InkWell(
            onTap: (){
              setState(() {
                _adding=true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(

                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.people, size: 25, color: Colors.black),
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      Expanded(child: channelList()),
    ],
  );

  Widget buildChat() {
    if (selectedChannel == null) {
      return Center(
        child: Text(
          'Select A Chat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return chatWindow();

  }

  Widget channelList(){
    DocumentReference<Map<String, dynamic>> user;
    if(prefs!=null)
      user = FirebaseFirestore.instance.collection('users').doc(prefs.getString('email'));

    return Scaffold(
      body: user==null ? CircularProgressIndicator():StreamBuilder<DocumentSnapshot>(
        stream: user!=null ? user.snapshots(): null,
        builder: ( context,AsyncSnapshot<DocumentSnapshot> snapshot) {
          if(snapshot!=null) {

            print(snapshot.runtimeType.toString());
            var snapdata = snapshot.data;
            Map<String,dynamic> channelData;
            List<ChannelModel> channelList;
            if(snapdata!=null) {
              channelData = snapdata.data();

              print(channelData['channels']);
              // print(channelData);
              if(channelData['channels']!=null) {
                channelList = <ChannelModel>[];
                // List<ChannelModel> channelList = List.from(channelData);
                List.from(channelData['channels']).forEach((element) {
                  // print("Afa "+element);
                  print("check3");
                  ChannelModel data = new ChannelModel.fromJson(element);
                  //
                  // //then add the data to the List<Offset>, now we have a type Offset
                  channelList.add(data);
                });
                print(channelList);

                return ListView.builder(
                  itemCount: channelList.length,
                  itemBuilder: (context, index) {
                    if (channelList != null && channelList.length > 0) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            Colors.white70;
                            print("clicked" +
                                " " +index.toString()+" "+
                                channelList[index].channelId + " "+ channelList.length.toString());
                            selectedChannel = channelList[index];
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(channel: selectedChannel,),
                                ));
                            if(chatData!=null)
                              chatData.clear();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 8,bottom: 8,left: 3,right: 3),
                          color: index == selectedIndex
                              ? Colors.white70
                              : Theme.of(context).cardColor,
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    channelList[index].photoUrl),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                children: [
                                  Text(channelList[index].name),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    } else
                      return CircularProgressIndicator();
                  },
                );
              }
              else
              {
                return Center(
                  child: Text("Add Friends"),
                );
              }
            }
            return CircularProgressIndicator();
          }
          else{
            return CircularProgressIndicator();
          }
        },

      ),
    )
    ;
  }

  Widget chatWindow(){

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
      final pickedFile = await picker.getImage(source: ImageSource.camera);

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
