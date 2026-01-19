import 'package:cloud_firestore/cloud_firestore.dart';

class PreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Chiavi per le preferenze (per evitare errori di battitura)
  static const String keyDarkMode = 'isDarkMode';
  static const String keyShowLabels = 'showLabels';
  static const String keyAutoRead = 'autoReadMessages';
  static const String keyGridSize = 'gridSize';

  // Recupera tutte le preferenze dell'utente
  Future<Map<String, dynamic>> getUserPreferences(String userID) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userID).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      // Puoi gestire l'errore o loggarlo qui
      print("Errore recupero preferenze: $e");
    }
    return {}; // Ritorna mappa vuota se non ci sono dati o c'è errore
  }

  // Salva una singola preferenza
  Future<void> updatePreference(String userID, String key, dynamic value) async {
    await _firestore.collection('users').doc(userID).set(
      {key: value},
      SetOptions(merge: true), // Unisce i dati senza sovrascrivere tutto il documento
    );
  }
}