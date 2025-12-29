import 'package:flutter/material.dart';

/*
Classe che gestisce la pagina che contiene tutte le chat
*/
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatByPics"),
        actions: [
          //IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: 20, // Creiamo 20 chat finte per testare lo scroll
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
            ),
            title: Text("Utente $index"),
            subtitle: const Text("Ciao! Come stai?"),
            trailing: const Text("10:30"),
            onTap: () {
              // Apri la chat singola
            },
          );
        },
      ),
      // Bottone galleggiante per nuova chat (come su WhatsApp)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}