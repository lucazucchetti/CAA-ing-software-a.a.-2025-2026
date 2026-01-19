import 'dart:convert';
import 'package:http/http.dart' as http;

class PictogramService {
  // URL base delle API di Arasaac
  final String _baseUrl = "https://api.arasaac.org/api/pictograms";
  final String _imageBaseUrl = "https://static.arasaac.org/pictograms";

  // Funzione per cercare pittogrammi in ITALIANO
  Future<List<Map<String, String>>> searchPictograms(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // 1. Chiamata all'API di ricerca (in italiano 'it')
      final url = Uri.parse('$_baseUrl/it/search/$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 2. Decodifica la risposta JSON
        List<dynamic> data = json.decode(response.body);

        // 3. Trasforma i dati in una lista semplice per la nostra app
        return data.map<Map<String, String>>((pic) {
          int id = pic['_id']; // L'ID univoco del pittogramma
          
          // Cerchiamo la parola chiave più adatta (spesso è la prima)
          // A volte l'API restituisce keywords diverse, prendiamo la stringa cercata o la prima disponibile
          String label = query; 
          if (pic['keywords'] != null && (pic['keywords'] as List).isNotEmpty) {
             label = pic['keywords'][0]['keyword'];
          }

          return {
            'id': id.toString(),
            // Costruiamo l'URL dell'immagine (300px è una buona risoluzione)
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