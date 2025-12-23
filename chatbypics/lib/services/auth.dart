import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //LOGIN
  Future<void> signInWithEmailAndPassword(
    {required String email, required String password}) async {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // REGISTRAZIONE
  Future<void> createUserWithEmailAndPassword({
    required String email, 
    required String password,
    required String nome,
    required String cognome,
    required bool isTutor,}) async {
      //Creazione dell'utente su Firebase Authentication
      UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        );

      //salvo i dettagli nel database usando l'ID univoco dell'utente
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'Nome': nome,
        'Cognome': cognome,
        'email': email,
        'ruolo': isTutor? 'Tutor' : 'Communication partner', //definisce il ruolo come stringa
        'dataRegistrazione': DateTime.now(),
      });
      //invia la mail di verifica
      if(credential.user != null && !credential.user!.emailVerified){
        await credential.user!.sendEmailVerification();
      }
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  //funzione per inviare la mail di reset password
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
  
}