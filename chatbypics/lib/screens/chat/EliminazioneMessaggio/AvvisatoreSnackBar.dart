import 'package:flutter/material.dart';

///[AvvisatoreSnackBar] classe che permette l'avviso tramite SnackBar all'utente,
///usa un pattern design
///Singleton ska tone 2 tone ska Bad Manners.
///
class AvvisatoreSnackBar{

  ///metodo costruttore privato
  AvvisatoreSnackBar._();

  ///metodo getInstance
  factory AvvisatoreSnackBar(){
    return _istanza;
  }

  ///[_istanza] istanza della classe
  static final AvvisatoreSnackBar _istanza= AvvisatoreSnackBar._();

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