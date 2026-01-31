import 'package:chatbypics/screens/chat/RuoloChat.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'EliminazioneMessaggio/AvvisatoreSnackBar.dart';

///[RuoloOsservatore] ruolo della chat Osservatore, offre i ruoli per andare a
///costruire una chat dove l'utente può solo leggere i messaggi e non scrivere
///(CONCRETE ROLE)
///
class RuoloOsservatore implements RuoloChat{

  @override
  Widget buildSchermataComposizioneMessaggi(BuildContext context, String chatID, User utente) {

    ///mostro solo la scritta modalità osservatore
    return Center(
        child: Text("MODALITA' OSSERVATORE"),
    );
  }

  @override
  Future<void> gestisciEliminazione({required BuildContext context, required String chatID, required String messageID, required Timestamp? timestamp, required bool isMe}) async {

    ///se la pagina è attiva vado a mostrare che non posso eliminare il messaggio perchè sono
    ///in modalità lettura, se il messaggio è "mio" inteso come di chi sto vedendo la chat
    ///
    if(!isMe) return;

    if(context.mounted)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          AvvisatoreSnackBar().risposta("Solo Lettura", 3)
      );
    }
  }


  @override
  PreferredSizeWidget buildAppBar(String testo) {

    ///aggiungo nel testo (osservatore) e cambio il colore
    return AppBar(
      title: Text("$testo (osservatore)"),
      backgroundColor: Colors.blue.shade100,
    );

  }

}