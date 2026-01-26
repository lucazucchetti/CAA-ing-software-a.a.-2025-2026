import 'package:chatbypics/screens/chatPage.dart';
import 'package:chatbypics/screens/newChatPage.dart'; // Assicurati di aver creato questo file (vedi sotto)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {

  final String? osservatore;

  const ChatListPage({
    super.key,
    this.osservatore,
  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late String currentUserId;
  late bool scrittura;

  //final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  bool _isSearching = false; // Se stiamo cercando o no
  final TextEditingController _searchController = TextEditingController();
  String _searchText = ""; // Il testo effettivo che stiamo cercando

  @override
  void initState() {
    super.initState();
    currentUserId = widget.osservatore ?? FirebaseAuth.instance.currentUser!.uid;
    widget.osservatore==null ? scrittura=true: scrittura=false;

    // Ascoltiamo cosa scrive l'utente in tempo reale
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // SE STO CERCANDO -> MOSTRA TEXTFIELD, ALTRIMENTI -> MOSTRA TITOLO
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true, // Apre la tastiera subito
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: "Cerca nome...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              )
            : const Text("Le tue Chat", style: TextStyle(color: Colors.black)),
            
        backgroundColor: Colors.deepPurple.shade100,
        iconTheme: const IconThemeData(color: Colors.black), // Icone nere per contrasto
        
        actions: [
          // GESTIONE DEL TASTO (LENTE o X)
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  // Se stavo cercando e clicco X -> Chiudo e resetto
                  _isSearching = false;
                  _searchController.clear();
                  _searchText = "";
                } else {
                  // Se clicco la lente -> Apro la ricerca
                  _isSearching = true;
                }
              });
            },
          ),
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
                  return const SizedBox(); 
                }

                var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                String friendName = userData != null 
                  ? "${userData['Nome']} ${userData['Cognome']}" 
                  : "Utente sconosciuto";

                // --- LOGICA DI FILTRO ---
                // Se sto cercando E il nome non contiene quello che ho scritto...
                if (_isSearching && _searchText.isNotEmpty) {
                  if (!friendName.toLowerCase().contains(_searchText)) {
                    // ... Restituisco un widget invisibile (nascondo la riga)
                    return const SizedBox.shrink();
                  }
                }
                // -----------------------

                // Dati dell'ultimo messaggio... (tuo codice precedente)
                Map<String, dynamic> lastMsg = chatData['lastMessageData'] ?? {};
                String lastMsgText = lastMsg['description'] ?? "Foto inviata";
              
                return ListTile(
                  // ... (tutto il resto del tuo ListTile rimane uguale)
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade200,
                    child: Text(friendName.isNotEmpty ? friendName[0].toUpperCase() : "?", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(friendName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    lastMsgText, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(chatID: chatId, chatName: friendName, scrittura: scrittura, chatOwnerID: currentUserId),
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
      floatingActionButton: scrittura ? FloatingActionButton(
        onPressed: () {
          // Naviga alla pagina di selezione contatti
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NewChatPage()));
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.person_add, color: Colors.white),
      ): null,
    );
  }
}