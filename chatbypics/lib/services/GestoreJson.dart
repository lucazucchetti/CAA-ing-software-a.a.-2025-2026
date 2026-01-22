import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

//Singleton
class GestoreJson{

  //costruttore privato
  GestoreJson._();

  //istanzio il costruttore singolo
  static final GestoreJson _istanza = GestoreJson._();

  //il factory che in dart permette il getInstance
  factory GestoreJson(){
    return _istanza;
  }

    Map<String, List<dynamic>> _pittogrammiMap = {};
    static const String _nomeFile = 'suggerimenti.json';

    //apertura file json e lettura
    Future<void> leggiJson() async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_nomeFile');

        if (await file.exists()) {
          String dati = await file.readAsString();

          _pittogrammiMap = Map<String, List<dynamic>>.from(jsonDecode(dati));
          print("caricato con successo");

        }
        else
          print("non trovato");
      }
      catch (e) {
        print("Error lettura json");
      }
    }

    Future<void> _salvaInJson() async {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$_nomeFile');

        String dato = jsonEncode(_pittogrammiMap);
        await file.writeAsString(dato);

        print("aggiornato il file in memoria");
      } catch (e) {
        print("errore aggiornamento del file in memoria");
      }
    }

    List<dynamic> suggerimentiDiImmagine(String id) {

      if(_pittogrammiMap.containsKey(id)) {
        return _pittogrammiMap[id]!;
      } else {
        return [];
      }

    }

    Future<void> aggiornamentoSuggerimenti(String oldId, String newURL) async {

      List<dynamic> suggerimenti;
      if (_pittogrammiMap.containsKey(oldId)) {
        suggerimenti = List.from(_pittogrammiMap[oldId]!);
      }
      else
      {
        suggerimenti=[];
      }

      if (suggerimenti.contains(newURL)) {
        suggerimenti.remove(newURL);
      }
      suggerimenti.insert(0, newURL);

      if (suggerimenti.length > 3) {
        suggerimenti = suggerimenti.sublist(0, 3);
      }

      _pittogrammiMap[oldId] = suggerimenti;

      await _salvaInJson();

      print("aggiornati suggerimenti dopo $oldId ci sarà $newURL");
    }
  }