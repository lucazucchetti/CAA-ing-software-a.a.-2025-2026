import 'package:flutter/material.dart';

///[SchermataErroreChat] classe che crea la schermata
///dove viene mostrata la schermata errore utente
///quando l'utente non è presente nel db
///
class SchermataErroreChat extends StatelessWidget {
  const SchermataErroreChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
          child: Text("ERRORE UTENTE")
      ),
    );
  }
}
