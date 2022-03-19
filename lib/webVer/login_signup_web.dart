import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kchat/pages/home_page_web.dart';
import 'package:kchat/webVer/first_signup_web.dart';
import 'package:kchat/models/UserModel.dart';
import 'package:kchat/services/firbase_auth_service.dart';
import 'package:kchat/style/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSignupWeb extends StatefulWidget{
  State createState() => LoginSignupWebState();

}

class LoginSignupWebState extends State<LoginSignupWeb> {

  UserModel user;
  bool _isloading=false;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  LoginSignupWebState({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();
  SharedPreferences prefs;




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // theme:  Styles.themeData(themeChangeProvider.darkTheme, context),,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _isloading ?_loadingIndicator() : InkWell(
                onTap: () async {
                  setState(() {
                    _isloading=true;
                  });

                  try {
                    final googleUser = await _googleSignIn.signIn();
                    final googleAuth = await googleUser.authentication;
                    final credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );
                    final authResult = await _firebaseAuth.signInWithCredential(
                        credential);
                    user = _userFromFirebase(authResult.user);
                    prefs = await SharedPreferences.getInstance();


                    // Fluttertoast.showToast(
                    //     msg: prefs.getString("photoUrl"),
                    //     toastLength: Toast.LENGTH_SHORT,
                    //     gravity: ToastGravity.CENTER,
                    //     timeInSecForIosWeb: 1,
                    //     backgroundColor: Colors.red,
                    //     textColor: Colors.white,
                    //     fontSize: 16.0
                    // );
                    print(prefs.getString("photoUrl"));

                    if (authResult.additionalUserInfo.isNewUser) {

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.email)
                        .set(
                      {
                        'displayName': user.displayName,
                        'aboutMe': "",
                        'photoUrl': user.photoUrl,
                        'id':user.uid,
                      }
                    );
                    prefs.setString("uid", user.uid);
                    prefs.setString("email", user.email);
                    prefs.setString("displayName", user.displayName);
                    prefs.setString("photoUrl", user.photoUrl);
                    prefs.setBool("isLoggedIn", true);

                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new FirstSignupWeb()));
                    }
                    else{



                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.email).get().then((snapshot) {
                            var snap=snapshot.data();
                            prefs.setString("uid", user.uid);
                            prefs.setString("email", user.email);
                            prefs.setString('displayName', snap['displayName']);
                            prefs.setString("photoUrl", snap['photoUrl']);
                            prefs.setBool("isLoggedIn", true);
                      });
                      Navigator.pushReplacement(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) => new HomePageWeb()));
                    }
                  }
                  catch(e)
                  {
                    setState(() {
                      _isloading=false;
                    });
                  }



                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).focusColor,
                      border: Border.all(color: Theme.of(context).accentColor),
                      borderRadius: BorderRadius.all(Radius.circular(30))
                  ),
                  padding: EdgeInsets.all(10),

                  child: Text("signin/signup with google",
                    style: TextStyle(color: Colors.white70,fontSize: 18),),
                ),
              ),
            ),
          ),
          SizedBox(
            // height: 200,
            height: MediaQuery.of(context).size.height/8,
          ),

        ],

      ),
    );

  }
  Center _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

}

UserModel _userFromFirebase(User user) {
  if (user == null) {
    return null;
  }
  return UserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );
}
