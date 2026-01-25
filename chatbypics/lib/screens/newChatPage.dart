import 'package:chatbypics/services/chat_service.dart';
import 'package:chatbypics/screens/chatPage.dart'; // La pagina della chat singola
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewChatPage extends StatelessWidget {
  const NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Seleziona Utente")),
      body: StreamBuilder<QuerySnapshot>(
        // QUI: Recupera la lista degli utenti. 
        // In futuro potrai filtrare per mostrare solo gli "amici" o i contatti salvati.
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: currentUid) // Esclude se stesso
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              var userData = user.data() as Map<String, dynamic>;
              String name = "${userData['Nome']} ${userData['Cognome']}";

              return ListTile(
                leading: CircleAvatar(child: Text(name[0])),
                title: Text(name),
                subtitle: Text(userData['ruolo'] ?? ''),
                onTap: () async {
                  // LOGICA AL CLICK
                  try {
                    // Mostra caricamento
                    showDialog(
                      context: context, 
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator())
                    );

                    // 1. Chiamo il servizio che gestisce la logica "Crea o Recupera"
                    String chatId = await ChatService().createOrGetChat(user.id);

                    // Chiudo il caricamento
                    if (context.mounted) Navigator.pop(context);

                    // 2. Vado alla pagina della chat
                    if (context.mounted) {
                      // Sostituisco la pagina attuale (pushReplacement) così se torna indietro va alla Home
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(chatID: chatId, chatName: name, scrittura: true,chatOwnerID: currentUid),
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context); // Chiudi caricamento in caso di errore
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}