import 'package:chatbypics/screens/chat/InputArea/StileInputArea.dart';
import 'package:flutter/material.dart';

///[InputArea] Classe che costruisce il
///Container contenente la barra inferiore della chat per mostrare o no
///il picker pittogrammi
///
class InputArea extends StatelessWidget {

  ///[isPickerVisible] booleano che rappresenta se mostrare o no la barra
  ///
  final bool isPickerVisible;

  ///[cliccato] è la funzione da passare per fare in
  ///modo che il pulsante di mostra funzioni
  final VoidCallback cliccato;

  const InputArea({
    super.key,
    required this.cliccato,
    required this.isPickerVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: StileInputArea.paddingContainer,
        color: StileInputArea.coloreContainer,
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPickerVisible ? Colors.grey.shade400 : Colors
                    .deepPurple,
                foregroundColor: Colors.white,
                elevation: 0,

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.zero,
              ),
              icon: Icon(
                  isPickerVisible ? Icons.keyboard_arrow_down : Icons
                      .grid_view_rounded,
                  size: 20
              ),
              label: Text(
                  isPickerVisible ? "Nascondi" : "Apri Simboli",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)
              ),
              onPressed: cliccato,
            )
          )
        )

    );
  }
}
