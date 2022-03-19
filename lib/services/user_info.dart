import 'package:shared_preferences/shared_preferences.dart';

class UserInfo{
  var name;

  var photo;



  get_user() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    name = pref.getString('displayName');
    photo = pref.getString('photoUrl');
    return {'name': name, 'photo': photo};
  }
}