import 'package:chatbypics/screens/chat/CategoriePittogrammi.dart';
import 'package:chatbypics/screens/chat/ComposizioneMessaggio/ComposizioneMessaggio.dart';
import 'package:chatbypics/screens/chat/Gestori/GestorePermessi.dart';
import 'package:chatbypics/screens/chat/EliminazioneMessaggio/BannerEliminazione.dart';
import 'package:chatbypics/screens/chat/GrigliaDeiSimboli/GrigliaDeiSimboli.dart';
import 'package:chatbypics/screens/chat/InputArea/InputArea.dart';
import 'package:chatbypics/screens/chat/suggerimenti/Suggerimenti.dart';
import 'package:chatbypics/services/SintesiVocale.dart';
import 'package:chatbypics/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chatbypics/services/pictogram_service.dart';
import 'package:flutter/services.dart';
import 'package:chatbypics/services/GestoreJson.dart';

import 'chat/Gestori/GestoreRichiestePreferenze.dart';
import 'chat/GrigliaCategorie/GrigliaCategorie.dart';
import 'chat/PreferenzeChat.dart';


///Classe [ChatPage] è la classe che gestisce le singole chat
///necessita come parametri la [chatId] e il [chatName] per funzionare
///
class ChatPage extends StatefulWidget {

  ///[chatID] è l'id della singola chat da mostrare
  ///passato come parametro nel metodo costruttore
  ///
  final String chatID;
  ///[chatName] è il nome della chat da mostrare
  ///pasato come parametro nel metodo costruttore
  ///
  final String chatName;


