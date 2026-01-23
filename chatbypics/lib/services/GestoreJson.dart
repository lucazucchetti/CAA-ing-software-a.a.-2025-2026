import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

///Classe che permette di interfacciarsi con il file Json contenente per ogni pittogramma
///i più recenti utilizzati dopo il pittogramma
///
///Utilizza un design pattern Singleton quindi l'accesso ai metodi
///avverà tramite GestoreJson()
///
///Utilizza una logica di lavoro in memoria, quindi andrà a aprire il json e salvare i dati
///in memoria, poi successivamente andrà a scrivere i dati in memoria nel file json
///
class GestoreJson{

  ///metodo costruttore privato della classe
  GestoreJson._();

  ///static final [_istanza], rappresenta l'istanza della classe
  static final GestoreJson _istanza = GestoreJson._();

  ///il factory che in dart permette il metodo getInstance
  factory GestoreJson(){
    return _istanza;
  }
    ///Map\<String, List\<dynamic>> [_pittogrammiMap], rappresenta la struttura dati utilizzata per
    ///salvare in memoria i dati letti dal file json, verra utilizzata anche nella scrittura dei nuovi dati nel file json.
    ///
    ///la key è l'id ossia l'ultima parte dell'url che identifica il pittogramma, a questo corrisponde una
    ///lista di valori(max 3) che sono gli url dei pittogrammi suggeriti(più recenti), viene istanziata come vuota
    Map<String, List<dynamic>> _pittogrammiMap = {};

    ///static const String [_nomeFile] nome del file json dove sono presenti i suggerimenti
    static const String _nomeFile = 'suggerimenti.json';

    ///Metodo asincrono [leggiJson] permette la lettura del file json di nome [_nomeFile]
    ///e va a salvare i dati letti nella struttura [_pittogrammiMap], la lettura del file json avviene nella
    ///directory privata dell'app nel Sandbox
    ///
    Future<void> leggiJson() async {
      try {
        ///richiede l'accesso al file json nel SandBox
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_nomeFile');

        ///se il file esiste legge i dati e li salva su [_pittogrammiMap] convertendoli nel formato corretto
        if (await file.exists()) {
          String dati = await file.readAsString();

          _pittogrammiMap = Map<String, List<dynamic>>.from(jsonDecode(dati));
          print("caricato con successo");

        }
        else {
          print("non trovato");
        }
      }
      catch (e) {
        print("Error lettura json");
      }
    }

    ///Metodo [_salvaInJson] è asincrono e privato e permette la scrittura dei dati salvati in
    ///[_pittogrammiMap] nel file json chiamato [_nomeFile], la scrittura avviene nella cartella
    ///privata dell'app situata nel Sandbox
    ///
    Future<void> _salvaInJson() async {
      try {
        ///richiesta nel Sandbox per accedere al json
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_nomeFile');

        ///scrive nel json
        String dato = jsonEncode(_pittogrammiMap);
        await file.writeAsString(dato);

        print("aggiornato il file in memoria");
      } catch (e) {
        print("errore aggiornamento del file in memoria");
      }
    }

    ///Metodo [suggerimentiDiImmagine] permette di ottenere la lista di suggerimenti(URL)
    ///dato in input un ID di un pittogramma, se non è presente la lista restituisce una Lista vuota
    ///
    ///__parametri: String id__
    ///
    ///__restituisce List \<dynamic>__
    ///
    List<dynamic> suggerimentiDiImmagine(String id) {

      if(_pittogrammiMap.containsKey(id)) {
        return _pittogrammiMap[id]!;
      } else {
        return [];
      }

    }
    ///Metodo [aggiornamentoSuggerimenti] asincrono permette l'aggiornamento nella struttura dati
    ///dei suggerimenti da proporre per un pittogramma dato e lo scrive nel file json tramite il metodo
    ///[_salvaInJson]
    ///
    ///__parametri: String oldId, String newUrl__
    ///oldId è l'id del pittogramma da aggiornare(key della [_pittogrammiMap])
    ///newUrl è l'url del pittogramma che è stato inserito dopo il pittogramma di oldId
    ///quindi da aggiornare il valore di [_pittogrammiMap]
    ///
    Future<void> aggiornamentoSuggerimenti(String oldId, String newURL) async {

      ///suggerimenti è la lista che conterrà il valore della key oldId
      ///se non esiste un valore per la key allora la imposta vuota
      List<dynamic> suggerimenti;
      if (_pittogrammiMap.containsKey(oldId)) {
        suggerimenti = List.from(_pittogrammiMap[oldId]!);
      }
      else
      {
        suggerimenti=[];
      }

      ///se esiste già il newURL nei suggerimenti allora lo toglie dai suggerimenti
      if (suggerimenti.contains(newURL)) {
        suggerimenti.remove(newURL);
      }
      ///inserisce in testa i suggerimenti il newURL
      suggerimenti.insert(0, newURL);

      ///se abbiamo più di 3 elementi nei suggerimenti allora rimuovo il suggerimento
      ///meno recente in modo da mantenere sempre i 3 suggermenti
      if (suggerimenti.length > 3) {
        suggerimenti = suggerimenti.sublist(0, 3);
      }

      ///salvo nella struttura dati i suggerimenti aggiornati
      _pittogrammiMap[oldId] = suggerimenti;

      ///scrivo nel file json la struttura dati aggiornata
      await _salvaInJson();

      print("aggiornati suggerimenti dopo $oldId ci sarà $newURL");
    }
  }