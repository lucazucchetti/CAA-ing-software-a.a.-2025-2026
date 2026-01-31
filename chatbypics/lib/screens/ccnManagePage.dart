import 'package:chatbypics/screens/chatList/RuoloListaTerzi.dart';
import 'package:chatbypics/screens/editCcnPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbypics/screens/addCcnPage.dart';
import 'package:chatbypics/screens/chatListPage.dart';

class CCNManagePage extends StatefulWidget {
  const CCNManagePage({super.key});

  @override
  State<CCNManagePage> createState() => _CCNManagePageState();
}

class _CCNManagePageState extends State<CCNManagePage> {
  // Recuperiamo l'ID del Tutor loggato per filtrare i suoi utenti
  final String currentTutorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Utenti CCN"),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      
      // 1. STREAMBUILDER: Ascolta Firebase in tempo reale
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('tutorId', isEqualTo: currentTutorId) // FILTRO FONDAMENTALE
            .where('ruolo', isEqualTo: 'CCN') // Sicurezza extra
            .snapshots(),
        builder: (context, snapshot) {
          
          // A. Caricamento in corso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. Nessun dato trovato
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text("Nessun utente CCN associato.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text("Premi + per crearne uno.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          var users = snapshot.data!.docs;

          // C. Lista Utenti Veri
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              // Estraiamo i dati dal documento Firebase
              var userData = users[index].data() as Map<String, dynamic>;
              String docId = users[index].id; // L'ID del documento per poterlo eliminare/modificare
              
              String nome = userData['Nome'] ?? "Senza Nome";
              String cognome = userData['Cognome'] ?? "";
              String fullName = "$nome $cognome";
              bool isActive = userData['profiloAttivo'] ?? true;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // AVATAR
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 25,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  // NOME
                  title: Text(
                    fullName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  
                  // STATO
                  subtitle: Text(
                    isActive ? "Profilo attivo" : "Disattivato",
                    style: TextStyle(color: isActive ? Colors.green : Colors.red),
                  ),

                  // AZIONI
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modifica
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // APRI LA PAGINA DI MODIFICA
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCcnPage(
                              userId: docId, // Passiamo l'ID
                              userData: userData, // Passiamo i dati attuali (nome, categorie vecchie, ecc)
                              ),
                            ),
                          );
                        },
                      ),
                      // Elimina (Funzionante)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                           _showDeleteDialog(docId, fullName);
                        },
                      ),
                      ///ICONA PER ACCESSO CHAT CCN
                      IconButton(
                        icon: const Icon(Icons.visibility_sharp, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatListPage(osservatore: docId, nomeCCN: fullName,ruolo: RuoloListaTerzi()),
                            ),
                          );
                          },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // BOTTONE PER AGGIUNGERE NUOVO CCN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCcnPage()),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Nuovo CCN", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Finestra di dialogo per confermare l'eliminazione (estetica)
  void _showDeleteDialog(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminare utente?"),
        content: Text("Sei sicuro di voler eliminare l'account di $name?\nQuesta azione non può essere annullata."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Chiude senza fare nulla
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () async {
              // 1. ELIMINAZIONE REALE DA FIREBASE
              await FirebaseFirestore.instance.collection('users').doc(docId).delete();
              
              if (mounted) {
                Navigator.pop(context); // 2. Chiude il dialogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name eliminato correttamente."))
                );
              }
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}