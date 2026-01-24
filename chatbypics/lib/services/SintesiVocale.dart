import 'package:flutter_tts/flutter_tts.dart';


///[SintesiVocale] classe che implementa la logica della sintesi vocale
///usa il pattern design Singleton e usa anche il Pattern Delegation
///per l'utilizzo della sintesi vocale con la classe FlutterTts()
///
class SintesiVocale{

  ///[_sint] istanza dell'oggetto FlutterTts che permetto la sintesi vocale
  ///
  final FlutterTts _sint;

  ///metodo costruttore privato, quando chiamato va
  ///prima ad assegnare a [_sint], poi va a fare il corpo del metodo
  ///
  SintesiVocale._() : _sint=FlutterTts(){

    _initTts();

  }

  ///[_istanza] rappresenta l'istanza della classe
  ///
  static final SintesiVocale _istanza=SintesiVocale._();

  ///il factory che in dart permette il metodo getIstance()
  ///
  factory SintesiVocale(){

    return _istanza;

  }

  ///[speak] metodo utilizzato per effettuare la sintesi vocale dato
  ///in ingresso un [text] ossia una stringa da leggere
  ///
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {

      ///Smette eventualmente di parlare e parla di nuovo
      ///
      await stop();
      await _sint.speak(text);
    }
  }

  ///[stop] metodo usato per stoppare la sintesi vocale in corso
  ///
  Future<void> stop() async {
    await _sint.stop();
  }

  ///[_initTts] metodo che permette la inizializzazione della sintesi vocale
  ///dei pittogrammi
  ///
  void _initTts() async {

    ///imposta lingua italiana
    ///
    await _sint.setLanguage("it-IT");

    ///imposta il tono della sintesi e la velocità
    ///
    await _sint.setPitch(1.0);
    await _sint.setSpeechRate(1);

    ///controlla se è possibile impostare la lingua italiana
    ///
    var isLanguageAvailable = await _sint.isLanguageAvailable("it-IT");

    ///se la lingua selezionata non è disponibile avviso in console che
    ///non è installata
    ///
    if (!isLanguageAvailable) {
      print("Errore: La lingua italiana non è installata sul dispositivo");
    }
  }

}