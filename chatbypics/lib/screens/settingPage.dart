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
      appBar: AppBar(
        title: StileSettingPage.titoloPagina,
        backgroundColor: StileSettingPage.coloreSfondoPagina,
      ),
      body: ListView(
        children: [
          //  SEZIONE PROFILO
          StileSettingPage.buildSectionHeader(StileSettingPage.headerProfilo),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: StileSettingPage.coloreSfondoIconaProfilo,
              child: Text(user?.email?.substring(0, 1).toUpperCase() ?? "U", 
                style: StileSettingPage.stileNomeProfilo
              ),
            ),
            title: Text(user?.email ?? "Utente"),
            subtitle: StileSettingPage.testoSottotitolo,
            trailing: StileSettingPage.iconaFrecciaAperturaSezione,
            onTap: () {
              // TODO: Naviga a pagina modifica profilo
            },
          ),

          const Divider(),

          //  SEZIONE ACCESSIBILITÀ CAA
          StileSettingPage.buildSectionHeader(StileSettingPage.headerAccessibilita),

          // Switch Etichette
          SwitchListTile(
            title: StileSettingPage.titoloTestoSimboli,
            subtitle: StileSettingPage.sottotitoloTestoSimboli,
            value: _showLabels,
            activeThumbColor: StileSettingPage.coloreLabel,
              onChanged: (val) => _updateVal(PreferencesService.keyShowLabels, val),
          ),

          // Slider Grandezza Griglia
          ListTile(
            title: StileSettingPage.titoloGrandezzaSimboli,
            subtitle: Text("${StileSettingPage.dimensioneAttuale} ${_gridSize.toInt()}"),
          ),
          Slider(
            value: _gridSize,
            min: 1,
            max: 5,
            divisions: 4,
            label: _gridSize.toInt().toString(),
            activeColor: Colors.deepPurple,
            onChanged: (val) => _updateVal(PreferencesService.keyGridSize, val),
          ),

          const Divider(),

          // SEZIONE VOCALE
          StileSettingPage.buildSectionHeader(StileSettingPage.headerSintesiVocale),
          SwitchListTile(
            title: StileSettingPage.titoloSintesi,
            subtitle: StileSettingPage.sottoTitoloSintesi,
            value: _autoReadMessages,
            activeThumbColor: Colors.deepPurple,
            onChanged: (val) => _updateVal(PreferencesService.keyAutoRead, val),
          ),

          ListTile(
            title: StileSettingPage.titoloVelocita,
            trailing: DropdownButton<String>(
              value: StileSettingPage.defaultValue,
              items: StileSettingPage.attributiVelocita.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {
                // TODO: Implementa logica TTS
              },
            ),
          ),

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