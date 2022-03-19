//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:kchat/models/channelModel.dart';
// import 'package:paginate_firestore/paginate_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ChannelList extends StatefulWidget{
//
//   State createState() => ChannelListState();
//
//
// }
//
// class ChannelListState extends State<ChannelList>{
//
//   SharedPreferences prefs;
//  bool _isloading =true;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _intsharedPreference();
//   }
//
//   _intsharedPreference() async{
//
//     prefs= await SharedPreferences.getInstance();
//
//     print(prefs.getString("photoUrl"));
//     setState(() {
//       _isloading=false;
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     DocumentReference<Map<String, dynamic>> user;
//     if(prefs!=null)
//     user = FirebaseFirestore.instance.collection('users').doc(prefs.getString('email'));
//
//     return Scaffold(
//       body: _isloading ? Container():StreamBuilder<DocumentSnapshot>(
//           stream: user.snapshots(),
//         builder: ( context,AsyncSnapshot<DocumentSnapshot> snapshot) {
//             if(snapshot.hasData) {
//               final data = snapshot.data ;
//
//               print(snapshot.runtimeType.toString());
//               Map<String,dynamic> channelData= snapshot.data.data();
//               print(channelData['channels']);
//               // print(channelData);
//               List<ChannelModel> channelList =new List<ChannelModel>();
//               // List<ChannelModel> channelList = List.from(channelData);
//               List.from(channelData['channels']).forEach((element){
//                 // print("Afa "+element);
//                 ChannelModel data = new ChannelModel.fromJson(element);
//                 //
//                 // //then add the data to the List<Offset>, now we have a type Offset
//                 channelList.add(data);
//               });
//               print(channelList);
//
//
//               return ListView.builder(
//                 itemCount: channelList.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundImage: NetworkImage(channelList[index]
//                               .photoUrl),
//                         ),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         Column(
//                           children: [
//                             Text(channelList[index].name),
//                           ],
//                         )
//
//                       ],
//                     ),
//                   );
//                 },
//               );
//               // return Container();
//             }
//             else{
//               return Container();
//             }
//         },
//
//       ),
//     )
//       ;
//   }
//
// }