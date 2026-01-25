import 'package:flutter/material.dart';
import 'package:chatbypics/screens/chat/GrigliaCategorie/GrigliaCategorie.dart';
import 'package:chatbypics/screens/chat/GrigliaDeiSimboli/GrigliaDeiSimboli.dart';

///[PersistentPicker] classe che permette di andare a costruire la sezione
///incaricata nel mostrare la parte di selezione dei pittogrammi per scrittura all'utente
///
class PersistentPicker extends StatelessWidget {

  ///[mostraCategorie] mostra schermata categorie se true altrimenti i simboli
  ///
  final bool mostraCategorie;

  ///[isLoading] se true mostra il caricamento
  ///
  final bool isLoading;

  ///[currentCategoryName] la categoria selezionata
  ///
  final String currentCategoryName;

  ///[searchController] il searchController per la ricerca di pittogrammi
  ///
  final TextEditingController searchController;

  ///[visibleCategories] le categorie visibili all'utente
  ///
  final List<Map<String,String>> visibleCategories;

  ///[currentSymbols] simboli mostrati al momento
  ///
  final List<Map<String, String>> currentSymbols;

  ///[vaiACategorie] azione per ritornare alle categorie
  ///
  final VoidCallback vaiACategorie;

  ///[ricerca] funzione per ricercare un pittogramma
  ///
  final VoidCallback ricerca;

  ///[chiudi] funzione per chiudere
  ///
  final VoidCallback chiudi;

  ///[clickCategorie] funzione se seleziono una categoria(mostra i pittogrammi)
  ///
  final Function(String nome,String termine) clickCategorie;

  ///[clickPittogramma] funzione se si schiaccia su  un simbolo
  ///
  final Function(String url,String descrizione) clickPittogramma;

  const PersistentPicker({

    super.key,
    required this.mostraCategorie,
    ///per default imposto il loadinf e il categoriname
    this.isLoading = false,
    this.currentCategoryName = "",
    required this.searchController,
    required this.visibleCategories,
    required this.currentSymbols,
    required this.vaiACategorie,
    required this.ricerca,
    required this.chiudi,
    required this.clickCategorie,
    required this.clickPittogramma,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      color: Colors.white,
      child: Column(
        children: [

          ///costruzione della barra ricerca
          _buildBarraRicerca(),

          ///mostra il nome della categoria selezionata se nella schermata categorie
          if (!mostraCategorie && !isLoading && currentCategoryName.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              color: Colors.deepPurple.shade50,
              child: Text(
                currentCategoryName,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade900),
              ),
            ),

          ///mostra la schermata categorie oppure pittogrammi in base a dove l'utente si trova
          ///
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : mostraCategorie
                ? _buildCategoriesGrid()
                : _buildSymbolsGrid(),
          ),
        ],
      ),
    );
  }


  ///[_buildBarraRicerca] metodo che restituisce la barra di ricerca dei pittogrammi
  ///
  Widget _buildBarraRicerca() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Tasto Indietro
          if (!mostraCategorie)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
              onPressed: vaiACategorie,
            ),

          Expanded(
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Cerca simbolo...",
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.deepPurple),
                  ///quando schiaccio l'icona di ricerca allora ricerca
                  onPressed: ricerca,
                ),
              ),
              ///anche se si fa da tastiera invio fa la ricerca
              onSubmitted: (_) => ricerca,
            ),
          ),

          ///Icona che chiude
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            ///se premuta chiude
            onPressed: chiudi,
          ),
        ],
      ),
    );
  }

  ///[_buildCategoriesGrid] metodo che costruisce la schermata di mostra categorie
  ///
  Widget _buildCategoriesGrid() {

    return GrigliaCategorie(
      visibleCategories: visibleCategories,
      selezionato: (nome, termine) {
        clickCategorie(nome, termine);
      },
    );
  }

  ///[_buildSymbolsGrid] metodo che costruisce la schermata di mostra pittogrammi
  ///
  Widget _buildSymbolsGrid() {

    return GrigliaDeiSimboli(
      simboli: currentSymbols,
      selezionato: (url, descrizione) {
        clickPittogramma(url, descrizione);
      },
    );
  }
}