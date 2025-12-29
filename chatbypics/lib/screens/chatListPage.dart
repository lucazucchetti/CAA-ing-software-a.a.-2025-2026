import 'package:chatbypics/screens/chatPage.dart';
import 'package:chatbypics/screens/newChatPage.dart'; // Assicurati di aver creato questo file (vedi sotto)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Le tue Chat"),
        backgroundColor: Colors.deepPurple.shade100,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      
      // 1. STREAMBUILDER: Ascolta le chat di Firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('visibleTo', arrayContains: currentUserId) // Mostra solo se sono tra i "visibili"
            .orderBy('lastMessageTime', descending: true) // Le più recenti in alto
            .snapshots(),
        builder: (context, snapshot) {
          // Gestione stati di caricamento ed errore
          if (snapshot.hasError) return Center(child: Text("Errore: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var chatDocs = snapshot.data!.docs;

          if (chatDocs.isEmpty) {
            return const Center(child: Text("Nessuna chat attiva.\nPremi + per iniziarne una!", textAlign: TextAlign.center));
          }

          // 2. LISTA DELLE CHAT
          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              var chatData = chatDocs[index].data() as Map<String, dynamic>;
              String chatId = chatDocs[index].id;
              
              // Chi è l'altro partecipante?
              // Prendo la lista dei partecipanti e rimuovo il mio ID. Quello che resta è l'amico.
              List<dynamic> participants = chatData['participants'];
              String friendUid = participants.firstWhere(
                (id) => id != currentUserId, 
                orElse: () => participants.first // Fallback se sto parlando con me stesso
              );

              // 3. RECUPERO IL NOME DELL'AMICO (FutureBuilder)
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendUid).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox(); // In attesa dei dati mostro nulla o uno scheletro
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  String friendName = userData != null 
                      ? "${userData['Nome']} ${userData['Cognome']}" 
                      : "Utente sconosciuto";

                  // Dati dell'ultimo messaggio per l'anteprima
                  Map<String, dynamic> lastMsg = chatData['lastMessageData'] ?? {};
                  String lastMsgText = lastMsg['description'] ?? "Foto inviata";
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade200,
                      child: Text(friendName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(friendName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      lastMsgText, 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    onTap: () {
                      // APRE LA CHAT VERA
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(chatID: chatId, chatName: friendName),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),

      // BOTTONE NUOVA CHAT
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviga alla pagina di selezione contatti
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NewChatPage()));
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}