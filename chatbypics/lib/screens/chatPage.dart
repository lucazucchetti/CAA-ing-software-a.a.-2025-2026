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

  ///[scrittura] rappresenta il permesso o no di poter inviare i messaggi
  ///
  final bool scrittura;

  ///[chatOwnerID] rappresenta l'id del proprietario della chat
  ///
  final String chatOwnerID;

  const ChatPage({
    super.key,
    required this.chatID,
    required this.chatName,
    required this.scrittura,
    required this.chatOwnerID
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
        title: widget.scrittura ? Text(widget.chatName) : Text(widget.chatName+"(Osservatore)"),
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
                _eliminaMessaggio(context, true, idMessaggio, timestamp);
              },
              utenteCheVisualizza: utente.uid,
            ),
          ),

          ///se in modalità scrittura mostro la parte della scrittura
          if(widget.scrittura)
            SezioneScrittura(chatID: widget.chatID, utente: utente)
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
  Future<void> _eliminaMessaggio(BuildContext cont, bool isMe, String messaggioId, Timestamp? timestampMessaggio) async{

    if (!widget.scrittura) {
      ScaffoldMessenger.of(cont).showSnackBar(
          AvvisatoreRisultatoEliminazione().risposta("Modalità lettura", 2));
      return;
    }

    ///se il messaggio non è mio allora esco
    if (!isMe) return;


    ///calcolo quando è stato inviato il messaggio e quando è stata fatta la richiesta di
    ///eliminazione.
    ///se non ho il timestamp di invio ancora allora lo imposto ad ora
    ///
    DateTime dataInvio = timestampMessaggio?.toDate() ?? DateTime.now();
    DateTime dataDomanda = DateTime.now();

    ///se il messaggio è troppo vecchio allora dico all'utente che non si può eliminare
    if (dataDomanda
        .difference(dataInvio)
        .inSeconds > 30) {
      if (cont.mounted) {
        ScaffoldMessenger.of(cont).showSnackBar(
            AvvisatoreRisultatoEliminazione().risposta(
                "Impossibile eliminare il messaggio, tempo scaduto", 3)
        );
      }

      return;
    }
    bool risp;

    ///creo il banner di richiesta di eliminazione
    risp = await BannerEliminazione.mostraBanner(context: cont);

    ///se la risposta è affermativa allora elimino e stampo la SnackBar che avvisa
    ///l'utente della cancellazione corretta del messaggio
    if (risp) {
      try {
        await ChatService().cancellaMessaggio(widget.chatID, messaggioId);
        if (cont.mounted) {
          ScaffoldMessenger.of(cont).showSnackBar(
              AvvisatoreRisultatoEliminazione().risposta(
                  "Messaggio eliminato!", 3)
          );
        }
      }
      catch (e) {
        print("errore nella cancellazione $e");
      }
    }
  }

}