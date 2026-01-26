import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/SintesiVocale.dart';
import 'Gestori/GestoreRichiestePreferenze.dart';
import 'PreferenzeChat.dart';
import 'SingoloMessaggio/SingoloMessaggio.dart';

///[SezioneLettura] classe che implementa tutta la parte di
///recupero e visualizzazione di messaggi in una chat
///
class SezioneLettura extends StatefulWidget {

  ///[chatID] è l'id della singola chat da mostrare
  ///passato come parametro nel metodo costruttore
  ///
  final String chatID;

  ///[utenteProprietarioChat] l'id dell'utente proprietario
  ///della chat
  ///
  final String utenteProprietarioChat;

  ///[utenteCheVisualizza] l'id dell'utente che visualizza la
  ///chat
  final String utenteCheVisualizza;

  ///[premutoElimina] è la funzione da passare per eliminare i singoli messaggi
  ///
  final Function(String messageId, Timestamp? timestamp) premutoElimina;


  const SezioneLettura({
    super.key,
    required this.chatID,
    required this.utenteProprietarioChat,
    required this.utenteCheVisualizza,
    required this.premutoElimina,
  });

  @override
  State<SezioneLettura> createState() => _SezioneLetturaState();
}


class _SezioneLetturaState extends State<SezioneLettura> {

  ///[_gestorePreferenze] è l'oggetto necessario per gestire le
  ///preferenze della chat dell'utente
  ///
  final GestoreRichiestePreferenze _gestorePreferenze = GestoreRichiestePreferenze();

  ///[_impostazioni] oggetto che contiene le preferenze della chat del determinato utente
  ///
  PreferenzeChat _impostazioni = PreferenzeChat();

  @override
  void initState() {
    super.initState();

    ///scarico le preferenze dela chat
    ///
    _caricaPreferenze();

    ///scarico le impostazioni della sintesi vocale,
    ///essendo un Singleton vado a creare l'oggetto in modo
    ///da accellerare il suo funzionamento
    ///
    SintesiVocale();
  }

  @override
  Widget build(BuildContext context) {
    return _streamBuilder();
  }


  ///[_streamBuilder] metodo che restituisce i messaggi dell'utente
  ///
  Widget _streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatID)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data!.docs;

        // Se non ci sono messaggi, mostra un avviso
        if (messages.isEmpty) {
          return const Center(
              child: Text("Inizia a comunicare con i pittogrammi!"));
        }

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 20),
          itemBuilder: (context, index) {
            return _buildMessageItem(messages[index]);
          },
        );
      },
    );
  }

  ///[_buildMessageItem] metodo che va a restituire la sezione dei messaggi inviati
  ///necessita in input il DocumentSnapshot [doc] di riferimento
  ///
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == widget.utenteProprietarioChat;
    String messaggioId = doc.id;
    Timestamp? timestampMessaggio = data['timestamp'];

    /// Recuperiamo la lista di pittogrammi dal documento
    List<dynamic> pictograms = data['pictograms'] ?? [];

    String fullSentence = pictograms.map((p) => p['description'] ?? '').join(
        " ");
    int itemsPerRow = _impostazioni.gridSize.toInt();
    if (itemsPerRow < 1) itemsPerRow = 1;

    ///creazione del singolo messaggio
    ///
    return SingoloMessaggio(
      isMe: isMe,
      messaggioId: messaggioId,
      timestampMessaggio: timestampMessaggio,
      fullSentence: fullSentence,
      pictograms: pictograms,
      impostazioni: _impostazioni,
      itemsPerRow: itemsPerRow,
      cliccato: (fraseDaLeggere) {
        SintesiVocale().speak(fraseDaLeggere);
      },
      premuto: (context, me, id, timestamp) {
        if (me) widget.premutoElimina(id, timestamp);
      },
    );
  }

  ///[_caricaPreferenze] metodo per caricare le preferenze di un determinato utente
  ///nelle impostazioni della chat
  ///
  Future<void> _caricaPreferenze() async {

    PreferenzeChat nuoveImpostazioni;

    ///Se l'utente è null allora non fa nulla e tiene le impostazioni standard
    ///
    if (widget.utenteCheVisualizza.isEmpty) return;

    ///Chiedo le impostazioni usando il gestore Preferenze
    ///
    nuoveImpostazioni = await _gestorePreferenze.caricaPreferenze(widget.utenteCheVisualizza);

    if (mounted) {
      setState(() {
        ///imposto le preferenze trovate
        _impostazioni = nuoveImpostazioni;
      });
    }
  }
}

