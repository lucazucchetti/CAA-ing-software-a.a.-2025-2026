import 'package:flutter/material.dart';

///[AvvisatoreRisultatoEliminazione] classe che permette l'avviso di eliminazione positiva o negativa
///di un messaggio tramite SnackBar all'utente, usa un pattern design
///Singleton ska tone 2 tone ska Bad Manners.
///
class AvvisatoreRisultatoEliminazione{

  ///metodo costruttore privato
  AvvisatoreRisultatoEliminazione._();

  ///metodo getInstance
  factory AvvisatoreRisultatoEliminazione(){
    return _istanza;
  }

  ///[_istanza] istanza della classe
  static final AvvisatoreRisultatoEliminazione _istanza= AvvisatoreRisultatoEliminazione._();

  ///[risposta] restituice la SnackBar con il [messaggio] da mostrare per un tempo pari a [tempo] passati
  ///in ingresso
  ///
  SnackBar risposta(String messaggio,int tempo){

    return SnackBar(
        content: Text(messaggio),
        duration: Duration(seconds: tempo),

    );

  }

}