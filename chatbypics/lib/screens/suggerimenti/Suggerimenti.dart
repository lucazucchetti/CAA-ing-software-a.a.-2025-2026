import 'package:chatbypics/screens/suggerimenti/SingoloSuggerimento.dart';
import 'package:chatbypics/screens/suggerimenti/stileSuggerimenti/StileSuggerimenti.dart';
import 'package:flutter/material.dart';

class Suggerimenti extends StatelessWidget {

  final List<String> dati;
  final Function(String) selezionato;

  const Suggerimenti({
    super.key,
    required this.dati,
    required this.selezionato,
  });


  @override
  Widget build(BuildContext context) {

    if (dati.isEmpty) return const SizedBox.shrink();

    return Container(
      height: StileSuggerimenti.altezza,
      padding: StileSuggerimenti.padding,
      color: StileSuggerimenti.colore,
      child: Row(
        mainAxisAlignment: StileSuggerimenti.allineamentoImm,
        children: [
          SizedBox(width: StileSuggerimenti.larghezzaSpazio,),
          //CREAZIONE DEI SINGOLI SUGGERIMENTI
          for (var url in dati)
            SingoloSuggerimento(
                url: url,
                funzioneAggiornaSuggerimenti:()=>selezionato(url),
            ),
        ],
      ),
    );
  }
}
