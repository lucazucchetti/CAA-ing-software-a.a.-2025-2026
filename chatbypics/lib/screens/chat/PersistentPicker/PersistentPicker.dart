import 'package:flutter/material.dart';

class PersistentPicker extends StatelessWidget {

  final bool isCategoryView;
  final Widget categoriesGrid;
  final Widget symbolsGrid;

  final VoidCallback onBackToCategories; // Tasto indietro
  final Function(String) onSearchChanged; // Digitazione nella barra ricerca
  final TextEditingController searchController; // Controller per pulire il testo se serve


  const PersistentPicker({
    super.key,
    required this.isCategoryView,
    required this.categoriesGrid,
    required this.symbolsGrid,
    required this.onBackToCategories,
    required this.onSearchChanged,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Altezza fissa del pannello
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // --- BARRA SUPERIORE (Ricerca + Indietro) ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Tasto INDIETRO (Visibile solo se NON siamo nella home delle categorie)
                if (!isCategoryView)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                    onPressed: onBackToCategories,
                  ),

                // BARRA DI RICERCA
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Cerca simbolo...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENUTO (Griglia Categorie o Griglia Simboli) ---
          Expanded(
            child: isCategoryView ? categoriesGrid : symbolsGrid,
          ),
        ],
      ),
    );
  }
}
