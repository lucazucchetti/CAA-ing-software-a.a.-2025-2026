import 'package:chatbypics/screens/chat/PreferenzeChat.dart';
import 'package:chatbypics/services/preferences_service.dart';

///[GestoreRichiestePreferenze] Classe usata per richiedere tramite PreferenceService
///le impostazioni di un utente, usa il DELEGATION PATTERN
///
class GestoreRichiestePreferenze {

  final PreferencesService _service=PreferencesService();

  ///[caricaPreferenze] metodo che permette di ricercare le preferenze
  ///di un determinato utente
  ///
  Future<PreferenzeChat>caricaPreferenze(String userId) async {

    ///Scarico le preferenze per l'utente
    ///
    Map<String, dynamic> dati = await _service.getUserPreferences(userId);

    ///ritorno le preferenze nell'oggetto [PreferenzeChat]
    return PreferenzeChat.dati(dati);
  }


}