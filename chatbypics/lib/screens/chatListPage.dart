import 'package:chatbypics/screens/chatList/RuoloLista.dart';
import 'package:chatbypics/screens/chatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {

  ///[osservato] è l'id di chi è osservata la chat(quindi il CCN)
  ///può essere null, se è null allora la lista è dell'utente che ha acceduto alla lista
  ///
  final String? osservato;
  ///[nomeCCN] nome del CCN del quale si stà vedendo la lista, può essere null
  ///in questo caso allora è perchè non si sta vedendo la lista del ccn ma la propia
  final String? nomeCCN;
  ///[ruolo] RuoloLista è il ruolo che si assume in base a se si sta osservando una lista chat del
  ///ccn oppure la propia, pattern player role
  ///
  final RuoloLista ruolo;

  const ChatListPage({
    super.key,
    this.osservato,
    this.nomeCCN,
    required this.ruolo,

  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  ///[currentUserId] id di chi ha fatto l'accesso
  ///
  late String currentUserId;
///[_isSearching] Indica se stiamo cercando qualcuno
  bool _isSearching = false;
  ///[TextEditingController] verifica se stiamo scrivendo/ editando il messaggio
  final TextEditingController _searchController = TextEditingController();
  ///[_searchController] Stringa che contine il messaggio finale
  String _searchText = "";

  ///[initState] Ascoltiamo da Firebase in tempo reale cosa scrive l'utente
  @override
  void initState() {
    super.initState();


    currentUserId = widget.osservato ?? FirebaseAuth.instance.currentUser!.uid;
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
  ///[build] Costruisce tutta la schermata facendo vedere tutte le chat amiche
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            :  (widget.ruolo.getTestoIntestazione(widget.nomeCCN)),

        ///colore in base al ruolo
        backgroundColor: widget.ruolo.getColoreBackground(),
        iconTheme: const IconThemeData(color: Colors.black), // Icone nere per contrasto
        // Se clicco la X chiude, se schiaccio la lente inizia la ricerca
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchText = "";
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      
      ///[Streambuilder] Ascolta le chat, Gestisce gli stati di caricamento e errori
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('visibleTo', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Errore: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var chatDocs = snapshot.data!.docs;

          if (chatDocs.isEmpty) {
            return const Center(child: Text("Nessuna chat attiva.\nPremi + per iniziarne una!", textAlign: TextAlign.center));
          }

          // Return della Lista delle chat, facendo visualizzare solo gli amici
          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              var chatData = chatDocs[index].data() as Map<String, dynamic>;
              String chatId = chatDocs[index].id;

              List<dynamic> participants = chatData['participants'];
              String friendUid = participants.firstWhere(
                (id) => id != currentUserId, 
                orElse: () => participants.first // Fallback se sto parlando con me stesso
              );

              ///[FutureBuilder<DocumentSnapshot>]
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

                // Cerco i nomi se non li trovo, nascondo la riga e vado avanti
                if (_isSearching && _searchText.isNotEmpty) {
                  if (!friendName.toLowerCase().contains(_searchText)) {
                    return const SizedBox.shrink();
                  }
                }


                // Dati dell'ultimo messaggio
                Map<String, dynamic> lastMsg = chatData['lastMessageData'] ?? {};
                String lastMsgText = lastMsg['description'] ?? "Foto inviata";
              
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: widget.ruolo.getColoreIcone(),
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
                      builder: (_) => ChatPage(chatID: chatId, chatName: friendName, ruolo: widget.ruolo.getRuoloChatPage(), chatOwnerID: currentUserId),

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

      ///[floatingActionButton] bottone per generare un altra chat
      floatingActionButton: widget.ruolo.buildBottone(context),
    );
  }
}