import 'package:chatbypics/screens/ccnManagePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbypics/screens/chatListPage.dart';
import 'package:chatbypics/screens/settingPage.dart';

/*
Classe che gestisce la barra per navigare tra le varie pagine all'interno
dell'applicazione
*/ 
class Homepage extends StatefulWidget{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String _userRole = ""; // Qui salveremo se è "Tutor" o altro
  bool _isLoading = true; // Per aspettare il caricamento del ruolo

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // 1. CONTROLLIAMO IL RUOLO SU FIREBASE
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          // Assicurati che nel DB il campo si chiami 'ruolo' e il valore sia 'Tutor'
          // Se hai usato un booleano, cambia in: _isTutor = data['isTutor'] == true;
          _userRole = doc.data()?['ruolo'] ?? "Utente"; 
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se stiamo ancora caricando, mostriamo una rotellina
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. COSTRUIAMO LE LISTE IN BASE AL RUOLO
    // Lista delle Pagine
    List<Widget> pages = [
      const ChatListPage(), // Indice 0: Sempre visibile
    ];

    // Lista dei Bottoni
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline), 
        activeIcon: Icon(Icons.chat_bubble),
        label: "Chats"
      ),
    ];

    // --- BLOCCO SOLO PER TUTOR ---
    if (_userRole == "Tutor") { // <--- IL FILTRO MAGICO
      pages.add(const CCNManagePage()); // La pagina dello screenshot (Gestione Utenti)
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined), 
          activeIcon: Icon(Icons.group),
          label: "Utenti CCN"
        )
      );
    }
    // -----------------------------

    // Aggiungiamo le Impostazioni (visibili a tutti)
    pages.add(const SettingPage()); // Sostituisci col nome della tua pagina impostazioni
    navItems.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings_outlined), 
        activeIcon: Icon(Icons.settings),
        label: "Impostazioni"
      )
    );

    return Scaffold(
      // Mostra la pagina corretta dalla lista dinamica
      body: pages[_selectedIndex],
      
      bottomNavigationBar: NavigationBar( // O BottomNavigationBar
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: navItems.map((item) {
          // Adattamento se usi NavigationBar invece di BottomNavigationBar
          return NavigationDestination(
            icon: item.icon, 
            selectedIcon: item.activeIcon,
            label: item.label!,
          );
        }).toList(),
      ),
    );
  }
}