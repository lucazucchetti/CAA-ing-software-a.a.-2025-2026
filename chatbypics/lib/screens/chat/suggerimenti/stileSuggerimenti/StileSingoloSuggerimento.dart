import 'package:flutter/material.dart';

///Classe astratta che contiene le variabili statiche fissate riguardanti lo stile
///dei singoli blocchi utilizzati per rappresentare i suggerimenti dei pittogrammi
///
abstract class StileSingoloSuggerimento
{
  ///altezza Container
  static const double altezzaContainer=50;
  ///larghezza Container
  static const double larghezzaContainer=50;
  ///spaziarura padding Pittogrammi
  static const EdgeInsets paddingImmagini=EdgeInsets.symmetric(horizontal: 4);
  ///padding del singolo Pittogramma
  static const EdgeInsets paddingDellImm=EdgeInsets.all(3.0);
  ///BoxFir del pittogramma
  static const BoxFit espansioneImm=BoxFit.contain;
  ///boxDecoration della singola immagine
  static final BoxDecoration boxImmagini=BoxDecoration(
    border: Border.all(color: Colors.orange, width: 2),
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  );

}