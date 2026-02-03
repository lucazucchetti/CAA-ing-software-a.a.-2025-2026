import 'package:flutter/material.dart';

///[GrigliaCategorie] classe che permette la costruzione della palette delle categorie
///dove l'utente può selezionare le categorie per vedere i pittogrammi contenuti
///
class GrigliaCategorie extends StatelessWidget {

  ///[visibleCategories] lista delle categorie visibili all'utente
  ///
  final List<Map<String, String>> visibleCategories;

  ///[selezionato] la funzione da eseguire quando seleziono una categoria quindi passa
  ///il nome della categoria e il suo identificativo per procedere alla ricerca dei suoi
  ///pittogrammi
  ///
  final Function(String,String) selezionato;

  const GrigliaCategorie({
    super.key,
    required this.visibleCategories,
    required this.selezionato,

  });

  @override
  Widget build(BuildContext context) {

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),


      itemCount: visibleCategories.length,
      itemBuilder: (context, index) {

        final cat = visibleCategories[index];

        return GestureDetector(
          onTap: () => selezionato(cat['name']!, cat['term']!),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple.shade100, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  cat['img']!,
                  height: 50,
                  loadingBuilder: (ctx, child, p) =>
                  p == null
                      ? child
                      : const SizedBox(height: 50),
                  errorBuilder: (ctx, err, st) =>
                  const Icon(Icons.folder, size: 50, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
