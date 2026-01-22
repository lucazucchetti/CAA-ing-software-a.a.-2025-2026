import 'dart:convert';
import 'package:http/http.dart' as http;

class PictogramService {
  // URL base delle API di Arasaac
  final String _baseUrl = "https://api.arasaac.org/api/pictograms";
  final String _imageBaseUrl = "https://static.arasaac.org/pictograms";

  // --- 1. BLACKLIST: Parole chiave da escludere ---
  final List<String> _blacklist = [
    // Sfera sessuale / anatomica intima
    "sesso", "masturbarsi", "pene", "vagina", "vulva", "testicoli", "nudo", "seno", "seni",
    "coito", "erotico", "preservativo", "incesto", "orgasmo", "genitali",
    "porno", "sperma",
    // Sfera violenza / crimine
    "uccidere", "picchiare", "violenza", "sangue", "abuso", "armi", "pistola",
    "coltello", "suicidio", "droga", "cocaina", "eroina", "ubriaco", "alcol",
    // Altro
    "feci", "urine"
  ];

  // Funzione per cercare pittogrammi in italiano
  Future<List<Map<String, String>>> searchPictograms(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse('$_baseUrl/it/search/$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // --- 2. FILTRAGGIO E LIMITAZIONE ---
        var filteredData = data.where((pic) {
          // Controllo se tra le keyword del pittogramma c'è qualcosa di vietato
          if (pic['keywords'] != null) {
            for (var k in pic['keywords']) {
              String keyword = k['keyword'].toString().toLowerCase();

              // Se la keyword contiene una parola della blacklist, scartiamo il pittogramma
              if (_blacklist.any((badWord) => keyword.contains(badWord))) {
                return false;
              }
            }
          }
          return true; // Se passa i controlli, lo teniamo
        });

        // --- 3. LIMITIAMO IL NUMERO DI RISULTATI ---
        // Prendiamo solo i primi 30 risultati per evitare confusione
        var limitedData = filteredData.take(30);

        return limitedData.map<Map<String, String>>((pic) {
          int id = pic['_id'];

          String label = query;
          if (pic['keywords'] != null && (pic['keywords'] as List).isNotEmpty) {
            label = pic['keywords'][0]['keyword'];
          }

          return {
            'id': id.toString(),
            'url': '$_imageBaseUrl/$id/${id}_300.png',
            'desc': label,
          };
        }).toList();

      } else {
        print("Errore API Arasaac: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Eccezione durante ricerca pittogrammi: $e");
      return [];
    }
  }

}