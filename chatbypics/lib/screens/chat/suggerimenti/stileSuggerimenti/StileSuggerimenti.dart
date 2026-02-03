import 'package:flutter/material.dart';

///Classe contenente le variabili statiche fissate riguardanti lo stile della
///barra contenente i pittogrammi suggeriti
///
abstract class StileSuggerimenti{

  ///altezza della barra
  static final double altezza=80;
  ///spaziatura della barra
  static const EdgeInsets padding=EdgeInsets.symmetric(vertical: 5, horizontal: 10);
  ///colore della barra
  static Color colore=Colors.yellow.shade100;
  ///allineamento del contenuto
  static const allineamentoImm=MainAxisAlignment.center;
  ///larghezza dello spazio
  static final double larghezzaSpazio=8;


}