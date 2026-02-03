import 'package:flutter/material.dart';

import '../chat/RuoloChat.dart';

///[RuoloLista] è l'interfaccia che permette di implementare la costruzione degli elementi
///necessari a mostrare la lista delle chat dell'utente, i due ruoli sono
///ListaTerzi se si accede alla lista delle chat di un utente gestito da parte del Tutor che sta usando l'app
///ListaMia se la lista delle chat è dell'utente che sta usando l'app
///
///usa il pattern: player-role
///(Abstracrt role)
abstract class RuoloLista{

  ///[buildBottone] metodo che permette di costruire il bottone aggiungi chat alla lista
  ///se è ListaTerzi creerà il bottone altrimenti restuituirà null
  ///
  Widget? buildBottone(BuildContext context);

  ///[getColoreBackground] metodo che in base al ruolo determina il colore della barra
  ///di informazione sugli utenti
  ///
  Color getColoreBackground();

  ///[getColoreIcone] metodo che in base al ruolo determina il colore della icona utente
  ///
  Color getColoreIcone();

  ///[getTestoIntestazione] metodo che in base al nome utente passato restituisce il testo
  ///da inserire come child all'interno della barra di informazione sugli utenti,
  ///[nomeUtente] è il parametro che è richiesto in ingresso e rappresenta il nome dell'utente
  ///da mostrare nella barra, il parametro può anche essere null, questo perchè per il
  ///ruolo listaMia il testo che sarà restituito conterrà un riferimento del tipo la tua chat
  Text getTestoIntestazione(String? nomeUtente);

  ///[getRuoloChatPage] metodo che in base al ruolo nella lista restituisce il ruolo da usare nella
  ///chat quindi determina se si può solo leggere nella chat selezionata oppure anche scrivere
  ///
  RuoloChat getRuoloChatPage();

}