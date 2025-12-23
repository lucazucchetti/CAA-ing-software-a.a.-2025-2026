import 'package:flutter/material.dart';

class CCNManagePage extends StatefulWidget {
  const CCNManagePage({super.key});

  @override
  State<CCNManagePage> createState() => _CCNManagePageState();
}

class _CCNManagePageState extends State<CCNManagePage> {
  // LISTA FINTA DI ESEMPIO (Poi arriverà da Firestore)
  final List<String> _ccnUsers = [
    "Mario Rossi",
    "Luigi Verdi",
    "Anna Bianchi",
    "Giulia Neri"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Utenti CCN"),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      
      // IL BUILDER DELLA LISTA (Come nelle Chat)
      body: _ccnUsers.isEmpty 
        ? const Center(child: Text("Nessun utente CCN associato")) 
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _ccnUsers.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                elevation: 2, // Leggera ombreggiatura
                child: ListTile(
                  // AVATAR
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      _ccnUsers[index][0], // Iniziale del nome
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  
                  // NOME DELL'UTENTE
                  title: Text(
                    _ccnUsers[index], 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  
                  // SOTTOTITOLO (Opzionale, es. stato o ultima attività)
                  subtitle: const Text("Profilo attivo"),

                  // AZIONI (Modifica / Elimina)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                    children: [
                      // Tasto Modifica
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Apri pagina modifica profilo
                        },
                      ),
                      // Tasto Elimina
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                           // Mostra conferma eliminazione
                           _showDeleteDialog(index);
                        },
                      ),
                    ],
                  ),
                  
                  // Se clicchi sulla riga intera, magari apri i dettagli
                  onTap: () {
                    // Navigator.push(...) verso i dettagli
                  },
                ),
              );
            },
          ),

      // BOTTONE PER AGGIUNGERE NUOVO CCN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Qui collegherai la pagina di registrazione CCN che volevi fare
          // Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterCCNPage()));
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Nuovo CCN", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Finestra di dialogo per confermare l'eliminazione (estetica)
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminare utente?"),
        content: Text("Sei sicuro di voler rimuovere ${_ccnUsers[index]} dalla tua gestione?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _ccnUsers.removeAt(index); // Rimuove dalla lista visiva
              });
              Navigator.pop(context);
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}