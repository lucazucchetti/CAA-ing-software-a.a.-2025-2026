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
  bool _isLoading = false;
  late bool _isActive;
  final List<String> _allCategories = Stileccneditpage.allCategories;

  final Map<String, bool> _categoryStates = {};

  @override
  void initState() {
    super.initState();
    _isActive = widget.userData['profiloAttivo'] ?? true;

    List<dynamic> savedCategories = widget.userData['enabledCategories'] ?? _allCategories;

    // Inizializziamo gli switch
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
      // 1. Ricostruiamo la lista delle categorie abilitate (Solo quelle attive)
      List<String> enabledList = [];
      _categoryStates.forEach((key, value) {
        if (value == true) enabledList.add(key);
      });

      // 2. Aggiorniamo Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'profiloAttivo': _isActive,
        'enabledCategories': enabledList, // Salviamo la lista
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo aggiornato con successo!")));
        Navigator.pop(context); // Torna indietro
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