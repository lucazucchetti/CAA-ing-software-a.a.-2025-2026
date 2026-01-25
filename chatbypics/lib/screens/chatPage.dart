import 'package:chatbypics/screens/chat/CategoriePittogrammi.dart';
import 'package:chatbypics/screens/chat/ComposizioneMessaggio/ComposizioneMessaggio.dart';
import 'package:chatbypics/screens/chat/EliminazioneMessaggio/AvvisatoreRisultatoEliminazione.dart';
import 'package:chatbypics/screens/chat/Gestori/GestorePermessi.dart';
import 'package:chatbypics/screens/chat/EliminazioneMessaggio/BannerEliminazione.dart';
import 'package:chatbypics/screens/chat/InputArea/InputArea.dart';
import 'package:chatbypics/screens/chat/suggerimenti/Suggerimenti.dart';
import 'package:chatbypics/services/SintesiVocale.dart';
import 'package:chatbypics/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chatbypics/services/pictogram_service.dart';
import 'package:chatbypics/services/GestoreJson.dart';

import 'chat/Gestori/GestoreRichiestePreferenze.dart';
import 'chat/PersistentPicker/PersistentPicker.dart';
import 'chat/PreferenzeChat.dart';
import 'chat/SingoloMessaggio/SingoloMessaggio.dart';


