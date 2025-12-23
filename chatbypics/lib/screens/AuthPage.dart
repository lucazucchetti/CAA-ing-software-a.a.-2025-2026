import 'package:chatbypics/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget{
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLogin = true;

  Future<void> signIn() async{
    try{
      await Auth().signInWithEmailAndPassword(email: _email.text, password: _password.text);
    }on FirebaseAuthException catch (error){}
  }
  Future<void> createUser() async{
    try{
      await Auth().createUserWithEmailAndPassword(email: _email.text, password: _password.text);
    }on FirebaseAuthException catch (error){}
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data'),

      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: InputDecoration(label: Text('email')),
          ),
          TextField(
            controller: _password,
            decoration: InputDecoration(label: Text('password')),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: (){
              isLogin ? signIn() : createUser(); 
            }, 
            child: Text(isLogin ? 'Accedi' : 'Registrati')),
          TextButton(onPressed: (){
            setState(() {
              isLogin = !isLogin;
            });
          }, child: Text(isLogin ? 'Non hai un account? Registrati' : 'Hai già un account? Accedi'))
        ]
      ),
    );
  }
}