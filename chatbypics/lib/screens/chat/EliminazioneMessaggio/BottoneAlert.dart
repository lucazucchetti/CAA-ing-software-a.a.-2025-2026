import 'package:chatbypics/screens/chat/EliminazioneMessaggio/StileBannerEliminazione/StileBottoneAlert.dart';
import 'package:flutter/material.dart';

///Classe che costruisce i singoli bottoni per la richiesta di eliminazione di un
///messaggio
///
class BottoneAlert extends StatelessWidget {

  const BottoneAlert({
    super.key,
    required this.risposta
  });

  ///variabile booleana [risposta] indica la risposta positiva oppure negativa
  ///che il bottone dovrà mostrare e ritornare quando premuto
  final bool risposta;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      ///in base al tipo di risposta passata decide il comportamento
      onPressed: () => Navigator.pop(context, risposta),
      child: risposta ? StileBottoneAlert.rispostaPositiva : StileBottoneAlert.rispostaNegativa,
    );
  }
}
