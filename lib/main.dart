import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
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
  var _visible = false;
  var signedIn = false;
  late String _email, _pwd;
  FirebaseAuth _auth = FirebaseAuth.instance;

  void login({required String email, required String pwd}) async {
    try {
      _auth
          .signInWithEmailAndPassword(email: _email, password: _pwd)
          .then((value) => {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Login Successfull')))
              });
    } catch (e) {
      print(e.toString());
    }
  }

  void register({required String email, required String pwd}) async {
    try {
      _auth.createUserWithEmailAndPassword(email: email, password: pwd).then(
          (value) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('User Registered!!'))));
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
    _auth.signInWithCredential(credential).then((value) =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Signed in by google'))));
  }

  void loginWithFacebook() async {
    final AccessToken result = await FacebookAuth.instance.login();
    final facebookAuthCredential =
        FacebookAuthProvider.getCredential(accessToken: result.token);
    _auth.signInWithCredential(facebookAuthCredential).then((value) =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Signed in by facebook'))));
  }

  @override
  void initState() {
    // _auth.onAuthStateChanged.isEmpty.then((value) =>
    // // TODO: complete the function
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _globalKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userName,
                decoration: InputDecoration(
                    hintText: 'Email id', contentPadding: EdgeInsets.all(5)),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Email id is required !!';
                  }
                },
              ),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: EdgeInsets.all(5),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _visible = !_visible;
                      });
                    },
                    icon: Icon(Icons.remove_red_eye),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required !!';
                  }
                },
                obscureText: _visible,
              ),
              TextButton(
                onPressed: () {
                  _globalKey.currentState!.validate();
                  setState(() {
                    _email = _userName.text;
                    _pwd = _password.text;
                  });
                  login(email: _email, pwd: _pwd);
                },
                child: Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  _globalKey.currentState!.validate();
                  setState(() {
                    _email = _userName.text;
                    _pwd = _password.text;
                    register(email: _email, pwd: _pwd);
                  });
                },
                child: Text(
                  'SIGNUP',
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
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
        ),
      ),
    );
  }
}
