import 'package:chatbypics/screens/chat/RuoloChat.dart';
import 'package:chatbypics/screens/chat/SchermateChat/SchermataErroreChat.dart';
import 'package:chatbypics/screens/chat/SezioneLettura.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

///Classe [ChatPage] è la classe che gestisce le singole chat
///utilizza un design pattern PLAYER-ROLE per poter diventare o
///chat di sola lettura(quando il Tutor vede le chat dei CCN)
///oppure chat anche di scrittura(quando l'utente apre la chat normalmente)
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

  ///[build] metodo build principale che crea tutto della chat
  ///
  @override
  Widget build(BuildContext context) {

    ///se non ho l'utente allora mostro errore chat
    final User? utente=_auth.currentUser;
    if(utente==null)
    {
      return SchermataErroreChat();
    }

    ///corpo della chat effettiva
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      ///costruisco in base al ruolo la appbar
      appBar: widget.ruolo.buildAppBar(widget.chatName),
      body: Column(
        children: [
          Expanded(

            ///mostra la sezione dei messaggi e imposto la
            ///eliminazione degli stessi in base al ruolo assunto
            child: SezioneLettura(
              chatID: widget.chatID,
              utenteProprietarioChat: widget.chatOwnerID,
              premutoElimina: (idMessaggio,timestamp,isMe) {
                widget.ruolo.gestisciEliminazione(
                    context: context,
                    chatID: widget.chatID,
                    messageID: idMessaggio,
                    timestamp: timestamp,
                    isMe: isMe
                );
              },
              utenteCheVisualizza: utente.uid,
            ),
          ),

          ///in base al ruolo imposto cosa mostrare nella sezione di
          ///composizione del messaggio
          widget.ruolo.buildSchermataComposizioneMessaggi(context, widget.chatID, utente),
        ],
      ),
    );
  }

}