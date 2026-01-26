import 'package:chatbypics/screens/chat/RuoloChat.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/chat_service.dart';
import 'EliminazioneMessaggio/AvvisatoreRisultatoEliminazione.dart';
import 'EliminazioneMessaggio/BannerEliminazione.dart';
import 'SezioneScrittura.dart';

///[RuoloScrittore]
///
class RuoloScrittore implements RuoloChat {

  @override
  bool get scrittore => true;


  @override
  Widget buildSchermataComposizioneMessaggi(BuildContext context, String chatID, User utente) {
    return SezioneScrittura(
      chatID: chatID,
      utente: utente,
    );
  }

  @override
  Future<void> gestisciEliminazione({required BuildContext context, required String chatID, required String messageID, required Timestamp? timestamp, required bool isMe}) async {

    ///se il messaggio non è mio allora esco
    if (!isMe) return;


    ///calcolo quando è stato inviato il messaggio e quando è stata fatta la richiesta di
    ///eliminazione.
    ///se non ho il timestamp di invio ancora allora lo imposto ad ora
    ///
    DateTime dataInvio = timestamp?.toDate() ?? DateTime.now();
    DateTime dataDomanda = DateTime.now();

    ///se il messaggio è troppo vecchio allora dico all'utente che non si può eliminare
    if (dataDomanda
        .difference(dataInvio)
        .inSeconds > 30) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            AvvisatoreRisultatoEliminazione().risposta("Impossibile eliminare il messaggio, tempo scaduto", 3));
      }

      return;
    }
    bool risp;

    ///creo il banner di richiesta di eliminazione
    risp = await BannerEliminazione.mostraBanner(context: context);

    ///se la risposta è affermativa allora elimino e stampo la SnackBar che avvisa
    ///l'utente della cancellazione corretta del messaggio
    if (risp) {
      try {
        await ChatService().cancellaMessaggio(chatID, messageID);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              AvvisatoreRisultatoEliminazione().risposta(
                  "Messaggio eliminato!", 3)
          );
        }
      }
      catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              AvvisatoreRisultatoEliminazione().risposta(
                  "Impossibile cancellare a causa di un errore riporva più tardi", 3)
          );
        }
      }
    }
  }

  @override
  String stampaTitolo(String nomeChat) {
    // TODO: implement stampaTitolo
    return nomeChat;
  }
  
}