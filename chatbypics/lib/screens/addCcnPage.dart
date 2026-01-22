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
  final _formKey = GlobalKey<FormState>();
  
  // Controller per i campi di testo
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuovo Utente CCN"),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Crea un account per il tuo assistito.\nLui dovrà solo fare il login.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 20),

              // CAMPO NOME
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Nome"),
                validator: (val) => val!.isEmpty ? "Inserisci il nome" : null,
              ),
              const SizedBox(height: 15),

              // CAMPO COGNOME
              TextFormField(
                controller: _surnameController,
                decoration: _inputDecoration("Cognome"),
                validator: (val) => val!.isEmpty ? "Inserisci il cognome" : null,
              ),
              const SizedBox(height: 15),

              // CAMPO EMAIL
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.contains("@") ? null : "Email non valida",
              ),
              const SizedBox(height: 15),

              // CAMPO PASSWORD
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration("Password provvisoria"),
                obscureText: true,
                validator: (val) => val!.length < 6 ? "Minimo 6 caratteri" : null,
              ),
              const SizedBox(height: 30),

              // BOTTONE REGISTRAZIONE
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Registra Utente CCN", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- STILE CAMPI ---
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  // --- LOGICA DI REGISTRAZIONE "SILENZIOSA" ---
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Dati del Tutor attuale (noi)
    final String tutorId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseApp? secondaryApp;

    try {
      // 2. Creiamo un'istanza secondaria di Firebase
      // Questo serve per creare l'utente SENZA sloggare il Tutor
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // 3. Creiamo l'utente sulla seconda istanza
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      String newUserId = userCredential.user!.uid;

      // 4. Salviamo i dati su Firestore (DB principale)
      // Qui aggiungiamo il ruolo 'CCN' e il 'tutorId' per collegarli
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
        Navigator.pop(context); // Torna indietro alla lista
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
      // 5. PULIZIA: Cancelliamo l'app secondaria per liberare memoria
      await secondaryApp?.delete();
      if (mounted) setState(() => _isLoading = false);
    }
  }
}