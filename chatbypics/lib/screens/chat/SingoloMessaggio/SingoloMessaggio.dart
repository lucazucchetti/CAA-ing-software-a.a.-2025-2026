import 'package:chatbypics/screens/chat/SingoloMessaggio/StileSingoloMessaggio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../PreferenzeChat.dart';

///[SingoloMessaggio] classe che permette la creazione dei singoli messaggi
///
class SingoloMessaggio extends StatelessWidget {

  ///[isMe] variabile che rappresenta se il messaggio è stato inviato dall'utente o no
  ///
  final bool isMe;

  ///[messaggioId] id del messaggio da stampare
  ///
  final String messaggioId;

  ///[timestampMessaggio] timestamp del messagio da stampare
  ///
  final Timestamp? timestampMessaggio;

  ///[fullSentence] la descrizione dei pittogrammi che compongono il messaggio
  ///
  final String fullSentence;

  ///[pictograms] lista dei pittogrammi che compongono il messaggio
  ///
  final List<dynamic> pictograms;

  ///[impostazioni] le preferenze chat per l'utente
  ///
  final PreferenzeChat impostazioni;

  ///[cliccato] funzione da eseguire quando è cliccato una volta il messaggio
  ///(lettura vocale)
  ///
  final Function(String) cliccato;

  ///[premuto] funzione da eseguire quando è premuto il messaggio
  ///(eliminazione)
  ///
  final Function(BuildContext, bool, String, Timestamp?) premuto;



  const SingoloMessaggio({
    super.key,
    required this.isMe,
    required this.messaggioId,
    required this.timestampMessaggio,
    required this.fullSentence,
    required this.pictograms,
    required this.impostazioni,
    required this.cliccato,
    required this.premuto,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///se messaggio premuto a lungo chiede se vuole eliminare il messaggio se è
      ///stato inviato dall'utente
      ///
        onLongPress:()=> premuto(context, isMe, messaggioId, timestampMessaggio),
        onTap:()=> cliccato(fullSentence),

        child: Align(

          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

          child: Container(

            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * StileSingoloMessaggio.constParContainer),

            margin: StileSingoloMessaggio.marginContainer,
            padding: StileSingoloMessaggio.paddingContainer,
            decoration: BoxDecoration(

              color: isMe ? StileSingoloMessaggio.coloreMioMessaggio : StileSingoloMessaggio.coloreAltroMessagio,
              borderRadius: StileSingoloMessaggio.borderRadiusMess,

            ),
            child: Wrap(

              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: pictograms.map((pic) {

                double totalWidth = MediaQuery.of(context).size.width * 0.7;
                double itemWidth = (totalWidth / _getItemsPerRow()) - 12;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(pic['imageUrl'], width: itemWidth, height: itemWidth, fit: BoxFit.contain),
                    if (impostazioni.showLabels)
                      Text(pic['description'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                );
              }).toList(),

            ),
          ),
        )
    );
  }

  ///[_getItemsPerRow] metodo che permette di calcolare quanti pittogrami in una riga ci possono
  ///stare date le impostazioni preferenziali dell'utente
  ///
  int _getItemsPerRow(){

    int num;

    num = impostazioni.gridSize.toInt();
    if (num < 1) num = 1;

    return num;
  }
}
