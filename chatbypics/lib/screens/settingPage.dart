import 'package:chatbypics/screens/ccnManagePage.dart';
import 'package:chatbypics/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  bool _isDarkMode = false;
  bool _showLabels = true;
  bool _autoReadMessages = true;
  double _gridSize = 3.0; // Valore indicativo per lo slider

  final User? user = Auth().currentUser; // Recupero utente corrente

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: ListView(
        children: [
          //  SEZIONE PROFILO
          _buildSectionHeader("Profilo"),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(user?.email?.substring(0, 1).toUpperCase() ?? "U", style: const TextStyle(color: Colors.white)),
            ),
            title: Text(user?.email ?? "Utente"),
            subtitle: const Text("Tocca per modificare il profilo"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Naviga a pagina modifica profilo
            },
          ),

          const Divider(),

          //  SEZIONE ACCESSIBILITÀ CAA
          _buildSectionHeader("Accessibilità CAA"),

          // Switch Etichette
          SwitchListTile(
            title: const Text("Mostra testo sotto i simboli"),
            subtitle: const Text("Aiuta l'associazione immagine-parola"),
            value: _showLabels,
            activeThumbColor: Colors.deepPurple,
            onChanged: (bool value) {
              setState(() => _showLabels = value);
              // TODO: Salva preferenza
            },
          ),

          // Slider Grandezza Griglia
          ListTile(
            title: const Text("Grandezza Griglia Simboli"),
            subtitle: Text("Dimensione attuale: ${_gridSize.toInt()}"),
          ),
          Slider(
            value: _gridSize,
            min: 1,
            max: 5,
            divisions: 4,
            label: _gridSize.toInt().toString(),
            activeColor: Colors.deepPurple,
            onChanged: (double value) {
              setState(() => _gridSize = value);
              // TODO: Salva preferenza e aggiorna GridView nella chat
            },
          ),

          const Divider(),

          // SEZIONE VOCALE
          _buildSectionHeader("Sintesi Vocale"),
          SwitchListTile(
            title: const Text("Lettura Automatica"),
            subtitle: const Text("Leggi i messaggi appena arrivano"),
            value: _autoReadMessages,
            activeThumbColor: Colors.deepPurple,
            onChanged: (bool value) {
              setState(() => _autoReadMessages = value);
            },
          ),
          ListTile(
            title: const Text("Velocità Voce"),
            trailing: DropdownButton<String>(
              value: "Normale",
              items: <String>['Lenta', 'Normale', 'Veloce'].map((String value) {
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
          _buildSectionHeader("App & Sistema"),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Modalità Scura"),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() => _isDarkMode = value);
              // TODO: Implementa cambio tema globale
            },
          ),

          ListTile(
            leading: const Icon(Icons.download_for_offline),
            title: const Text("Gestione Offline"),
            subtitle: const Text("Scarica simboli per uso senza rete"),
            onTap: () {
              // TODO: Logica download massivo
            },
          ),

          const Divider(),

          //  TASTO LOGOUT
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
                elevation: 0,
              ),
              icon: const Icon(Icons.logout),
              label: const Text("Disconnetti"),
              onPressed: () async {
                await Auth().signOut();
                // AuthPage gestirà il cambio di stato grazie allo StreamBuilder nel main
              },
            ),
          ),

          const Center(
            child: Text("Versione 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget helper per i titoli delle sezioni
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}