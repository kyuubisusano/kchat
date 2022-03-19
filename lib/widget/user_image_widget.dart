import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserImageWidget extends StatefulWidget {

    State createState() => _UserImageWidgetState();

}

class _UserImageWidgetState extends State<UserImageWidget>{
  SharedPreferences prefs;
  var email;
bool _isloading=true;
  _intsharedPreference() async{

    prefs= await SharedPreferences.getInstance();

    email = prefs.getString("photoUrl");
    setState(() {
      _isloading = false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    _intsharedPreference();
  }


  @override
  Widget build(BuildContext context) {
    // final user = StreamChat.of(context).user;
    // final urlImage = user.extraData['image'];

    return GestureDetector(
      // onTap: () => Navigator.of(context).push(MaterialPageRoute(
      //   builder: (context) => ProfilePage(),
      // )),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: CircleAvatar(
          backgroundImage: email!=null ? NetworkImage(prefs.getString("photoUrl")): AssetImage('assets/example.png'),
        ),
      ),
    );
  }
}
