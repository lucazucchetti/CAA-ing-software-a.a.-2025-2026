import 'package:chatbypics/screens/chat/RuoloChat.dart';
import 'package:chatbypics/screens/chat/SezioneLettura.dart';
import 'package:chatbypics/screens/chat/EliminazioneMessaggio/AvvisatoreRisultatoEliminazione.dart';
import 'package:chatbypics/screens/chat/EliminazioneMessaggio/BannerEliminazione.dart';
import 'package:chatbypics/screens/chat/SezioneScrittura.dart';
import 'package:chatbypics/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///Classe [ChatPage] è la classe che gestisce le singole chat
///necessita come parametri la [chatID] e il [chatName] per funzionare
///
class ChatPage extends StatefulWidget {

  ///[chatID] è l'id della singola chat da mostrare
  ///passato come parametro nel metodo costruttore
  ///
  final String chatID;
  ///[chatName] è il nome del destinatario della chat da mostrare
  ///pasato come parametro nel metodo costruttore
  ///
  final String chatName;

  ///[chatOwnerID] rappresenta l'id del proprietario della chat
  ///
  final String chatOwnerID;

  ///[ruolo] è l'interfaccia ruolo che la determianta chat può assumere,
  ///o solo lettura messaggi
  ///oppure lettura e scrittura messaggi
  ///(PATTERN PLAYER-ROLE)
  ///
  final RuoloChat ruolo;

  const ChatPage({
    super.key,
    required this.chatID,
    required this.chatName,
    required this.chatOwnerID,
    required this.ruolo,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();

}

///Classe [_ChatPageState] rappresenta lo stato della pagina chat
///
class _ChatPageState extends State<ChatPage> {

  ///[_auth] variabile che rappresenta l'istanza del DB utilizzato
  ///
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///[initState] Stato iniziale eseguito una volta all'apertura della chat
  ///
  @override
  void initState() {
    super.initState();

  }

  ///[build] metodo build principale che crea tutto
  ///
  @override
  Widget build(BuildContext context) {

    final User? utente=_auth.currentUser;
    if(utente==null)
    {
      return const Scaffold(
        body: Center(
            child: Text("ERRORE UTENTE")
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5), // Sfondo neutro
      appBar: AppBar(
        title: Text(widget.ruolo.stampaTitolo(widget.chatName)),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Column(
        children: [
          Expanded(

            ///mostra i messaggi
            child: SezioneLettura(
              chatID: widget.chatID,
              utenteProprietarioChat: widget.chatOwnerID,
              premutoElimina: (idMessaggio,timestamp) {
                widget.ruolo.gestisciEliminazione(
                    context: context,
                    chatID: widget.chatID,
                    messageID: idMessaggio,
                    timestamp: timestamp,
                    isMe: true
                );
              },
              utenteCheVisualizza: utente.uid,
            ),
          ),

          ///se in modalità scrittura mostro la parte della scrittura
          widget.ruolo.buildSchermataComposizioneMessaggi(context, widget.chatID, utente),
        ],
      ),
    );
  }

  ///[_eliminaMessaggio] funzione privata asincrona che permette l'eliminazione del
  ///messaggio quando viene selezionato se il messaggio è stato inviato al massimo
  ///30s fa
  ///
  /// richiede [cont] che è il context, [isMe] booleano che rappresenta se
  /// il messaggio è dell'utente che ha selezionato oppure no
  /// [messaggioId] stringa che è l'id del messaggio da eliminare
  /// [timestampMessaggio] è il Timestamp di invio del messaggio
  ///

}