import 'package:flutter/material.dart';

///Classe astratta che contiene le variabili statiche fissate riguardanti lo stile
///del BannerEliminazione per eliminare i messaggi
///
abstract class StileBannerEliminazione
{
  ///[richiesta] è il testo che deve essere mostrato quando si apre il banner
  static const Text richiesta=Text("Vuoi eliminare il messaggio selezionato?");
}