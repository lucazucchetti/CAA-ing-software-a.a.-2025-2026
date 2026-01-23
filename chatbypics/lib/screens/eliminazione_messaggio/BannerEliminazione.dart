import 'package:chatbypics/screens/eliminazione_messaggio/BottoneAlert.dart';
import 'package:chatbypics/screens/eliminazione_messaggio/StileBannerEliminazione.dart';
import 'package:flutter/material.dart';

///Classe che costruisce il banner di eliminazione di un messaggio grazie al suo metodo
///
abstract class BannerEliminazione{

  ///[mostraBanner] è il metodo che permette l'effettiva costruzione del alert che richiede
  ///se eliminare o no il messaggio selezionato, come risultato avrà un booleano
  ///che rappresenta la risposta data, richiede il contesto in entrata
  ///
  static Future<bool> mostraBanner({required BuildContext context}) async {
    bool risposta=false;
    risposta = await showDialog(
      context: context,
      builder: (contesto) => AlertDialog(
        title: StileBannerEliminazione.richiesta,
        actions: [
          BottoneAlert(risposta: false),
          BottoneAlert(risposta: true),
        ],
      ),
    ) ?? false;

    return risposta;
  }
}
