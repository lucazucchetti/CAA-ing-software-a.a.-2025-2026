import 'dart:async';
import 'package:chatbypics/screens/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // 1. Controlla subito lo stato attuale
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      // 2. Se non è verificato, invia la mail (se non è già stata inviata dalla registrazione)
      sendVerificationEmail();

      // 3. Avvia un timer che controlla ogni 3 secondi se l'utente ha cliccato il link
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Bisogna ricaricare l'utente perché Firebase salva lo stato in cache
    await FirebaseAuth.instance.currentUser!.reload();
    
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    // Se è verificato, il timer si ferma
    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SE È VERIFICATO -> Mostra la Home Page
    if (isEmailVerified) {
      return const Homepage(); 
    }

    // SE NON È VERIFICATO -> Mostra la schermata di attesa
    return Scaffold(
      appBar: AppBar(title: const Text("Verifica la tua Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Ti abbiamo inviato una mail di verifica.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Clicca sul link ricevuto per accedere.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Bottone per rinviare la mail
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Invia di nuovo'),
              onPressed: canResendEmail ? sendVerificationEmail : null,
            ),
            
            const SizedBox(height: 8),
            
            // Bottone per annullare e tornare al login
            TextButton(
              child: const Text('Annulla e Torna al Login'),
              onPressed: () => FirebaseAuth.instance.signOut(),
            )
          ],
        ),
      ),
    );
  }
}