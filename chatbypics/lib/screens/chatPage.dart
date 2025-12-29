import 'package:chatbypics/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatID;
  final String chatName;

  const ChatPage({
    super.key,
    required this.chatID,
    required this.chatName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Esempi di pittogrammi (in futuro arriveranno dal DB)
  final List<Map<String, String>> _samplePictograms = [
    {'url': 'https://cdn-icons-png.flaticon.com/512/1902/1902201.png', 'desc': 'Ciao'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/3076/3076113.png', 'desc': 'Mangiare'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/2444/2444988.png', 'desc': 'Bere'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/711/711239.png', 'desc': 'Felice'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/187/187159.png', 'desc': 'Triste'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/833/833472.png', 'desc': 'Bagno'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // Sfondo neutro
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Column(
        children: [
          // 1. LISTA DEI MESSAGGI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatID)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                // Se non ci sono messaggi, mostra un avviso amichevole
                if (messages.isEmpty) {
                  return const Center(child: Text("Inizia a comunicare con i pittogrammi!"));
                }

                return ListView.builder(
                  reverse: true, // I messaggi partono dal basso
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),

          // 2. BARRA DI INPUT (Solo Pittogrammi)
          _buildInputArea(),
        ],
      ),
    );
  }

  // --- WIDGET MESSAGGIO SINGOLO ---
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightGreen[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            // Immagine
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                data['imageUrl'],
                height: 120, // Un po' più grande per vederlo bene
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 5),
            // Testo sotto (Accessibilità)
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // --- BARRA INFERIORE (Solo tasto Pittogrammi) ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.grid_view_rounded, size: 28),
            label: const Text("Apri Pittogrammi", style: TextStyle(fontSize: 18)),
            onPressed: _showPictogramSelector,
          ),
        ),
      ),
    );
  }

  // --- LOGICA SELEZIONE PITTOGRAMMI ---
  void _showPictogramSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            const Text("Scegli un concetto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _samplePictograms.length,
                itemBuilder: (context, index) {
                  final pic = _samplePictograms[index];
                  return GestureDetector(
                    onTap: () {
                      _sendMessage(pic['url']!, pic['desc']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(pic['url']!, height: 60),
                          Text(pic['desc']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- INVIO MESSAGGIO ---
  void _sendMessage(String imageUrl, String description) {
    ChatService().sendPictogram(
      chatID: widget.chatID,
      senderID: _auth.currentUser!.uid,
      imageUrl: imageUrl,
      description: description,
    );
  }
}