///Classe [ChatPage] è la classe che gestisce le singole chat
///necessita come parametri la [chatID] e il [chatName] per funzionare
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


  ///[_auth] variabile che rappresenta l'istanza del DB utilizzato
  ///
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ///[_composingMessage] Lista di pittogrammi del messaggio da inviare
  ///
  final List<Map<String, String>> _composingMessage = [];

  ///[_isPickerVisible] rappresenta se la barra messaggi è visibile o no
  ///
  bool _isPickerVisible = false;

  ///[_searchController] rappresenta il testo presente nella barra di
  ///ricerca dei pittogrammi
  ///
  final TextEditingController _searchController = TextEditingController();

  ///[_currentSymbols]Lista di simboli che devono essere mostrati al momento
  ///
  List<Map<String, String>> _currentSymbols = [];

  ///[_isLoading] variabile utilizzata per indicare se c'è una ricerca in corso
  ///oppure no per mostrare il caricamento
  ///
  bool _isLoading = false;

  ///[_showingCategories] se true mostra le cartelle se false i simboli
  ///
  bool _showingCategories = true;

  ///[_currentCategoryName]Titolo della categoria usata ora
  ///
  String _currentCategoryName = "";

  ///[_gestorePermessi] oggetto che permette la ricerca delle categorie permesse per l'utente
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

    ///scarico le impostazioni della sintesi vocale,
    ///essendo un Singleton vado a creare l'oggetto in modo
    ///da accellerare il suo funzionamento
    ///
    SintesiVocale();

    ///carico i permessi utente
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
  void _aggiungiPittogramma(String newURL,String desc) {
    if(_composingMessage.isNotEmpty){
      String oldURL=_composingMessage.last['url']!;
      String oldId=oldURL.split('/').last;

      GestoreJson().aggiornamentoSuggerimenti(oldId,newURL);
    }

    setState((){
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

    ///calcolo quando è stato inviato il messaggio e quando è stata fatta la richiesta di
    ///eliminazione.
    ///se non ho il timestamp di invio ancora allora lo imposto ad ora
    ///
    DateTime dataInvio=timestampMessaggio?.toDate() ?? DateTime.now();
    DateTime dataDomanda=DateTime.now();

    ///se il messaggio è troppo vecchio allora dico all'utente che non si può eliminare
    if(dataDomanda.difference(dataInvio).inSeconds>30)
    {
      if(cont.mounted){
        ScaffoldMessenger.of(cont).showSnackBar(
          AvvisatoreRisultatoEliminazione().risposta("Impossibile eliminare il messaggio, tempo scaduto",3)
        );
      }

      return;
    }
    bool risp;
    ///creo il banner di richiesta di eliminazione
    risp=await BannerEliminazione.mostraBanner(context: cont);

    ///se la risposta è affermativa allora elimino e stampo la SnackBar che avvisa
    ///l'utente della cancellazione corretta del messaggio
    if (risp){
      try {
        await ChatService().cancellaMessaggio(widget.chatID, messaggioId);
        if (cont.mounted){
          ScaffoldMessenger.of(cont).showSnackBar(
              AvvisatoreRisultatoEliminazione().risposta("Messaggio eliminato!",3)
          );
        }
      }
      catch(e){
        print("errore nella cancellazione $e");
      }
    }
  }

  ///[build] metodo build principale che crea tutto
  ///
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
            ///mostra i messaggi
            child: _streamBuilder()
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

  ///[_streamBuilder] metodo che restituisce i messaggi dell'utente
  ///
  Widget _streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
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
    );
  }


  ///[_selectCategory] metodo che permette di andare a cambiare la schermata dei
  ///pittogrammi quando si seleziona una categoria.
  ///in ingresso si ha [name] ossia il nome della categoria da mostrare e
  ///[term] ossia il di ricerca effettivo della categoria per le API Arasaac
  ///
  void _selectCategory(String name,String term) async{

    ///viene mostrata la schermata di caricamento e mostro i pittogrammi, imposta
    ///la catrgoria selezionata e cancella eventuale testo di ricerca pittogrammi
    ///
    setState((){
      _isLoading=true;
      _showingCategories=false;
      _currentCategoryName=name;
      _searchController.clear();
    });

    try{

      ///avviene la ricerca dei pittogrammi
      ///
      var results=await PictogramService().searchPictograms(term);

      ///visto che ora ha i pittogrammi smette di mostrare il caricamento e
      ///mostra i risultati
      ///
      setState((){
        _currentSymbols=results;
        _isLoading=false;
      });
    }
    catch (e){
      print("Errore: $e");
      setState(()=>_isLoading=false);
    }
  }

  ///[_performTextSearch] metodo utilizzatio per far avvenire la
  ///ricerca di un pittogramma tramite testo
  ///
  void _performTextSearch() async{

    ///creo la query in base al testo presente nel searchController e lo
    ///pulisco dagli spazi vuoti
    ///
    String query=_searchController.text.trim();

    ///ne non c'è nulla ritorno vuoto
    if (query.isEmpty)  return;

    ///se c'è qualcosa nella barra di ricerca allora vado
    ///a modificare ciò che deve essere mostrato all'utente
    ///
    setState((){
      _isLoading = true;
      _showingCategories = false;
      _currentCategoryName = "Ricerca: $query";
    });

    try {
      ///effettuo la ricerca
      ///
      var results=await PictogramService().searchPictograms(query);
      ///se la ricerca ha esito positivo mostra i siboli
      ///
      setState((){
        _currentSymbols=results;
        _isLoading =false;
      });
    }
    catch (e){
      ///se la ricerca ha dato esito negativo allora smetto di mostrare la
      ///rotella di attesa
      ///
      setState(() => _isLoading = false);
    }
  }

  ///[_backToCategories] metodo utilizzato per tornare alla schermata
  ///di visualizzazione delle categorie
  ///
  void _backToCategories(){

    setState((){
      _showingCategories = true;
      _currentSymbols = [];
      _searchController.clear();
      _currentCategoryName = "";

      FocusScope.of(context).unfocus();
    });

  }

  ///[_buildPersistentPicker] metodo che costruisce e restituisce il PersistentPicker ossio
  ///la senzione della chat apposita per la ricerca e la visualizzazione dei
  ///pittogrammi
  ///
  Widget _buildPersistentPicker(){

    ///creazione del PersistenPicker
    return PersistentPicker(
      mostraCategorie: _showingCategories,
      isLoading: _isLoading,
      currentCategoryName: _currentCategoryName,
      searchController: _searchController,
      visibleCategories: _visibleCategories,
      currentSymbols: _currentSymbols,

      vaiACategorie: _backToCategories,
      ricerca: _performTextSearch,


      chiudi: ()=>setState(()=>_isPickerVisible=false),

      clickCategorie: (nome,termine){
        _selectCategory(nome,termine);
      },

      clickPittogramma: (url,descrizione){
        _aggiungiPittogramma(url, descrizione);
      },
    );
  }


  ///[_buildMessageItem] metodo che va a restituire la sezione dei messaggi inviati
  ///necessita in input il DocumentSnapshit [doc] di riferimento
  ///
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data =doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == _auth.currentUser!.uid;
    String messaggioId=doc.id;
    Timestamp? timestampMessaggio=data['timestamp'];

    /// Recuperiamo la lista di pittogrammi dal documento
    List<dynamic> pictograms = data['pictograms'] ?? [];

    String fullSentence = pictograms.map((p) => p['description'] ?? '').join(" ");
    int itemsPerRow = _impostazioni.gridSize.toInt();
    if (itemsPerRow < 1) itemsPerRow = 1;

    ///creazione del singolo messaggio
    ///
    return SingoloMessaggio(
      isMe: isMe,
      messaggioId: messaggioId,
      timestampMessaggio: timestampMessaggio,
      fullSentence: fullSentence,
      pictograms: pictograms,
      impostazioni: _impostazioni,
      itemsPerRow: itemsPerRow,
      cliccato: (fraseDaLeggere) {
        SintesiVocale().speak(fraseDaLeggere);
      },
      premuto: (context,me,id,timestamp) {
        _eliminaMessaggio(context,me,id,timestamp);
      },
    );
  }

  ///[_buildInputArea] metodo che restituisce la
  ///Barra di click che permette di aprire o chiudere la composizione del messaggio
  ///
  Widget _buildInputArea(){

    return InputArea(cliccato: (){

      setState((){
        _isPickerVisible=!_isPickerVisible;
        if(!_isPickerVisible) FocusScope.of(context).unfocus();
      });
      },
        isPickerVisible: _isPickerVisible);

  }

  ///[_buildSuggerimenti] metodo che restituisce la della barra dei suggerimenti
  ///crea la barra dei pittogrammi suggeriti.
  ///
  Widget _buildSuggerimenti(){
    ///se non ce nessun messaggio non mostro nulla ed esco dal metodo
    if(_composingMessage.isEmpty) return SizedBox.shrink();

    ///Ricavo l'id dell'ultimo pittogramma inserito
    String ultimoURL= _composingMessage.last['url']!;
    String ultimoId=ultimoURL.split('/').last;

    ///ricavo i suggerimenti di quell'id e ricavo gli url sottoforma di lista
    List<dynamic> suggerimenti=GestoreJson().suggerimentiDiImmagine(ultimoId);
    List<String> listaUrl=List<String>.from(suggerimenti);

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



  ///[_buildComposerPreview] metodo utilizzato per andare a
  ///creare la barra di anteprima del messaggio da inviare.
  ///ritorna la barra creata.
  ///
  Widget _buildComposerPreview(){
    
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

  ///[_handleSendMessage] metodo utilizzato per inviare un nuovo messaggio e registrarlo nel
  ///database
  ///
  void _handleSendMessage() async{

    ///se non c'è nulla nella composizione del messaggio allora esce
    ///
    if (_composingMessage.isEmpty)    return;

    ///altrimenti compongo il messaggio nel formato da inviare al database
    ///
    List<Map<String, String>> messageData=_composingMessage.map((p)=>{

      'imageUrl': p['url']!,
      'description': p['desc']!,

    }).toList();

    ///tramite ChatService() invio il messaggio al db
    ///
    await ChatService().sendPictogramMessage(

      chatID: widget.chatID,
      senderID: _auth.currentUser!.uid,
      pictograms: messageData,

    );

    ///pulisco la barra di anteprima del messaggio e aggiorno così la grafica
    ///
    setState(() {

      _composingMessage.clear();
      _isPickerVisible=false;

    });
  }

  ///[_caricaPreferenze] metodo per caricare le preferenze di un determinato utente
  ///nelle impostazioni della chat
  ///
  Future<void> _caricaPreferenze() async{
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
  Future<void> _caricaPermessi() async{

    ///trova l'utente se non esiste allora esci dalla funzione e mantieni
    ///la lista vuota
    ///
    final utente=FirebaseAuth.instance.currentUser;
    if(utente==null)    return;

    ///trova quali sono le categorie permesse per l'utente
    ///
    List<String> pittogrammiOk=await _gestorePermessi.recuperaCategorie(utente.uid);


    ///se la pagina è attiva allora aggiorno i permessi dell'utente se ci sono,
    ///altrimenti gli mostro tutto
    ///
    if(mounted)
    {

      setState((){
        if(pittogrammiOk.isNotEmpty){

          _visibleCategories=CategoriePittogrammi.categories.where((cat){

            return pittogrammiOk.contains(cat['name']);

          }).toList();

        }
        else _visibleCategories=List.from(CategoriePittogrammi.categories);

      });

    }
  }
}

