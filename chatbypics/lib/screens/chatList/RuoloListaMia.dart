import 'package:chatbypics/screens/chat/RuoloChat.dart';
import 'package:chatbypics/screens/chat/RuoloScrittore.dart';
import 'package:flutter/material.dart';
import '../newChatPage.dart';
import 'RuoloLista.dart';

///[RuoloListaMia] classe che implementa i metodi per andare a costruire una lista che è propria
///dell'utente che sta usando l'app, quindi permette di far sapere che è l'utente corrente e
///permettera di scrivere nelle chat che andrà a selezionare
///
/// (Ruolo Concreto)
///
class RuoloListaMia implements RuoloLista{
  @override
  Widget? buildBottone(BuildContext context) {
    ///crea il bottone
    return FloatingActionButton(
      onPressed: () {
        // Naviga alla pagina di selezione contatti
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NewChatPage()));
      },
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.person_add, color: Colors.white),
    );
  }

  @override
  Color getColoreBackground() {
    ///colore viola chiaro
    return Colors.deepPurple.shade100;
  }

  @override
  Color getColoreIcone(){
    return Colors.deepPurple.shade200;
  }

  @override
  Text getTestoIntestazione(String? nomeUtente) {
    return Text("Le tue Chat ", style: TextStyle(color: Colors.black));
  }

  @override
  ///imposto nella classe ruolo da scrittore
  RuoloChat getRuoloChatPage() {
    return RuoloScrittore();
  }

}