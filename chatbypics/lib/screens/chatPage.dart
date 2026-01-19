import 'package:chatbypics/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbypics/services/preferences_service.dart';

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
  final PreferencesService _prefService = PreferencesService();
  bool _isPickerVisible = false; // Controlla se la griglia è aperta
  final List<Map<String, String>> _composingMessage = [];
  double _gridSize = 3.0;
  bool _showLabels = true;
  @override

  final List<Map<String, String>> _samplePictograms = [
    {'url': 'https://cdn-icons-png.flaticon.com/512/1902/1902201.png', 'desc': 'Ciao'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/3076/3076113.png', 'desc': 'Mangiare'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/2444/2444988.png', 'desc': 'Bere'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/711/711239.png', 'desc': 'Felice'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/187/187159.png', 'desc': 'Triste'},
    {'url': 'https://cdn-icons-png.flaticon.com/512/833/833472.png', 'desc': 'Bagno'},
  ];
  @override
  void initState() {
    super.initState();
    _loadPreferences(); // scarica le impostazioni appena entri in chat
  }
  Future<void> _loadPreferences() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Usa il service per ottenere la mappa di preferenze
      var prefs = await _prefService.getUserPreferences(user.uid);

      if (mounted) {
        setState(() {
          // Aggiorna le variabili locali se le chiavi esistono
          if (prefs.containsKey(PreferencesService.keyGridSize)) {
            _gridSize = (prefs[PreferencesService.keyGridSize] as num).toDouble();
          }
          if (prefs.containsKey(PreferencesService.keyShowLabels)) {
            _showLabels = prefs[PreferencesService.keyShowLabels];
          }
        });
      }
    }
  }


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

                // Se non ci sono messaggi, mostra un avviso
                if (messages.isEmpty) {
                  return const Center(child: Text("Inizia a comunicare con i pittogrammi!"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),


          if (_composingMessage.isNotEmpty) _buildComposerPreview(),


          _buildInputArea(),


          if (_isPickerVisible) _buildPersistentPicker(),
        ],
      ),
    );
  }

  // widget ocn messaggio e pittogrammi
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    // Recuperiamo la lista di pittogrammi dal documento
    List<dynamic> pictograms = data['pictograms'] ?? [];

    int itemsPerRow = _gridSize.toInt();
    if (itemsPerRow < 1) itemsPerRow = 1;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightGreen[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Wrap(
          spacing: 8, // Spazio orizzontale
          runSpacing: 8, // Spazio verticale (andata a capo)
          alignment: WrapAlignment.start,
          children: pictograms.map((pic) {
            // Calcolo larghezza per averne max 3 per riga (togliendo i margini)
            double totalWidth = MediaQuery.of(context).size.width * 0.7;
            double itemWidth = (totalWidth / itemsPerRow) - 12;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(pic['imageUrl'], width: itemWidth, height: itemWidth, fit: BoxFit.contain),
                if (_showLabels)
                Text(pic['description'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // barra inferiore chat
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPickerVisible ? Colors.grey : Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(_isPickerVisible ? Icons.keyboard_arrow_down : Icons.grid_view_rounded),
                label: Text(_isPickerVisible ? "Nascondi" : "Aggiungi Simboli"),
                onPressed: () {
                  setState(() {
                    _isPickerVisible = !_isPickerVisible;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //CREDO SI POSSA RIMUOVERE, ERA IL SELETTORE DI PITTOGRAMMI CHE
  //SI CHIUDEVA DOPO L'INSERIMENTO DI OGNI SINGOLO PITTOGRAMMA
  //COSTRINGENDO L'UTENTE A RIAPRIRE IL SELETTORE PER OGNI PITTOGRAMMA
  //DA INSERIRE
  /*
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
                        setState(() {
                          // AGGIUNGI ALLA LISTA INVECE DI INVIARE SUBITO
                          _composingMessage.add({'url': pic['url']!, 'desc': pic['desc']!});
                        });
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
*/

  Widget _buildPersistentPicker() {
    return Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Barra superiore del selettore con tasto chiudi
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Seleziona simboli", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isPickerVisible = false),
                ),
              ],
            ),
          ),
          // Griglia pittogrammi
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _samplePictograms.length,
              itemBuilder: (context, index) {
                final pic = _samplePictograms[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _composingMessage.add({'url': pic['url']!, 'desc': pic['desc']!});
                    });
                    // Nessun Navigator.pop quindi La finestra resta aperta.
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(pic['url']!, height: 40),
                        Text(pic['desc']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ANTEPRIMA MESSAGGIO IN COMPOSIZIONE ---
  Widget _buildComposerPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 110,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _composingMessage.length,
                    itemBuilder: (context, index) {
                      final pic = _composingMessage[index];
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepPurple.shade100),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(pic['url']!, height: 60, width: 60),
                                const SizedBox(height: 4),
                                Text(
                                  pic['desc']!,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Bottone per rimuovere il singolo pittogramma
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => _composingMessage.removeAt(index)),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Tasto INVIO
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FloatingActionButton(
                    mini: false,
                    backgroundColor: Colors.deepPurple,
                    onPressed: _handleSendMessage,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- INVIO MESSAGGIO ---
  void _handleSendMessage() async {
    if (_composingMessage.isEmpty) return;

    // Prepariamo i dati per il DB
    List<Map<String, String>> messageData = _composingMessage.map((p) => {
      'imageUrl': p['url']!,
      'description': p['desc']!,
    }).toList();

    // Invio tramite il servizio
    await ChatService().sendPictogramMessage(
      chatID: widget.chatID,
      senderID: _auth.currentUser!.uid,
      pictograms: messageData,
    );

    // Pulizia della barra
    setState(() {
      _composingMessage.clear();
      _isPickerVisible = false; // Per chiudere dopo l'invio
    });
  }
}