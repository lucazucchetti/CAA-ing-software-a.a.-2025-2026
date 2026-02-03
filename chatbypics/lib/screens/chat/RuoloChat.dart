import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///[RuoloChat] interfaccia che implementa i metodi necessari per gestire i widget chatPage
///in base al tipo di chat da visualizzare, le modalità fino ad ora sono:
///Osservatore (può solo vedere i messaggi)
///Scrittore (può anche mandare i messaggi)
///Implementa il pattern
///PLAYER-ROLE
///(ABSTRACT ROLE)
///
abstract class RuoloChat
{

  ///[buildSchermataComposizioneMessaggi] metodo che permette di mostrare la schermata
  ///della chat in base al ruolo in ingresso ha il contesto su do dove lavorare[context]
  ///l'id della chat [chatID] e l'istanza del db dell'utente [utente]
  ///
  Widget buildSchermataComposizioneMessaggi(BuildContext context, String chatID, User utente);

  ///[gestisciEliminazione] metodo asincrona che permette l'eliminazione del
  ///messaggio quando viene selezionato se il messaggio è stato inviato al massimo
  ///30s fa
  ///
  /// richiede [context] che è il context, [isMe] booleano che rappresenta se
  /// il messaggio è dell'utente che ha selezionato oppure no
  /// [messageID] stringa che è l'id del messaggio da eliminare
  /// [timestamp] è il Timestamp di invio del messaggio [chatID] id della chat
  /// del messaggio
  ///
  Future<void> gestisciEliminazione({
    required BuildContext context,
    required String chatID,
    required String messageID,
    required Timestamp? timestamp,
    required bool isMe,
  });

  ///[buildAppBar] metodo necessario a costruire l'appBar della chat
  ///in ingresso ha il testo da inserire nell'appbar [testo]
  ///
  PreferredSizeWidget buildAppBar(String testo);

}

