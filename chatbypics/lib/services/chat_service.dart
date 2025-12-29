import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. INVIARE UN PITTOGRAMMA ---
  Future<void> sendPictogram({
    required String chatID,
    required String senderID,
    required String imageUrl,
    required String description,
  }) async {
    
    // A. Aggiungi il messaggio alla collezione 'messages'
    await _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .add({
      'senderId': senderID,
      'imageUrl': imageUrl,
      'description': description, // Es: "Ciao", "Mangiare"
      'timestamp': FieldValue.serverTimestamp(), // L'ora del server
      'type': 'pittogramma',
    });

    // B. Aggiorna la chat principale (per farla salire in cima alla lista)
    // Questo serve per mostrare l'ultimo messaggio nella Home Page
    await _firestore.collection('chats').doc(chatID).update({
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageData': {
        'description': description, // Testo anteprima
        'imageUrl': imageUrl,       // Icona anteprima (opzionale)
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
}