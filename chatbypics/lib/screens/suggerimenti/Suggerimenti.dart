import 'package:chatbypics/screens/suggerimenti/SingoloSuggerimento.dart';
import 'package:chatbypics/screens/suggerimenti/stileSuggerimenti/StileSuggerimenti.dart';
import 'package:flutter/material.dart';

///Classe che implementa la barra dei suggerimenti
///
class Suggerimenti extends StatelessWidget {

  ///final List\<String>[dati] lista degli URL dei pittogrammi da suggerire nella barra,
  ///passato nel costruttore
  final List<String> dati;
  ///final Function(String)[selezionato] è la funzione da eseguire quando si schiacciano i
  ///pittogrammi suggeriti ha come parametro l'URL del pittogramma selezionato, viene passato nel costruttore
  final Function(String) selezionato;

  const Suggerimenti({
    super.key,
    required this.dati,
    required this.selezionato,
  });

  @override
  Widget build(BuildContext context) {

    ///se non c'è nessun suggerimento disponibile allora non mostrare la barra
    if (dati.isEmpty) return const SizedBox.shrink();

    return Container(
      height: StileSuggerimenti.altezza,
      padding: StileSuggerimenti.padding,
      color: StileSuggerimenti.colore,
      child: Row(
        mainAxisAlignment: StileSuggerimenti.allineamentoImm,
        children: [
          SizedBox(width: StileSuggerimenti.larghezzaSpazio,),
          ///per ogni pittogramma da suggerire creo le singole strutture
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
