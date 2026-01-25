import '../../services/preferences_service.dart';

///[PreferenzeChat] classe che contiene le informazioni riguardanti
///le preferenze grafiche dell'utente
///
class PreferenzeChat{

  ///[gridSize] dimensione della grid
  ///
  final double gridSize;

  ///[showLabels]
  ///
  final bool showLabels;

  ///[autoRead] se deve implementare l'autoreas
  ///
  final bool autoRead;

  ///[isDarkMode] se la dark mode è attiva
  ///
  final bool isDarkMode;

  ///metodo costruttore va a impostare in automatico le preferenze
  ///
  const PreferenzeChat({
    this.gridSize=3.0,
    this.showLabels=true,
    this.autoRead=false,
    this.isDarkMode=false,
  });

  ///metodo costruttore che va impostare le preferenze con parametri dati in ingresso
  ///
  PreferenzeChat.dati(Map<String, dynamic> map):
        gridSize=(map[PreferencesService.keyGridSize] as num?)?.toDouble() ?? 3.0,
        showLabels=map[PreferencesService.keyShowLabels] ?? true,
        autoRead=map[PreferencesService.keyAutoRead] ?? false,
        isDarkMode=map[PreferencesService.keyDarkMode] ?? false;
}



