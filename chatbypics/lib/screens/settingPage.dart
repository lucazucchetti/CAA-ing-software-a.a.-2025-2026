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
  final User? user = Auth().currentUser;

  bool _isDarkMode = false;
  bool _showLabels = true;
  bool _autoReadMessages = true;
  double _gridSize = 3.0; // Valore indicativo per lo slider


  @override
  void initState() {
    super.initState();
    _initPreferences(); // Carica le impostazioni all'avvio
  }
  // Carica i dati usando il service
  void _initPreferences() async {
    if (user == null) return;
    var prefs = await _prefService.getUserPreferences(user!.uid);

    // Aggiorna la UI solo se la pagina è ancora caricata
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
  // Funzione helper per aggiornare UI e Database insieme
  void _updateVal(String key, dynamic value) {
    // Aggiorna UI locale
    setState(() {
      if (key == PreferencesService.keyShowLabels) _showLabels = value;
      if (key == PreferencesService.keyGridSize) _gridSize = value;
      if (key == PreferencesService.keyAutoRead) _autoReadMessages = value;
      if (key == PreferencesService.keyDarkMode) _isDarkMode = value;
    });
    // Salva su DB tramite Service
    if (user != null) {
      _prefService.updatePreference(user!.uid, key, value);
    }
  }

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

          // SEZIONE SISTEMA
          StileSettingPage.buildSectionHeader(StileSettingPage.headerAppSistema),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: StileSettingPage.titoloAppSistema,
            value: _isDarkMode,
            onChanged: (val) => _updateVal(PreferencesService.keyDarkMode, val),
          ),

          const Divider(),

          //  TASTO LOGOUT
          Padding(
            padding: StileSettingPage.padding,
            child: ElevatedButton.icon(
              style: StileSettingPage.bottoneDisconnessione,
              icon: StileSettingPage.iconaDisconnessione,
              label: StileSettingPage.labelBottoneDisconnessione,
              onPressed: () async {
                await Auth().signOut();
                // AuthPage gestirà il cambio di stato grazie allo StreamBuilder nel main
              },
            ),
          ),
        ],
      ),
    );
  }

  
}