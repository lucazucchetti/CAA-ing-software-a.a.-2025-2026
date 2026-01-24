import 'package:flutter/material.dart';

class GrigliaCategorie extends StatelessWidget {

  final List<Map<String, String>> visibleCategories;
  final Function(String,String) selezionato;

  const GrigliaCategorie({
    super.key,
    required this.visibleCategories,
    required this.selezionato,

  });

  @override
  Widget build(BuildContext context) {
    // Se la lista è vuota, potrebbe essere che sta ancora caricando o che l'utente non ha permessi.
    // Possiamo mostrare un caricamento se _visibleCategories è vuota ma _categories no.
    if (visibleCategories.isEmpty) {
      // Piccolo controllo: se l'utente ha davvero 0 permessi mostriamo "Nessuna categoria"
      // Per ora assumiamo sia caricamento iniziale
      // Se vuoi gestire il caso "0 permessi", servirebbe una variabile bool _permissionsLoaded
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      // USA LA LISTA FILTRATA
      itemCount: visibleCategories.length,
      itemBuilder: (context, index) {
        // PRENDI L'ELEMENTO DALLA LISTA FILTRATA
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
