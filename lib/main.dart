import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kchat/pages/home_page.dart';
import 'package:kchat/pages/home_page_web.dart';
import 'package:kchat/webVer/first_signup_web.dart';
import 'package:kchat/style/dark_theme_provider.dart';
import 'package:kchat/style/styles.dart';
import 'package:kchat/webVer/login_signup_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/login_signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  State createState() => _MyAppState();
}
class _MyAppState extends State<MyApp>
{
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();
  SharedPreferences prefs;
  var isLoggedIn;

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    getsharedPrefernce();
  }



  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
    print("hh"+ themeChangeProvider.darkTheme.toString());

  }
  void getsharedPrefernce() async{
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = (prefs.getBool('isLoggedIn') == null) ? false : prefs.getBool('isLoggedIn');
    print("log "+isLoggedIn.toString());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      theme: Styles.themeData(true, context),
      home: FutureBuilder(
        // Replace the 3 second delay with your initialization code:
          future: Future.delayed(Duration(seconds: 3)),
          builder: (context, AsyncSnapshot snapshot) {
            // Show splash screen while waiting for app resources to load:
            if (snapshot.connectionState == ConnectionState.waiting) {
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Splash());
            } else {
              return isLoggedIn ? kIsWeb ? HomePageWeb():HomePage(): kIsWeb ? LoginSignupWeb():LoginSignup();}}),
    );
  }

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, AsyncSnapshot snapshot) {
          // Show splash screen while waiting for app resources to load:
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(home: Splash());
          } else {
            return LoginSignup();}});
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.apartment_outlined,
          size: MediaQuery.of(context).size.width * 0.785,
        ),
      ),
    );
  }
}