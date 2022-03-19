
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Options extends StatefulWidget {

  State createState() =>  OptionsState();
}

class OptionsState extends State<Options> {
  SharedPreferences prefs;
  bool _isphotoSelected=false;
  var _pickedImages ;
  String _imageInfo = '';
  bool _isloading=true;

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
      _isloading=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body:Column(
        children: [
          SizedBox(height: 150,),
          CircleAvatar(
            radius: 60,
             backgroundImage: NetworkImage(
               prefs.getString('photoUrl')
             ) ,
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text("Personal Info"),
                ),
                ElevatedButton(onPressed:(){

                }, child: Text("Log Out"))
              ],
            ),
          )
        ],
      ) ,
    );
  }


}