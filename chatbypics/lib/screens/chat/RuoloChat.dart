import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class RuoloChat
{
  ///[scrittore] variabile booleana che indica se si può scrivere o no
  ///
  bool get scrittore;

  ///[stampaTitolo] Metodo che permette di stampare il titolo corretto nell'appBar
  ///della chat
  ///
  String stampaTitolo(String nomeChat);

  ///[buildSchermataComposizioneMessaggi] metodo che permette di mostrare la schermata
  ///della chat in base al ruolo
  ///
  Widget buildSchermataComposizioneMessaggi(BuildContext context, String chatID, User utente);

  ///[gestisciEliminazione] metodo che permette l'eliminazione di un determianto
  ///messaggio
  ///
  Future<void> gestisciEliminazione({
    required BuildContext context,
    required String chatID,
    required String messageID,
    required Timestamp? timestamp,
    required bool isMe,
  });

}