  const ChatPage({
    super.key,
    required this.chatID,
    required this.chatName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();


}

///Classe [_ChatPageState] rappresenta lo stato della pagina chat
///
class _ChatPageState extends State<ChatPage> {


  ///[_auth] variabile che rappresenta l'istanza del DB utilizzato come Singleton
  ///usato incorretto
  ///
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ///[_composingMessage] Lista di pittogrammi del messaggio da inviare
  ///
  final List<Map<String, String>> _composingMessage = [];

  ///[_isPickerVisible] rappresenta se la barra messaggi è visibile o no
  ///
  bool _isPickerVisible = false;

  ///[_showLabels] da fare
  ///
  bool _showLabels = true;

  ///non usato
  bool _autoReadMessages = true;

  //bool _isPickerVisible = false; //griglia chiusa di default
  //final List<Map<String, String>> _composingMessage = [];

  ///stato per ricerca categorie???
  ///
  final TextEditingController _searchController = TextEditingController();

  ///[_currentSymbols]Lista di simboli che devono essere inviati al momento
  ///
  List<Map<String, String>> _currentSymbols = [
  ];

  ///[_isLoading]
  ///
  bool _isLoading = false;

  ///[_showingCategories] se true mostra le cartelle se false i simboli
  ///
  bool _showingCategories = true;

  ///[_currentCategoryName]Titolo della categoria usata ora
  ///
  String _currentCategoryName = "";

  ///[_gestorePermessi] Classe che permette la ricerca delle categorie permesse per l'utente
  ///
  final GestorePermessi _gestorePermessi=GestorePermessi();

  ///[_visibleCategories] Categorie visibili all'utente
  ///
  List<Map<String, String>> _visibleCategories = [];

  ///[_gestorePreferenze] oggetto che permette di interfacciarsi al database per impostare
  ///le preferenze di un determinato utente
  ///
  final GestoreRichiestePreferenze _gestorePreferenze=GestoreRichiestePreferenze();

  ///[_impostazioni] oggetto che contiene le preferenze della chat del determinato utente
  ///
  PreferenzeChat _impostazioni=PreferenzeChat();


  ///[initState] Stato iniziale eseguito una volta all'apertura della chat
  ///
  @override
  void initState() {

    super.initState();

    ///scarico le preferenze dela chat
    ///
    _caricaPreferenze();

    ///scarico le impostazioni della sintesi vocale
    ///
    SintesiVocale();

    ///carico i permessi
    ///
    _caricaPermessi();

    ///leggo il file json, carico i dati nella struttura dati
    ///
    GestoreJson().leggiJson();
  }

  ///[_aggiungiPittogramma] funzione che permette di aggiornare i suggerimenti
  ///nel file json quando si inserisce un nuovo pittogramma e aggiunge alla barra
  ///di composizione del messaggio il nuovo pittogramma.
  ///
  ///1a parte:
  /// Controlla che [_composingMessage] non sia vuoto(quindi è presente un
  /// pittogramma passato), recupera il pittogramma passato e ricava l'id
  /// (parte finale dell'url) poi usa il GestoreJson per aggiornare i suggerimenti
  /// dell'id con il newURL passato come parametro.
  ///
  ///2a parte:
  /// Aggiorna aggiorna lo stato della barra di composizione messaggi
  /// aggiungendo il nuovo pittogramma.
  ///
  /// __parametri String newURL: url del pittogramma nuovo inserito, String desc, descrizione del pittogramma__
  ///
  void _aggiungiPittogramma(String newURL, String desc) {
    if (_composingMessage.isNotEmpty) {
      String oldURL = _composingMessage.last['url']!;
      String oldId = oldURL.split('/').last;

      GestoreJson().aggiornamentoSuggerimenti(oldId, newURL);
    }

    setState(() {
      _composingMessage.add({'url': newURL, 'desc': desc});
    });
  }

  ///[_eliminaMessaggio] funzione privata asincrona che permette l'eliminazione del
  ///messaggio quando viene selezionato se il messaggio è stato inviato al massimo
  ///30s fa
  ///
  /// richiede [cont] che è il context, [isMe] booleano che rappresenta se
  /// il messaggio è dell'utente che ha selezionato oppure no
  /// [messaggioId] stringa che è l'id del messaggio da eliminare
  /// [timestampMessaggio] è il Timestamp di invio del messaggio
  ///
  Future<void> _eliminaMessaggio(BuildContext cont, bool isMe, String messaggioId, Timestamp? timestampMessaggio) async
  {
    ///se il messaggio non è mio allora esco
    if(!isMe) return;

    DateTime dataInvio = timestampMessaggio?.toDate() ?? DateTime.now();
    DateTime dataDomanda=DateTime.now();

    ///se il messaggio è troppo vecchio allora dico all'utente che non si può eliminare
    if(dataDomanda.difference(dataInvio).inSeconds>30)
    {
      if (cont.mounted) {
        ScaffoldMessenger.of(cont).showSnackBar(
          const SnackBar(
            content: Text("Impossibile eliminare il messaggio, tempo scaduto"),
            duration: Duration(seconds: 4),
          ),
        );
      }

      return;
    }
    bool risp;
    ///creo il banner di richiesta di eliminazione
    risp = await BannerEliminazione.mostraBanner(context: cont);

    ///se la risposta è affermativa allora elimino e stampo la SnackBar che avvisa
    ///l'utente della cancellazione corretta del messaggio
    if (risp) {
      try {
        await ChatService().cancellaMessaggio(widget.chatID, messaggioId);
        if (cont.mounted) {
          ScaffoldMessenger.of(cont).showSnackBar(
            const SnackBar(
              content: Text("Messaggio eliminato correttamente!"),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        print("errore nella cancellazione $e");
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
          ///area suggerimenti, mostrata se _isPickerVisible è attivo
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

    return GrigliaCategorie(
      visibleCategories: _visibleCategories,
      selezionato: (nome, termine){
        _selectCategory(nome,termine);
      },
    );

  }

  // --- VISTA 2: GRIGLIA DEI SIMBOLI (RISULTATI) ---
  Widget _buildSymbolsGrid() {

    return GrigliaDeiSimboli(
        simboli: _currentSymbols,
        selezionato: (url,descrizione){
          _aggiungiPittogramma(url, descrizione);
        }
    );
  }

  // --- WIDGET MESSAGGIO (CON GRIGLIA DI PITTOGRAMMI) ---

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == _auth.currentUser!.uid;
    String messaggioId = doc.id;
    Timestamp? timestampMessaggio = data['timestamp'];

    // Recuperiamo la lista di pittogrammi dal documento
    List<dynamic> pictograms = data['pictograms'] ?? [];

    String fullSentence = pictograms.map((p) => p['description'] ?? '').join(" ");
    int itemsPerRow = _impostazioni.gridSize.toInt();
    if (itemsPerRow < 1) itemsPerRow = 1;
    return GestureDetector(
      ///se messaggio premuto a lungo chiede se vuole eliminare il messaggio se è
      ///stato inviato dall'utente
      onLongPress: () => _eliminaMessaggio(context, isMe, messaggioId, timestampMessaggio),
      onTap: () {

        ///Quando la frase è toccata parla
        ///
        SintesiVocale().speak(fullSentence);
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
                if (_impostazioni.showLabels)
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

  ///[_buildInputArea] Barra Inferiore della chat
  ///
  Widget _buildInputArea() {

    return InputArea(cliccato: (){
      setState((){
        _isPickerVisible=!_isPickerVisible;
        if(!_isPickerVisible) FocusScope.of(context).unfocus();
      });
    },isPickerVisible: _isPickerVisible);
  }

  ///Builder della barra dei suggerimenti
  Widget _buildSuggerimenti() {
    ///se non ce nessun messaggio non mostro nulla
    if (_composingMessage.isEmpty) return SizedBox.shrink();

    ///Ricavo l'id dell'ultimo pittogramma inserito
    String ultimoURL = _composingMessage.last['url']!;
    String ultimoId = ultimoURL.split('/').last;

    ///ricavo i suggerimenti di quell'id e ricavo gli url sottoforma di lista
    List<dynamic> suggerimenti = GestoreJson().suggerimentiDiImmagine(ultimoId);
    List<String> listaUrl = List<String>.from(suggerimenti);

    ///se non c'è nessun suggerimento allora non mostro nulla
    if (suggerimenti.isEmpty) return SizedBox.shrink();

    ///costruisco la barra dei suggerimenti, passondo la lista degli url
    ///dei pittogrammi da suggerire, e la funzione da eseguire quando si preme sul
    ///pittogramma suggerito con parametro la stringa url del pittogramma schiacciato
    ///con la ricerca della descrizione
    ///
    return Suggerimenti(
      dati: listaUrl,
      selezionato: (urlCliccato) async {
        String descrizione=await PictogramService().getDescrizione(urlCliccato);
        _aggiungiPittogramma(urlCliccato, descrizione);
      },
    );
  }



  // --- ANTEPRIMA MESSAGGIO IN COMPOSIZIONE ---
  Widget _buildComposerPreview() {
    
    return ComposizioneMessaggio(
        composingMessage: _composingMessage,
        invio: _handleSendMessage,
        rimozione:(posizioneDaEliminare){
          setState((){
            _composingMessage.removeAt(posizioneDaEliminare);
          });
        },
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

  ///[_caricaPreferenze] metodo per caricare le preferenze di un determinato utente
  ///nelle impostazioni della chat
  ///
  Future<void> _caricaPreferenze() async {
    final utente=FirebaseAuth.instance.currentUser;

    PreferenzeChat nuoveImpostazioni;

    ///Se l'utente è null allora non fa nulla e tiene le impostazioni standard
    ///
    if(utente==null) return;

    ///Chiedo le impostazioni usando il gestore Preferenze
    ///
    nuoveImpostazioni = await _gestorePreferenze.caricaPreferenze(utente.uid);

    if (mounted) {
      setState((){
        ///imposto le preferenze trovate
        _impostazioni=nuoveImpostazioni;
      });
    }
  }

  ///[_caricaPermessi] metodo che permette di caricare per un determinato
  ///utente i permessi di utilizzo di determinate categorie di pittogrammi
  ///
  Future<void> _caricaPermessi() async {

    ///trova l'utente se non esiste allora esci dalla funzione e mantieni
    ///la lista vuota
    ///
    final utente=FirebaseAuth.instance.currentUser;
    if(utente==null)    return;

    ///trova quali sono le categorie permesse per l'utente
    ///
    List<String> pittogrammiOk=await _gestorePermessi.recuperaCategorie(utente.uid);


    ///se la pagina è attiva allora aggiorno i permessi dell'utente se ci sono
    ///altrimenti gli mostro tutto
    ///
    if(mounted)
    {

      setState((){
        if(pittogrammiOk.isNotEmpty) {

          _visibleCategories=CategoriePittogrammi.categories.where((cat){
            return pittogrammiOk.contains(cat['name']);}).toList();

        }
        else _visibleCategories=List.from(CategoriePittogrammi.categories);

      });

    }
  }
}

