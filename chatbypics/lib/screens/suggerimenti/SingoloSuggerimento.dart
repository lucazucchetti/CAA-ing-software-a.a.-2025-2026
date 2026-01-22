import 'package:chatbypics/screens/suggerimenti/stileSuggerimenti/StileSingoloSuggerimento.dart';
import 'package:flutter/material.dart';

class SingoloSuggerimento extends StatelessWidget {
  final String url;
  final VoidCallback funzioneAggiornaSuggerimenti;

  const SingoloSuggerimento ({
    super.key,
    required this.url,
    required this.funzioneAggiornaSuggerimenti,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Stilesingolosuggerimento.paddingImmagini,
      child: GestureDetector(
        onTap: funzioneAggiornaSuggerimenti, //funzione sopra
        child: Container(
          width: Stilesingolosuggerimento.larghezzaContainer,
          height: Stilesingolosuggerimento.altezzaContainer,
          decoration: Stilesingolosuggerimento.boxImmagini,
          child: Padding(
            padding: Stilesingolosuggerimento.paddingDellImm,
            child: Image.network(url, fit: Stilesingolosuggerimento.espansioneImm),
          ),
        ),
      ),
    );
  }
}
