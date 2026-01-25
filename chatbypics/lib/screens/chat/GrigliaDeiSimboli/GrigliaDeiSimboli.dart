import 'package:flutter/material.dart';

///[GrigliaDeiSimboli] classe che permette la costruzione della palette di scelta dei pittogrammi
///di una determinata categoria
///
class GrigliaDeiSimboli extends StatelessWidget {

  ///[simboli] la lista dei simboli da mostrare
  final List<Map<String, String>> simboli;

  /// Funzione da chiamare al click del pittogramma: passa il  pittogramma stesso(url, descrizione)
  final Function(String, String) selezionato;

  const GrigliaDeiSimboli({
    super.key,
    required this.simboli,
    required this.selezionato,
  });

  @override
  Widget build(BuildContext context) {
    if (simboli.isEmpty) {
      return const Center(child: Text("Nessun simbolo trovato."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: simboli.length,
      itemBuilder: (context, index) {
        final pic = simboli[index];
        return GestureDetector(
          onTap: () {
            ///se pittogramma schiacciato
            ///aggiungo il pittogramma selezionato e aggiorno i suggerimenti
            selezionato(pic['url']!, pic['desc']!);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.network(pic['url']!, fit: BoxFit.contain),
                  ),
                ),
                Text(
                  pic['desc']!,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
        },
      );
  }
}
