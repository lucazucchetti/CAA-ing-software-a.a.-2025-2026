import 'package:chatbypics/screens/chat/RuoloChat.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'EliminazioneMessaggio/AvvisatoreRisultatoEliminazione.dart';

class RuoloOsservatore implements RuoloChat{

  @override
  // TODO: implement scrittore
  bool get scrittore => true;


  @override
  Widget buildSchermataComposizioneMessaggi(BuildContext context, String chatID, User utente) {
    return Center(
        child: Text("MODALITA OSSERVATORE"),
    );
  }

  @override
  Future<void> gestisciEliminazione({required BuildContext context, required String chatID, required String messageID, required Timestamp? timestamp, required bool isMe}) async {

    if(context.mounted)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          AvvisatoreRisultatoEliminazione().risposta("Solo Lettura", 3)
      );
    }
  }

  @override
  String stampaTitolo(String nomeChat) {
    // TODO: implement stampaTitolo
    return "$nomeChat (Osservatore)";
  }

}