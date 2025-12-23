import 'package:chatbypics/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget{
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Controller per l'inserimento del testo
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _surname = TextEditingController();

  bool isLogin = false;
  bool isTutor = false; // Variabile per gestire la spunta del Tutor
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
        // Nota: Per sicurezza, le nuove versioni di Firebase spesso usano 
        // questo codice generico invece di dire esplicitamente "utente non trovato"
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
      // Chiamata aggiornata con i nuovi parametri (Nome, Cognome, Ruolo)
      // Assicurati che il tuo file auth.dart sia aggiornato come discusso prima!
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
      
      // Chiama la funzione nel service Auth
      await Auth().sendPasswordResetEmail(email: _email.text.trim());
      
      // Conferma all'utente
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
      appBar: AppBar(
        title: const Text('ChatByPics'),
      ),
      // Usiamo SingleChildScrollView per evitare errori quando si apre la tastiera
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SEZIONE REGISTRAZIONE: Mostra Nome e Cognome solo se non è login
            if (!isLogin) ...[
              TextField(
                controller: _name,
                decoration: const InputDecoration(label: Text('Nome')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _surname,
                decoration: const InputDecoration(label: Text('Cognome')),
              ),
              const SizedBox(height: 10),
            ],

            // SEZIONE COMUNE: Email e Password
            TextField(
              controller: _email,
              decoration: const InputDecoration(label: Text('Email')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _password,
              obscureText: obscurePassword, 
              decoration: InputDecoration(
                label: const Text('Password'),
                // Aggiungi l'icona a destra (Suffix Icon)
                suffixIcon: IconButton(
                  icon: Icon(
                  // Cambia icona in base allo stato: Occhio aperto o sbarrato
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // Quando clicchi, inverti il valore (da vero a falso e viceversa)
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            // CHECKBOX TUTOR: Visibile solo in registrazione
            if (!isLogin)
              CheckboxListTile(
                title: const Text("Registrati come Tutor"),
                value: isTutor,
                onChanged: (bool? val) {
                  setState(() {
                    isTutor = val!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

            const SizedBox(height: 20),
            if(isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: forgotPassword, 
                  child: const Text(
                    'Password Dimenticata?', 
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                      ),
                  ),
                ),
              ),

            // BOTTONE AZIONE
            ElevatedButton(
              onPressed: (){
                isLogin ? signIn() : createUser(); 
              }, 
              child: Text(
                isLogin ? 'Accedi' : 'Registrati',
                style: TextStyle(color: Colors.blue) 
              )
            ),

            // TOGGLE LOGIN/REGISTRAZIONE
            TextButton(
              onPressed: (){
                setState(() {
                  isLogin = !isLogin;
                  // Opzionale: pulisce i campi quando cambi modalità
                  if (isLogin) {
                     isTutor = false;
                     _name.clear();
                     _surname.clear();
                  }
                });
              }, 
              child: Text(
                isLogin ? 'Non hai un account? Registrati' : 'Hai già un account? Accedi',
                style: TextStyle(
                  color: Colors.blue,
                ),
              )
            ),
          ]
        ),
      ),
    );
  }
}