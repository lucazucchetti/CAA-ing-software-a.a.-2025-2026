import 'package:chatbypics/screens/ccn/StileCcnEditPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditCcnPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const EditCcnPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<EditCcnPage> createState() => _EditCcnPageState();
}

class _EditCcnPageState extends State<EditCcnPage> {
  ///[_isLoading] variabile per restituire la barra di caricamento
  bool _isLoading = false;
  ///[_isActive] variabile per impedire l'accesso del ccn in caso venisse bloccato dal tutor
  late bool _isActive;
  ///[_allCategories] lista delle categorie che possono essere nascoste al ccn
  final List<String> _allCategories = Stileccneditpage.allCategories;
  ///[_categoryStates] mappa le categorie visibili per mostrare solo quelle al ccn
  final Map<String, bool> _categoryStates = {};

  @override
  void initState() {
    super.initState();
    _isActive = widget.userData['profiloAttivo'] ?? true;

    List<dynamic> savedCategories = widget.userData['enabledCategories'] ?? _allCategories;

    //inizializzazione degli switch per disabilitare le categorie (tutti attivi di default)
    for (var cat in _allCategories) {
      _categoryStates[cat] = savedCategories.contains(cat);
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullName = "${widget.userData['Nome']} ${widget.userData['Cognome']}";

    return Scaffold(
      appBar: Stileccneditpage.buildAppBar(_saveChanges),
      body: _isLoading 
        ? Stileccneditpage.iconaBarraProgresso
        : Stileccneditpage.buildListViewPagina(
          _saveChanges, 
          fullName, 
          _isActive, 
          _categoryStates, 
          (cat,val) {setState(() {_categoryStates[cat] = val;});}, 
          (val) => setState(() => _isActive = val)),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      List<String> enabledList = [];
      _categoryStates.forEach((key, value) {
        if (value == true) enabledList.add(key);
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'profiloAttivo': _isActive,
        'enabledCategories': enabledList,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo aggiornato con successo!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}