import 'package:chatbypics/screens/chat/RuoloOsservatore.dart';
import 'package:flutter/material.dart';


import '../chat/RuoloChat.dart';
import 'RuoloLista.dart';

///[RuoloListaTerzi] classe che implementa i metodi per andare a costruire una lista che è propria
///dell'utente del quale si stanno controllando le chat,
///quindi permette di far sapere chi è l'utente controllato e
///permettera di solo leggere le chat che andrà a selezionare
///
/// (Ruolo Concreto)
///
class RuoloListaTerzi implements RuoloLista{
  @override
  Widget? buildBottone(BuildContext context) {
    ///nessun bottone di aggiungi chat
    return null;
  }

  @override
  Color getColoreBackground() {
    ///colore blu chiaro
    return Colors.blue.shade100;
  }

  @override
  Color getColoreIcone(){
    return Colors.blue.shade200;
  }

  @override
  Text getTestoIntestazione(String? nomeUtente) {
    ///mostro le chat di: nome dell'utente
    return Text("Le Chat di: $nomeUtente", style: TextStyle(color: Colors.black));
  }

  @override
  RuoloChat getRuoloChatPage() {
    ///inserisco ruolo da osservatore in modo che non si possono scrivere nuovi
    ///messaggi nella chat selezionata
    return RuoloOsservatore();
  }

}