import 'package:chatbypics/screens/chat/suggerimenti/stileSuggerimenti/StileSingoloSuggerimento.dart';
import 'package:flutter/material.dart';

///Classe [SingoloSuggerimento] che implementa il singolo suggerimento andando a stampare il singolo
///pittogramma e permettendogli di aggiornare i suggerimenti e la chat se premuto
///
class SingoloSuggerimento extends StatelessWidget {
  ///String[url] è l'url del pittogramma da suggerire
  final String url;
  ///VoidCallBack[funzioneAggiornaSuggerimenti] è la funzione da eseguire
  ///nel pittogramma quando viene premuto
  ///aggiorna i suggerimenti e la chat
  final VoidCallback funzioneAggiornaSuggerimenti;

  const SingoloSuggerimento ({
    super.key,
    required this.url,
    required this.funzioneAggiornaSuggerimenti,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: StileSingoloSuggerimento.paddingImmagini,
      child: GestureDetector(
        ///quando viene selezionato il pittogramma esegue la funzione passata
        onTap: funzioneAggiornaSuggerimenti,
        child: Container(
          width: StileSingoloSuggerimento.larghezzaContainer,
          height: StileSingoloSuggerimento.altezzaContainer,
          decoration: StileSingoloSuggerimento.boxImmagini,
          child: Padding(
            padding: StileSingoloSuggerimento.paddingDellImm,
            child: Image.network(url, fit: StileSingoloSuggerimento.espansioneImm),

          ),
        ),
      ),
    );
  }
}
