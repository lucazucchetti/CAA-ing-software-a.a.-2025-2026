import 'package:chatbypics/screens/chat/PreferenzeChat.dart';
import 'package:chatbypics/services/preferences_service.dart';

///[GestoreRichiestePreferenze] Classe usata per richiedere tramite PreferenceService
///le impostazioni di un utente
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

  /// Salva una preferenza specifica (passacarte verso il Service)
  Future<void> updateSetting(String userId, String key, dynamic value) async {
    await _service.updatePreference(userId, key, value);
  }
}