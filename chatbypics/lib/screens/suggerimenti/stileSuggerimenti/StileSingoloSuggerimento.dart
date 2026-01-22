import 'package:flutter/material.dart';

//classe statica contenete lo stile per i singoliSuggerimenti ossia i singoli pittogrammi suggeriti
abstract class Stilesingolosuggerimento
{
  static const double altezzaContainer=50;
  static const double larghezzaContainer=50;
  static const EdgeInsets paddingImmagini=EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets paddingDellImm=EdgeInsets.all(3.0);
  static const BoxFit espansioneImm=BoxFit.contain;
  static final BoxDecoration boxImmagini=BoxDecoration(
    border: Border.all(color: Colors.orange, width: 2),
    borderRadius: BorderRadius.circular(8),
    color: Colors.white,
  );

}