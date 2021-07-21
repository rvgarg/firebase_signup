import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_signup/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/login': (context) => Login(),
        },
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _globalKey = GlobalKey<FormState>();
  final _userName = TextEditingController();
  final _password = TextEditingController();
  late String _email;

  @override
  void initState() => super.initState();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login({required String mobile, required BuildContext context}) async {
    mobile = '+91' + mobile;
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: Duration(seconds: 30),
          verificationCompleted: (phoneAuthCredential) async {
            await _auth.signInWithCredential(phoneAuthCredential).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('LoggedIn with phone Auth !!!')));
              Navigator.of(context).pushNamed('/login');
            }).catchError((onError) {
              print(onError);
            });
          },
          verificationFailed: (e) {
            print(e.message);
          },
          codeSent: (verificationId, [int? resend_id]) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Enter OTP'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _password,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.redAccent),
                    ),
                    onPressed: () {
                      FirebaseAuth auth = FirebaseAuth.instance;

                      var smsCode = _password.text.trim();

                      var _credential = PhoneAuthProvider.getCredential(
                          verificationId: verificationId, smsCode: smsCode);
                      auth
                          .signInWithCredential(_credential)
                          .then((AuthResult result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged In via OTP')));
                        Navigator.of(context).pushNamed('/login');
                      }).catchError((e) {
                        print(e);
                      });
                    },
                  )
                ],
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print(verificationId);
          });
    } catch (e) {
      print(e.toString());
    }
  }

  void loginWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    _auth.signInWithCredential(credential).then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Signed in by google')));
      Navigator.of(context).pushNamed('/login');
    });
  }

  void loginWithFacebook() async {
    var login = FacebookLogin();
    var loginResult = await login.logInWithReadPermissions(['email']);
    switch (loginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login by Facebook done!!')));
        Navigator.of(context).pushNamed('/login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _globalKey,
        child: Stack(
          children: [
            Align(
              child: TextFormField(
                controller: _userName,
                decoration: InputDecoration(
                    labelText: 'Mobile No.', contentPadding: EdgeInsets.all(5)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mobile number is required !!';
                  }
                },
              ),
              alignment: Alignment.topCenter,
            ),
            Align(
              child: TextButton(
                onPressed: () {
                  _globalKey.currentState!.validate();
                  setState(() {
                    _email = _userName.text.trim();
                  });
                  login(mobile: _email, context: context);
                },
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              alignment: Alignment.center,
            ),
            Align(
              child: Column(
                children: [
                  TextButton(
                    onPressed: loginWithGoogle,
                    child: Text(
                      'GOOGLE  ',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                  TextButton(
                    onPressed: loginWithFacebook,
                    child: Text(
                      'FACEBOOK',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ],
              ),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
}
