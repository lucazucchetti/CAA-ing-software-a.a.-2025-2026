import 'package:flutter/material.dart';

///Classe astratta che contiene le variabili statiche fissate riguardanti lo stile
///dei Bottoni del BannerEliminazione per eliminare i messaggi
///
abstract class StileBottoneAlert
{
  ///[rispostaNegativa] è il testo e la grafica della risposta negativa
  static const Text rispostaNegativa=Text("Annulla",style: TextStyle(color: Colors.grey));
  ///[rispostaPositiva] è il testo e la grafica della risposta positiva
  static const Text rispostaPositiva=Text("Elimina",style: TextStyle(color: Colors.red));
}