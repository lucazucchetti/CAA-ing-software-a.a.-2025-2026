import 'package:chatbypics/screens/ccnManagePage.dart';
import 'package:chatbypics/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Variabile per memorizzare se l'utente è un Tutor
  bool isTutor = false;
  bool isLoading = true; // Per mostrare un caricamento mentre controlliamo il ruolo

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // Funzione che scarica il ruolo da Firestore
  Future<void> _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          // Controlliamo il campo 'ruolo' che abbiamo salvato durante la registrazione
          // Assicurati che su Firestore il campo si chiami esattamente 'ruolo'
          String role = doc.get('ruolo') ?? ''; 
          
          if (mounted) {
            setState(() {
              isTutor = (role == 'Tutor');
              isLoading = false;
            });
          }
        }
      } catch (e) {
        print("Errore nel recupero del ruolo: $e");
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) // Mostra rotella se sta caricando
          : Column(
              children: [
                // 1. SEZIONE IMPOSTAZIONI GENERALI
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.deepPurple),
                  title: const Text("Impostazioni Applicazione"),
                  subtitle: const Text("Lingua, notifiche, aspetto"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Qui navigherai alla pagina di dettaglio impostazioni
                    // Navigator.push(...);
                  },
                ),
                
                const Divider(), // Linea divisoria

                // 2. SEZIONE REGISTRA CCN (Visibile SOLO se isTutor è true)
                if (isTutor) 
                  ListTile(
                    leading: const Icon(Icons.supervised_user_circle, color: Colors.blue),
                    title: const Text("Gestione CCN"), // Puoi rinominarlo così
                    subtitle: const Text("Aggiungi o modifica i tuoi utenti assistiti"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CCNManagePage()
                        ),
      );
    },
  ),

                if (isTutor) const Divider(),

                // SPAZIO VUOTO per spingere il logout in basso
                const Spacer(),

                // 3. BOTTONE LOGOUT
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity, // Occupa tutta la larghezza
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100, // Sfondo rosso chiaro
                        foregroundColor: Colors.red, // Testo/Icona rossa
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Esci dall'account", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        // Esegue il logout
                        await Auth().signOut();
                        // Chiude la pagina delle impostazioni (torna indietro)
                        // Poiché Auth cambia lo stato, main.dart reindirizzerà automaticamente al Login
                        if (mounted){
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        } 
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20), // Un po' di margine dal fondo
              ],
            ),
    );
  }
}