import 'package:cloud_firestore/cloud_firestore.dart';

///[GestorePermessi] classe che permette la gestione dei permessi sulle
///categorie di pittogrammi visualizzabili da un utente
///
class GestorePermessi{

  ///[_database] istanza del database usato
  ///
  final FirebaseFirestore _database=FirebaseFirestore.instance;

  ///[recuperaCategorie] metodo che restituisce
  ///la lista delle categorie abilitate per un utente richiede l'id dell'utente
  ///in ingresso
  ///
  Future<List<String>> recuperaCategorie(String id) async {
    try {
      final doc=await _database.collection('users').doc(id).get();

      ///se l'utente esiste allora leggo se ci sono i permessi
      if(doc.exists)
      {

        List<dynamic>? dati=doc.data()?['enabledCategories'];

        ///se esistono i permessi allora vado a restituirli
        if (dati!=null) {
          return dati.map((e) => e.toString()).toList();
        }
      }
    } catch(e){
      print("Errore");
    }

    ///se non ce l'utente o i permessi allora restituisce una lista vuota
    return [];
  }
}