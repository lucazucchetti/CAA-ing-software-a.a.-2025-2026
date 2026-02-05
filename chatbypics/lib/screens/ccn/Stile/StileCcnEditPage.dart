import 'package:flutter/material.dart';

abstract class Stileccneditpage {

  ///[allCategories] lista di tutte le categorie che verranno elencate nella pagina per poterle disabilitare al ccn
  static final List<String> allCategories = [
    'Persone', 'Azioni', 'Emozioni', 'Cibo', 'Luoghi', 
    'Scuola', 'Corpo', 'Vestiti', 'Saluti', 'Aggettivi'
  ];

  ///[buildAppBar] metodo che costruisce l'app bar della pagina
  ///[saveChanges] chiama la funzione che salva i dati nel DB
  static AppBar buildAppBar(Future<void> Function() saveChanges){
    return AppBar(title: const Text("Modifica Permessi"),
          backgroundColor: Colors.deepPurple.shade100,
          actions: [
            // Tasto Salva in alto a destra
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveChanges,
            )
          ],
        );
  }

  ///[iconaBarraProgresso] costruisce la barra di caricamento in caso ci volesse tempo per caricare i dati
  static const iconaBarraProgresso = Center(child: CircularProgressIndicator());

  ///[buildListViewPagina] costruisce la list view che compone l'intera pagina
  ///[saveChanges] chiama la funzione che salva i cambiamenti nel DB
  ///[fullName] nome del ccn preso dal database
  ///[isActive] variabile per disabilitare il profilo
  ///[statiCategorieAttuali] mappa delle categorie che rimangono attive, salvandole qui
  ///[onCategoryChanged] chiama la funzione per salvare i cambiamenti nel DB
  ///[onStatusChanged] chiama il salvataggio sul DB dello stato del profilo
  static ListView buildListViewPagina(
    Future<void> Function() saveChanges, 
    String fullName, 
    bool isActive, 
    Map<String,bool> statiCategorieAttuali,
    Function(String, bool) onCategoryChanged,
    Function(bool) onStatusChanged){
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildHeaderUtente(fullName),
        const SizedBox(height: 30),

        const Text("Stato Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        builStatoAccount(isActive, onStatusChanged),

        const SizedBox(height: 25),

        const Text("Categorie Pittogrammi Visibili", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 5),
        const Text("Disattiva le categorie troppo complesse per l'utente.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 10),
        
        builCategorieVisibili(statiCategorieAttuali, onCategoryChanged),

        const SizedBox(height: 30),
        buildBottoneSalva(saveChanges),
      ],
    );

  }

  ///[buildHeaderUtente] costruisce la sezione dell'header
  static Center buildHeaderUtente(String fullName){
    return Center(
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
    );
  }
  ///[buildStatoAccount] costruisce la sezione per la disattivazione dell'account del ccn
  static Card builStatoAccount(bool isActive, Function(bool) onStatusChanged){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text("Profilo Attivo"),
        subtitle: Text(isActive ? "L'utente può accedere all'app" : "Accesso bloccato"),
        value: isActive,
        activeThumbColor: Colors.green,
        onChanged: onStatusChanged,
      ),
    );
  }

  ///[builCategorieVisibili] costruisce la sezione dedicata alla disattivazione delle categorie
  static Card builCategorieVisibili(Map<String,bool> statiCategorieAttuali, Function(String, bool) onCategoryChanged){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: allCategories.map((cat) {
          return Column(
            children: [
              SwitchListTile(
                title: Text(cat),
                value: statiCategorieAttuali[cat]!,
                activeThumbColor: Colors.deepPurple,
                onChanged: (val) {
                  onCategoryChanged(cat,val);
                },
              ),
              if (cat != allCategories.last) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  ///[buildBottoneSalva] costruisce il bottone per salvare le modifiche
  static SizedBox buildBottoneSalva(Future<void> Function() saveChanges){
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: saveChanges,
        child: const Text("Salva Modifiche", style: TextStyle(fontSize: 18)),
      ),
    );
  }

}