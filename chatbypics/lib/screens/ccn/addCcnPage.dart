import 'package:chatbypics/screens/ccn/Stile/StileAddCcnPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Fondamentale per il trucco
import 'package:flutter/material.dart';

class AddCcnPage extends StatefulWidget {
  const AddCcnPage({super.key});

  @override
  State<AddCcnPage> createState() => _AddCcnPageState();
}

class _AddCcnPageState extends State<AddCcnPage> {
  /// [_formKey] Chiave globale che identifica il modulo di registrazione. 
/// Viene utilizzata per validare i campi di testo (nome, email, password) prima di inviare i dati a Firebase.
  final _formKey = GlobalKey<FormState>();
  
  ///[_nameController] controller per l'inserimento del nome
  final TextEditingController _nameController = TextEditingController();
  ///[_surnameController] controller per l'inserimento del cognome
  final TextEditingController _surnameController = TextEditingController();
  ///[_emailController] controller per l'inserimento dell'email
  final TextEditingController _emailController = TextEditingController();
  ///[_passwordController] controller per l'inserimento della password
  final TextEditingController _passwordController = TextEditingController();
  
  ///[_isLoading] variabile per disabilitare il bottone dopo il primo click per la registrazione del ccn
  ///serve per impedire che il tutor possa cliccare 10 volte il bottone, arrivando a registrare 10 ccn
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Stileaddccnpage.buildAppBar,
      body: Stileaddccnpage.buildScrollView(
        _formKey, 
        _nameController, 
        _surnameController, 
        _emailController, 
        _passwordController, 
        _isLoading, 
        _registerUser
      ),
    );
  }

  ///[_registerUser] questo metodo registra in firebase l'utente, vengono salvati anche i dati del tutor associato al ccn
  ///per consentirli di entrare nelle chat del ccn in modalità osservatore
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String tutorId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseApp? secondaryApp;

    try {
      //crea un'istanza secondaria di firebase per non fare uscire dall'account il tutor
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String newUserId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(newUserId).set({
        'uid': newUserId,
        'Nome': _nameController.text.trim(),
        'Cognome': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'ruolo': 'CCN', // RUOLO FONDAMENTALE
        'tutorId': tutorId, // Link al Tutor che l'ha creato
        'createdAt': FieldValue.serverTimestamp(),
        'profiloAttivo': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utente CCN creato con successo!")),
        );
        Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {
      String errorMsg = "Errore durante la registrazione";
      if (e.code == 'email-already-in-use') errorMsg = "Questa email è già registrata";
      if (e.code == 'weak-password') errorMsg = "La password è troppo debole";
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red));
      }
    } finally {
      await secondaryApp?.delete();
      if (mounted) setState(() => _isLoading = false);
    }
  }
}