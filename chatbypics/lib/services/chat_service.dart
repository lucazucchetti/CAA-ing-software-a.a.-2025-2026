import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. NUOVO METODO PER INVIARE PIÙ PITTOGRAMMI ---
  Future<void> sendPictogramMessage({
    required String chatID,
    required String senderID,
    required List<Map<String, String>> pictograms,
  }) async {

    // A. Aggiungi il messaggio alla collezione 'messages'
    await _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .add({
      'senderId': senderID,
      'pictograms': pictograms,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'pittogramma_multiplo',
    });

    // B. Aggiorna l'anteprima nella home (unisce i testi: es. "Ciao, Mangiare")
    String previewText = pictograms.map((p) => p['description']).join(", ");

    // C. Aggiorna la chat principale (per farla salire in cima alla lista)
    // Questo serve per mostrare l'ultimo messaggio nella Home Page
    await _firestore.collection('chats').doc(chatID).update({
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageData': {
        'description': previewText,
        'imageUrl': pictograms.isNotEmpty ? pictograms.first['imageUrl'] : '',
      }
    });
  }

  // --- 2. CREA O RECUPERA CHAT (Per quando clicchi un amico) ---
  Future<String> createOrGetChat(String friendUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("Utente non loggato");

    // Genera ID univoco ordinato alfabeticamente (es. A_B è uguale a B_A)
    List<String> ids = [currentUser.uid, friendUid];
    ids.sort();
    String chatDocId = ids.join("_");

    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatDocId).get();

    if (chatDoc.exists) {
      return chatDocId;
    } else {
      // Se non esiste, la crea
      // Qui aggiungeremo anche la logica dei Tutor (visibleTo)
      List<String> allowedUsers = [currentUser.uid, friendUid];

      // (Opzionale: qui potresti aggiungere la ricerca dei Tutor dal DB come abbiamo discusso prima)

      await _firestore.collection('chats').doc(chatDocId).set({
        'participants': [currentUser.uid, friendUid],
        'visibleTo': allowedUsers,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageData': {
          'description': 'Nuova chat',
          'imageUrl': '',
        },
      });

      return chatDocId;
    }
  }

  ///Classe che permette l'eliminazione di un messaggio da parte di un utente
  ///l'eliminazione avviene direttamente nel database ed ha validità per tutte
  ///e due gli utenti
  ///
  /// richiede [chatID] id della chat e [messaggioID] id del messaggio da cancellare
  ///
  Future<void> cancellaMessaggio(String chatID, String messaggioID) async {
    try {
      ///cancellazione effettiva
      await _firestore.collection('chats').doc(chatID).collection('messages').doc(messaggioID).delete();

    } catch (e) {
      print("Errore di eliminazione: $e");
    }
  }
}