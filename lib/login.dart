import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(Login());

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MyLogin(title: 'Login'),
        theme: ThemeData(primarySwatch: Colors.red),
      );
}

class MyLogin extends StatefulWidget {
  final String title;

  MyLogin({Key? key, required this.title}) : super(key: key);

  @override
  MyLoginState createState() => MyLoginState();
}

class MyLoginState extends State<MyLogin> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: TextButton(
            child: Text('LOGOUT'),
            onPressed: () {
              setState(() {
                FirebaseAuth.instance
                    .signOut()
                    .then((value) => Navigator.of(context).pop());
              });
            },
          ),
        ),
        body: Center(
          child: Text(
            'WELCOME!!',
            style: TextStyle(fontSize: 20.0, color: Colors.redAccent),
          ),
        ),
      );
}
