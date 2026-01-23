import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditCcnPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditCcnPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<EditCcnPage> createState() => _EditCcnPageState();
}

class _EditCcnPageState extends State<EditCcnPage> {
  bool _isLoading = false;
  
  // 1. STATO DEL PROFILO
  late bool _isActive;

  // 2. LISTA DI TUTTE LE CATEGORIE DISPONIBILI (Deve coincidere con quelle in ChatPage)
  final List<String> _allCategories = [
    'Persone', 'Azioni', 'Emozioni', 'Cibo', 'Luoghi', 
    'Scuola', 'Corpo', 'Vestiti', 'Saluti', 'Aggettivi'
  ];

  // 3. MAPPA PER GESTIRE I FLAGG (Quali sono accese?)
  final Map<String, bool> _categoryStates = {};

  @override
  void initState() {
    super.initState();
    _isActive = widget.userData['profiloAttivo'] ?? true;

    // Recuperiamo le categorie abilitate da Firebase (se esistono)
    // Se l'array 'enabledCategories' non esiste nel DB, assumiamo che siano TUTTE attive di default.
    List<dynamic> savedCategories = widget.userData['enabledCategories'] ?? _allCategories;

    // Inizializziamo gli switch
    for (var cat in _allCategories) {
      // È attiva se è presente nella lista salvata
      _categoryStates[cat] = savedCategories.contains(cat);
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName = "${widget.userData['Nome']} ${widget.userData['Cognome']}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifica Permessi"),
        backgroundColor: Colors.deepPurple.shade100,
        actions: [
          // Tasto Salva in alto a destra
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // HEADER UTENTE
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(255, 113, 89, 155),
                      child: Text(fullName[0], style: const TextStyle(fontSize: 30, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("Gestisci cosa può vedere questo utente", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // SEZIONE 1: STATO ACCOUNT
              const Text("Stato Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text("Profilo Attivo"),
                  subtitle: Text(_isActive ? "L'utente può accedere all'app" : "Accesso bloccato"),
                  value: _isActive,
                  activeThumbColor: Colors.green,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),

              const SizedBox(height: 25),

              // SEZIONE 2: CATEGORIE VISIBILI
              const Text("Categorie Pittogrammi Visibili", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 5),
              const Text("Disattiva le categorie troppo complesse per l'utente.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 10),
              
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: _allCategories.map((cat) {
                    return Column(
                      children: [
                        SwitchListTile(
                          title: Text(cat),
                          value: _categoryStates[cat]!,
                          activeThumbColor: Colors.deepPurple,
                          onChanged: (val) {
                            setState(() {
                              _categoryStates[cat] = val;
                            });
                          },
                        ),
                        // Divisore sottile tra le righe (tranne l'ultima)
                        if (cat != _allCategories.last) const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),
              
              // BOTTONE SALVA GRANDE
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveChanges,
                  child: const Text("Salva Modifiche", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      // 1. Ricostruiamo la lista delle categorie abilitate (Solo quelle attive)
      List<String> enabledList = [];
      _categoryStates.forEach((key, value) {
        if (value == true) enabledList.add(key);
      });

      // 2. Aggiorniamo Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'profiloAttivo': _isActive,
        'enabledCategories': enabledList, // Salviamo la lista
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo aggiornato con successo!")));
        Navigator.pop(context); // Torna indietro
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}