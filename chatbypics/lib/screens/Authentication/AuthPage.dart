import 'package:chatbypics/screens/Authentication/Stile/StileAuthPage.dart';
import 'package:chatbypics/screens/setting/StileSettingPage.dart';
import 'package:chatbypics/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget{
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  ///[_email] controller per l'inserimento dell'email
  final TextEditingController _email = TextEditingController();
  ///[_password] controller per l'inserimento della password
  final TextEditingController _password = TextEditingController();
  ///[_name] controller per l'inserimento del nome
  final TextEditingController _name = TextEditingController();
  ///[_surname] controller per l'inserimento del cognome
  final TextEditingController _surname = TextEditingController();

  ///[isLogin] flag per decidere che pagina restituire
  bool isLogin = false;
  ///[isTutor] flag per registrare la persona come tutor, se la spunta è disattivata,
  ///l'utente viene registrato come COMUNICATION PARTNER 
  bool isTutor = false; // Variabile per gestire la spunta del Tutor
  ///[obscurePassword] flag per oscurare la password nella fase di inserimento
  bool obscurePassword = true; // Inizia come 'true' (nascosta)

  Future<void> signIn() async{
    try{
      await Auth().signInWithEmailAndPassword(
        email: _email.text.trim(), 
        password: _password.text.trim()
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Si è verificato un errore.";

      // Controlliamo il codice dell'errore restituito da Firebase
      if (e.code == 'user-not-found') {
        errorMessage = "Nessun utente registrato con questa email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Password errata.";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Email o password errati (o utente non trovato).";
      }

      // Mostra la barra rossa in basso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red, // Colore rosso per l'errore
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> createUser() async{
    try{
      await Auth().createUserWithEmailAndPassword(
        email: _email.text.trim(), 
        password: _password.text.trim(),
        nome: _name.text.trim(),
        cognome: _surname.text.trim(),
        isTutor: isTutor,
      );
      
    } on FirebaseAuthException catch (e) {
      print("Errore Registrazione: $e");
    }
  }

  Future<void> forgotPassword() async{
    try {
      if (_email.text.trim().isEmpty) {
        // Mostra un avviso se l'email è vuota
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inserisci la tua email per resettare la password")),
        );
        return;
      }
      await Auth().sendPasswordResetEmail(email: _email.text.trim());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link inviato! Controlla la tua email.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Errore durante l'invio")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StileSettingPage.buildAppBar,
      body: Stileauthpage.buildScrollView(
        isLogin, 
        isTutor, 
        _name, 
        _surname, 
        _email, 
        _password, 
        obscurePassword, 
        (){
          setState(() {
            obscurePassword = !obscurePassword;
          });
        }, 
        (val){
          setState(() {
            isTutor=val;
          });
        }, 
        forgotPassword, 
        createUser, 
        signIn, 
        (){
          setState(() {
            isLogin = !isLogin;
            if(isLogin){
              isTutor=false;
              _name.clear();
              _surname.clear();
            }
          });
        }
      ),
    );
  }
}