import 'package:chatbypics/screens/suggerimenti/Suggerimenti.dart';
import 'package:chatbypics/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chatbypics/services/preferences_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:chatbypics/services/pictogram_service.dart';
import 'package:flutter/services.dart';
import 'package:chatbypics/services/GestoreJson.dart';


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
  final FlutterTts flutterTts = FlutterTts();
  double _ttsSpeed = 0.5; // Velocità normale (0.0 a 1.0)
  bool _autoReadMessages = true;
  @override


  //bool _isPickerVisible = false; //griglia chiusa di default
  //final List<Map<String, String>> _composingMessage = [];

  // STATO PER LA RICERCA / CATEGORIE
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _currentSymbols = [
  ]; // I simboli visualizzati al momento
  bool _isLoading = false;
  bool _showingCategories = true; // Se true mostra le cartelle, se false i simboli
  String _currentCategoryName = ""; // Titolo della categoria attuale
  List<Map<String, String>> _visibleCategories = [];

  //Lista delle categorie con la relativa immagine di copertina
  final List<Map<String, String>> _categories = [
    {
      'name': 'Persone',
      'term': 'persone',
      'img': 'https://static.arasaac.org/pictograms/2649/2649_300.png'
    },
    {
      'name': 'Azioni',
      'term': 'verbi',
      'img': 'https://static.arasaac.org/pictograms/6873/6873_300.png'
    },
    {
      'name': 'Emozioni',
      'term': 'emozioni',
      'img': 'https://static.arasaac.org/pictograms/8582/8582_300.png'
    },
    {
      'name': 'Alimentazione',
      'term': 'alimenti',
      'img': 'https://static.arasaac.org/pictograms/2534/2534_300.png'
    },
    {
      'name': 'Luoghi',
      'term': 'luoghi',
      'img': 'https://static.arasaac.org/pictograms/32598/32598_300.png'
    },
    {
      'name': 'Scuola',
      'term': 'scuola',
      'img': 'https://static.arasaac.org/pictograms/15515/15515_300.png'
    },
    {
      'name': 'Corpo',
      'term': 'corpo umano',
      'img': 'https://static.arasaac.org/pictograms/6473/6473_nocolor_500.png'
    },
    {
      'name': 'Vestiti',
      'term': 'abbigliamento',
      'img': 'https://static.arasaac.org/pictograms/2613/2613_300.png'
    },
    {
      'name': 'Saluti',
      'term': 'saluti sociali',
      'img': 'https://static.arasaac.org/pictograms/2347/2347_300.png'
    },
    {
      'name': 'Aggettivi',
      'term': 'aggettivi',
      'img': 'https://static.arasaac.org/pictograms/32584/32584_300.png'
    },
  ];
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initTts();// scarica le impostazioni appena entri in chat
    // Carica i permessi appena entri in chat
    _loadUserPermissions();
    //Leggo i suggerimenti
    GestoreJson().leggiJson();
  }
  void _initTts() async {
    await flutterTts.setLanguage("it-IT"); // Imposta Italiano
    await flutterTts.setPitch(1.0);
    var isLanguageAvailable = await flutterTts.isLanguageAvailable("it-IT");
    if (!isLanguageAvailable) {
      print("Errore: La lingua italiana non è installata sul dispositivo");
    }
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
          if (prefs.containsKey(PreferencesService.keyAutoRead)) {
            _autoReadMessages = prefs[PreferencesService.keyAutoRead];
          }
          if (prefs.containsKey(PreferencesService.keyShowLabels)) {
            _showLabels = prefs[PreferencesService.keyShowLabels];
          }
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

/*
  @override
  void initState() {
    super.initState();
    // Carica i permessi appena entri in chat
    _loadUserPermissions();
    //Leggo i suggerimenti
    GestoreJson().leggiJson();
  }
  */

  void _aggiungiPittogramma(String newURL, String desc) {
    if (_composingMessage.isNotEmpty) {
      String oldURL = _composingMessage.last['url']!;
      String oldId = oldURL
          .split('/')
          .last;

      GestoreJson().aggiornamentoSuggerimenti(oldId, newURL);
    }

    setState(() {
      _composingMessage.add({'url': newURL, 'desc': desc});
    });
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
                  return const Center(
                      child: Text("Inizia a comunicare con i pittogrammi!"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 20),
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),


          if (_composingMessage.isNotEmpty) _buildComposerPreview(),
          _buildInputArea(),
          //6. AREA SUGGERIMENTI
          if (_isPickerVisible) _buildSuggerimenti(),
          // 4. Selettore Pittogrammi Persistente
          if (_isPickerVisible) _buildPersistentPicker(),
        ],
      ),
    );
  }


  // widget ocn messaggio e pittogrammi

  // --- LOGICA DI NAVIGAZIONE E RICERCA ---

  // 1. Quando si clicca una categoria
  void _selectCategory(String name, String term) async {
    setState(() {
      _isLoading = true;
      _showingCategories = false; // Nascondi cartelle, mostra simboli
      _currentCategoryName = name;
      _searchController.clear(); // Pulisce la ricerca testuale se c'era
    });

    // Cerca su ARASAAC usando il termine della categoria
    try {
      var results = await PictogramService().searchPictograms(term);
      setState(() {
        _currentSymbols = results;
        _isLoading = false;
      });
    } catch (e) {
      print("Errore: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. Quando si cerca col testo
  void _performTextSearch() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showingCategories = false; // Passa alla vista simboli
      _currentCategoryName = "Ricerca: $query";
    });

    try {
      var results = await PictogramService().searchPictograms(query);
      setState(() {
        _currentSymbols = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 3. Tornare alla vista Categorie
  void _backToCategories() {
    setState(() {
      _showingCategories = true;
      _currentSymbols = [];
      _searchController.clear();
      _currentCategoryName = "";
      // Chiudi la tastiera del telefono
      FocusScope.of(context).unfocus();
    });
  }

  // --- UI DEL SELETTORE ---
  Widget _buildPersistentPicker() {
    return Container(
      height: 350, // Altezza fissa del pannello
      color: Colors.white,
      child: Column(
        children: [
          // A. BARRA SUPERIORE (Ricerca + Navigazione)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // Tasto Indietro (visibile solo se non siamo nelle categorie)
                if (!_showingCategories)
                  IconButton(
                    icon: const Icon(
                        Icons.arrow_back, color: Colors.deepPurple),
                    onPressed: _backToCategories,
                  ),

                // Barra di ricerca
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cerca simbolo...",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, size: 20),
                    ),
                    onSubmitted: (_) => _performTextSearch(),
                  ),
                ),

                // Tasto Cerca (se si scrive a mano)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.deepPurple),
                  onPressed: _performTextSearch,
                ),

                // Tasto Chiudi Tutto
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => setState(() => _isPickerVisible = false),
                ),
              ],
            ),
          ),

          // B. TITOLO CATEGORIA CORRENTE (Opzionale)
          if (!_showingCategories && !_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              color: Colors.deepPurple.shade50,
              child: Text(
                _currentCategoryName,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900),
              ),
            ),

          // C. CONTENUTO PRINCIPALE (Grid Categorie O Grid Simboli)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showingCategories
                ? _buildCategoriesGrid() // Mostra le cartelle
                : _buildSymbolsGrid(), // Mostra i pittogrammi
          ),
        ],
      ),
    );
  }

  // --- VISTA 1: GRIGLIA DELLE CATEGORIE ---
  // --- VISTA 1: GRIGLIA DELLE CATEGORIE FILTRATA ---
  Widget _buildCategoriesGrid() {
    // Se la lista è vuota, potrebbe essere che sta ancora caricando o che l'utente non ha permessi.
    // Possiamo mostrare un caricamento se _visibleCategories è vuota ma _categories no.
    if (_visibleCategories.isEmpty) {
      // Piccolo controllo: se l'utente ha davvero 0 permessi mostriamo "Nessuna categoria"
      // Per ora assumiamo sia caricamento iniziale
      // Se vuoi gestire il caso "0 permessi", servirebbe una variabile bool _permissionsLoaded
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      // USA LA LISTA FILTRATA
      itemCount: _visibleCategories.length,
      itemBuilder: (context, index) {
        // PRENDI L'ELEMENTO DALLA LISTA FILTRATA
        final cat = _visibleCategories[index];

        return GestureDetector(
          onTap: () => _selectCategory(cat['name']!, cat['term']!),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple.shade100, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  cat['img']!,
                  height: 50,
                  loadingBuilder: (ctx, child, p) =>
                  p == null
                      ? child
                      : const SizedBox(height: 50),
                  errorBuilder: (ctx, err, st) =>
                  const Icon(Icons.folder, size: 50, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- VISTA 2: GRIGLIA DEI SIMBOLI (RISULTATI) ---
  Widget _buildSymbolsGrid() {
    if (_currentSymbols.isEmpty) {
      return const Center(child: Text("Nessun simbolo trovato."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 colonne per i simboli (più piccoli)
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _currentSymbols.length,
      itemBuilder: (context, index) {
        final pic = _currentSymbols[index];
        return GestureDetector(
          onTap: () {
            _aggiungiPittogramma(pic['url']!, pic['desc']!);
            // NON chiudiamo il pannello, così può aggiungerne altri
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(pic['url']!, fit: BoxFit.contain),
                  ),
                ),
                Text(
                  pic['desc']!,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET MESSAGGIO (CON GRIGLIA DI PITTOGRAMMI) ---

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    // Recuperiamo la lista di pittogrammi dal documento
    List<dynamic> pictograms = data['pictograms'] ?? [];

    String fullSentence = pictograms.map((p) => p['description'] ?? '').join(" ");
    int itemsPerRow = _gridSize.toInt();
    if (itemsPerRow < 1) itemsPerRow = 1;
    return GestureDetector(
      onTap: () {
        _speak(fullSentence); // Quando tocchi, legge la frase
      },
      child: Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery
            .of(context)
            .size
            .width * 0.8),
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
            /*  
            double itemWidth = (MediaQuery
                .of(context)
                .size
                .width * 0.7) / 3 - 12;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(pic['imageUrl'], width: itemWidth,
                    height: itemWidth,
                    fit: BoxFit.contain),
                Text(pic['description'] ?? '', style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),

              ],
*/
            );
          }).toList(),
        ),
      ),
      )
    );
  }

  // barra inferiore chat
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPickerVisible ? Colors.grey.shade400 : Colors
                  .deepPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              // MODIFICA QUI: Aumentato a 30 per renderlo completamente arrotondato
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(
                _isPickerVisible ? Icons.keyboard_arrow_down : Icons
                    .grid_view_rounded,
                size: 20
            ),
            label: Text(
                _isPickerVisible ? "Nascondi" : "Apri Simboli",
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)
            ),
            onPressed: () {
              setState(() {
                _isPickerVisible = !_isPickerVisible;
                if (!_isPickerVisible) FocusScope.of(context).unfocus();
              });
            },
          ),
        ),
      ),
    );
  }

  //BUILDER PER I SUGGERIMENTI
  Widget _buildSuggerimenti() {
    if (_composingMessage.isEmpty) return SizedBox.shrink();

    String ultimoURL = _composingMessage.last['url']!;
    String ultimoId = ultimoURL
        .split('/')
        .last;
    List<dynamic> suggerimenti = GestoreJson().suggerimentiDiImmagine(ultimoId);
    List<String> listaUrl = List<String>.from(suggerimenti);

    //nascondiamo la barra suggerunebtu se non ci sono
    if (suggerimenti.isEmpty) return SizedBox.shrink();

    return Suggerimenti(
      dati: listaUrl,
      selezionato: (urlCliccato) {
        _aggiungiPittogramma(urlCliccato, "");
      },
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
  /*
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
  */

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
                              border: Border.all(
                                  color: Colors.deepPurple.shade100),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                    pic['url']!, height: 60, width: 60),
                                const SizedBox(height: 4),
                                Text(
                                  pic['desc']!,
                                  style: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.bold),
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
                              onTap: () =>
                                  setState(() =>
                                  _composingMessage.removeAt(index)),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.close, size: 18, color: Colors.white),
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
    List<Map<String, String>> messageData = _composingMessage.map((p) =>
    {
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

  Future<void> _loadUserPermissions() async {
    try {
      // 1. Leggi il documento dell'utente attuale
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists && mounted) {
        // 2. Prendi la lista dei permessi (se esiste)
        // Se il campo 'enabledCategories' è null (utenti vecchi), mostriamo tutto per sicurezza.
        List<dynamic>? allowedNames = userDoc.data()?['enabledCategories'];

        setState(() {
          if (allowedNames == null) {
            // Caso: Il campo non esiste -> Mostra TUTTO
            _visibleCategories = List.from(_categories);
          } else {
            // Caso: Il campo esiste -> Filtra solo quelli presenti nella lista
            _visibleCategories = _categories.where((cat) {
              return allowedNames.contains(cat['name']);
            }).toList();
          }
        });
      }
    } catch (e) {
      print("Errore caricamento permessi: $e");
      // In caso di errore, nel dubbio mostriamo tutto
      setState(() => _visibleCategories = List.from(_categories));
    }
  }
}

