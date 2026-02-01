import 'package:chatbypics/screens/chat/CategoriePittogrammi.dart';
import 'package:chatbypics/screens/chat/ComposizioneMessaggio/ComposizioneMessaggio.dart';
import 'package:chatbypics/screens/chat/Gestori/GestorePermessi.dart';
import 'package:chatbypics/screens/chat/InputArea/InputArea.dart';
import 'package:chatbypics/screens/chat/suggerimenti/Suggerimenti.dart';
import 'package:chatbypics/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chatbypics/services/pictogram_service.dart';
import 'package:chatbypics/services/GestoreJson.dart';

import 'PersistentPicker/PersistentPicker.dart';

///[SezioneScrittura] classe che implementa tutta la parte necessaria
///a mostrare e far funzionare la sezione della chat per comporre e
///inviare i messaggi
///
class SezioneScrittura extends StatefulWidget{

  ///[chatID] è l'id della singola chat da mostrare
  ///passato come parametro nel metodo costruttore
  ///
  final String chatID;

  ///[utente] è l'istanza dell'utente che invia i messaggi
  ///quindi l'utente corrente
  final User utente;

  const SezioneScrittura({
    super.key,
    required this.chatID,
    required this.utente,

  });

  @override
  State<SezioneScrittura> createState() => _SezioneScritturaState();
}

class _SezioneScritturaState extends State<SezioneScrittura> {

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

  ///[_gestoreJson] il gestore del file Json singleton
  ///
  final GestoreJson _gestoreJson=GestoreJson();

  ///[_chatService] il chat service usato
  ///
  final ChatService _chatService=ChatService();

  ///[_pictogramService] il pictogram service
  ///
  final PictogramService _pictogramService=PictogramService();

  ///[initState] Stato iniziale eseguito una volta all'apertura della chat
  ///
  @override
  void initState() {

    super.initState();

    ///carico i permessi utente
    ///
    _caricaPermessi();

    ///leggo il file json, carico i dati nella struttura dati
    ///
    _gestoreJson.leggiJson();
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

      _gestoreJson.aggiornamentoSuggerimenti(oldId,newURL);
    }

    setState((){
      _composingMessage.add({'url': newURL, 'desc': desc});
    });
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
    await _chatService.sendPictogramMessage(

      chatID: widget.chatID,
      senderID: widget.utente.uid,
      pictograms: messageData,

    );

    ///pulisco la barra di anteprima del messaggio e aggiorno così la grafica
    ///
    setState(() {

      _composingMessage.clear();
      _isPickerVisible=false;

    });
  }

  ///[_caricaPermessi] metodo che permette di caricare per un determinato
  ///utente i permessi di utilizzo di determinate categorie di pittogrammi
  ///
  Future<void> _caricaPermessi() async{

    ///trova l'utente se non esiste allora esci dalla funzione e mantieni
    ///la lista vuota
    ///
    final utente=widget.utente;

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
      var results=await _pictogramService.searchPictograms(term);

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
      var results=await _pictogramService.searchPictograms(query);
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
    List<dynamic> suggerimenti=_gestoreJson.suggerimentiDiImmagine(ultimoId);
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
        String descrizione=await _pictogramService.getDescrizione(urlCliccato);
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



@override
  Widget build(BuildContext context) {
  return Column(
      children: [
        ///anteprima messaggio se _composingMessage ha dei messaggi all'interno
        if (_composingMessage.isNotEmpty) _buildComposerPreview(),
        ///area input
        _buildInputArea(),
        ///area suggerimenti, mostrata se _isPickerVisible è attivo
        if (_isPickerVisible) _buildSuggerimenti(),
        ///selettore pittogrammi se _isPickerVisible è attivo
        if (_isPickerVisible) _buildPersistentPicker(),
      ],
    );
  }
  
}
