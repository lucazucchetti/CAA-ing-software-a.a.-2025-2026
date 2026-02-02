import 'package:chatbypics/screens/setting/StileSettingPage.dart';
import 'package:chatbypics/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbypics/services/preferences_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final PreferencesService _prefService = PreferencesService();
  ///[user] variabile che salva che l'utente per salvare le modifiche nel documento associato all'utente nel DB
  final User? user = Auth().currentUser;

  ///[_isDarkMode] impostazione default del tema dell'applicazione
  bool _isDarkMode = false;

  ///[_showLabels] impostazione default per mostrare le etichette descrittive sotto ai pittogrammi
  bool _showLabels = true;

  ///[_autoReadMessages] impostazione default per la lettura automatica dei pittogrammi
  bool _autoReadMessages = true;

  ///[_gridSize] impostazione default per la grandezza della griglia dei pittogrammi
  double _gridSize = 3.0; // Valore indicativo per lo slider


  @override
  void initState() {
    super.initState();
    _initPreferences(); // Carica le impostazioni all'avvio
  }
  ///[_initPreferences] metodo che carica i dati usando il service
  void _initPreferences() async {
    if (user == null) return;
    var prefs = await _prefService.getUserPreferences(user!.uid);

    //aggiorna l'interfaccia solo in caso sia già carica [mounted]
    if (mounted) {
      setState(() {
        if (prefs.containsKey(PreferencesService.keyDarkMode)) {
          _isDarkMode = prefs[PreferencesService.keyDarkMode];
        }
        if (prefs.containsKey(PreferencesService.keyShowLabels)) {
          _showLabels = prefs[PreferencesService.keyShowLabels];
        }
        if (prefs.containsKey(PreferencesService.keyAutoRead)) {
          _autoReadMessages = prefs[PreferencesService.keyAutoRead];
        }
        if (prefs.containsKey(PreferencesService.keyGridSize)) {
          _gridSize = (prefs[PreferencesService.keyGridSize] as num).toDouble();
        }
      });
    }
  }
  ///[_updateVal] Metodo per aggiornare contemporaneamente interfaccia e firebase DB
  void _updateVal(String key, dynamic value) {
    setState(() {
      if (key == PreferencesService.keyShowLabels) _showLabels = value;
      if (key == PreferencesService.keyGridSize) _gridSize = value;
      if (key == PreferencesService.keyAutoRead) _autoReadMessages = value;
      if (key == PreferencesService.keyDarkMode) _isDarkMode = value;
    });
    if (user != null) {
      _prefService.updatePreference(user!.uid, key, value);
    }
  }
  ///[build] costruisce la pagina, tutte le personalizzazioni grafiche sono realizzate
  ///nella classe [StileSettingPage]
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StileSettingPage.buildAppBar,
      body: ListView(
        children: [
          StileSettingPage.buildSettingProfilo(user?.email?.substring(0, 1).toUpperCase() ?? "U", user?.email ?? "Utente"),

          const Divider(),

          StileSettingPage.buildSettingAccessibilita(_showLabels, (val) => _updateVal(PreferencesService.keyShowLabels, val), _gridSize, (val) => _updateVal(PreferencesService.keyGridSize, val)),
          
          const Divider(),
          StileSettingPage.buildSettingSintesiVocale(_autoReadMessages, (val) => _updateVal(PreferencesService.keyAutoRead, val)),

          const Divider(),

          StileSettingPage.buildSettingAppSistema(_isDarkMode, (val) => _updateVal(PreferencesService.keyDarkMode, val)),

          const Divider(),

          StileSettingPage.tastoLogout(() => Auth().signOut()),
        ],
      ),
    );
  }

  
}