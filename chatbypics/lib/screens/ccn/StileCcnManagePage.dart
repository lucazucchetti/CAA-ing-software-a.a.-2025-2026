import 'package:chatbypics/screens/addCcnPage.dart';
import 'package:chatbypics/screens/chatList/RuoloListaTerzi.dart';
import 'package:chatbypics/screens/chatListPage.dart';
import 'package:chatbypics/screens/editCcnPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

///[Stileccnmanagepage] questa classe gestisce lo stile e parte della logica collegata alla grafica (bottoni, sezioni espandibili)
///per la gestione dei ccn registrati
abstract class Stileccnmanagepage {
  ///[titoloPagina] variabile del titolo della pagina
  static Text titoloPagina = Text("Gestione Utenti CCN");

  ///[sfondoPagina] variabile del colore dello sfondo
  static Color sfondoPagina = Colors.deepPurple.shade50;

  ///[buildAppBar] metodo che costruisce l'app bar della pagina
  static AppBar buildAppBar = AppBar(
    title: titoloPagina,
    backgroundColor: sfondoPagina,
  );

  ///[iconaBarraProgresso] questo metodo costruisce la barra progresso in caso ci volesse del tempo
  ///per caricare i dati da firebase
  static Center iconaBarraProgresso(){
    return Center(child: CircularProgressIndicator());
  }

  ///[ccnGestitiAssenti] questo metodo costruisce un messaggio per dire che non si hanno ccn gestisti
  static Center ccnGestitiAssenti(){
    return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text("Nessun utente CCN associato.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text("Premi + per crearne uno.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
  }

  ///[buildSchedaListaCcn] costruisce la scheda del ccn per poterlo gestire
  static Card buildSchedaListaCcn(String fullName, bool isActive, BuildContext context, String docId, var userData){
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: buildAvatarIcon(fullName),
        title: buildNome(fullName),
        subtitle: buildStato(fullName, isActive),
        trailing: buildAzioni(context, fullName, docId, userData),
      ),
    );

  }

  ///[_showDeleteDialog] costruisce la finestra di dialogo per confermare l'eliminazione (estetica)
  static void _showDeleteDialog(String docId, String name, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminare utente?"),
        content: Text("Sei sicuro di voler eliminare l'account di $name?\nQuesta azione non può essere annullata."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(docId).delete();
              
              if (context.mounted) {
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name eliminato correttamente."))
                );
              }
            },
            child: const Text("Elimina", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  ///[buildBottoneAggiuntaCcn] questo metodo costruisce il bottone che consente di aggiungere un nuovo ccn alla lista dei ccn gestiti
  static FloatingActionButton buildBottoneAggiuntaCcn(BuildContext context){
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddCcnPage()),
        );
      },
      backgroundColor: Colors.deepPurple,
      icon: const Icon(Icons.person_add, color: Colors.white),
      label: const Text("Nuovo CCN", style: TextStyle(color: Colors.white)),
    );

  }

  ///[buildAvatarIcon] costruisce l'icona del ccn
  static CircleAvatar buildAvatarIcon(String fullName){
    return CircleAvatar(
      backgroundColor: Colors.deepPurple,
      radius: 25,
      child: Text(
        fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
  ///[buildNome] costruisce il nome del ccn
  static Text buildNome(String fullName){
    return Text(
      fullName, 
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  ///[buildStato] costruisce lo stato del ccn
  static Text buildStato(String fullName, bool isActive){
    return Text(
      isActive ? "Profilo attivo" : "Disattivato",
      style: TextStyle(color: isActive ? Colors.green : Colors.red),
    );
  }

  ///[buildAzioni] costruisce le azioni possibili per gestire il ccn
  static Row buildAzioni(BuildContext context,String fullName, String docId, var userData){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildIconaModifica(context, fullName, userData, docId),
        buildIconaElimina(context, docId, fullName),
        buildIconaOsservaChat(context, docId, fullName),
      ],
    );
  }

  ///[buildIconaModifica] Costruisce l'icona cliccabile per la moficica del ccn
  static IconButton buildIconaModifica(BuildContext context, String fullName, var userData, String docId){
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
    onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCcnPage(
            userId: docId, 
            userData: userData,
            ),
          ),
        );
      },
    );
  }

  ///[buildIconaElimina] Costruisce l'icona cliccabile per l'eliminazione del ccn
  static IconButton buildIconaElimina(BuildContext context, String docId, String fullName){
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.redAccent),
      onPressed: () {
          _showDeleteDialog(docId, fullName, context);
      },
    );
  }

  ///[buildIconaOsservaChat] Costruisce l'icona cliccabile per osservare le chat del ccn
  static IconButton buildIconaOsservaChat(BuildContext context, String docId, String nomeCcn){
    return IconButton(
      icon: const Icon(Icons.visibility_sharp, color: Colors.blue),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListPage(osservatore: docId, ruolo: RuoloListaTerzi(), nomeCCN: nomeCcn),
          ),
        );
      },
    );
  }
}
