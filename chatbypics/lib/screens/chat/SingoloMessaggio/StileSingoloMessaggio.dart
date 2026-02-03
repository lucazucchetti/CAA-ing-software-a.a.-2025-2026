import 'package:flutter/material.dart';

///[StileSingoloMessaggio] classe astratta che contiene le variabili
///utilizzate nella grafica dei singoli messaggi
///
abstract class StileSingoloMessaggio{

  ///[constParContainer] fattore per il constraint del container
  ///
  static const double constParContainer=0.8;

  ///[marginContainer] rappresenta il margin del container
  ///
  static const EdgeInsets marginContainer=EdgeInsets.symmetric(vertical: 8);

  ///[paddingContainer] padding del container
  ///
  static const EdgeInsets paddingContainer=EdgeInsets.all(12);

  ///[coloreMioMessaggio] colore del messaggio se è stato inviato dall'utente
  ///
  static final Color? coloreMioMessaggio=Colors.lightGreen[100];

  ///[coloreAltroMessagio] colore del messaggio se è stato inviato dall'altro
  ///
  static final Color coloreAltroMessagio=Colors.white;

  ///[borderRadiusMess] borderRadius del singolo messaggio
  ///
  static final BorderRadius borderRadiusMess=BorderRadius.circular(15);




}
