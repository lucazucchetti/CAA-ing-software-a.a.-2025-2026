import 'package:chatbypics/screens/ccn/stileCcnManagePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CCNManagePage extends StatefulWidget {
  const CCNManagePage({super.key});

  @override
  State<CCNManagePage> createState() => _CCNManagePageState();
}

class _CCNManagePageState extends State<CCNManagePage> {
  // Recuperiamo l'ID del Tutor loggato per filtrare i suoi utenti
  final String currentTutorId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Stileccnmanagepage.buildAppBar,
      
      //ascolta firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('tutorId', isEqualTo: currentTutorId) 
            .where('ruolo', isEqualTo: 'CCN')
            .snapshots(),
        builder: (context, snapshot) {
          
          //gestisce il caricamento in corso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stileccnmanagepage.iconaBarraProgresso();
          }

          //gestisce il caso in cui non si hanno ccn associati da gestire
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Stileccnmanagepage.ccnGestitiAssenti();
          }

          var users = snapshot.data!.docs;

          //gestisce i ccn associati per poterli gestire
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              String docId = users[index].id; 
              
              String nome = userData['Nome'] ?? "Senza Nome";
              String cognome = userData['Cognome'] ?? "";
              String fullName = "$nome $cognome";
              bool isActive = userData['profiloAttivo'] ?? true;

              return Stileccnmanagepage.buildSchedaListaCcn(fullName, isActive, context, docId, userData);
              
            },
          );
        },
      ),
      floatingActionButton: Stileccnmanagepage.buildBottoneAggiuntaCcn(context)
    );
  }

  
}