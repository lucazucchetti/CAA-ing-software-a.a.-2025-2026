import 'package:chatbypics/screens/ccnManagePage.dart';
import 'package:chatbypics/screens/chatList/RuoloListaMia.dart';
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
  final String? testRole;
  const Homepage({super.key, this.testRole});
  

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

    /**
     * Modifica che consente ai casi di test di non effettuare la chiamata a firebase facendo fallire il test.
     * Quando facciamo i test viene passato un ruolo fittizio per consentire di testare anche questa parte di codice
     */
    if (widget.testRole != null) {
      setState(() {
        _userRole = widget.testRole!;
        _isLoading = false; // Smettiamo di caricare subito
      });
    } else {
      // Comportamento normale (App reale) -> Chiama Firebase
      _checkUserRole();
      _checkProfiloStatus();
    }
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

  // Ascolta se il tutor elimina o disattiva questo account mentre l'app è aperta
  void _checkProfiloStatus() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots() // Ascolta in tempo reale ogni cambiamento
        .listen((snapshot) async {
      
      // CASO A: Il documento è stato ELIMINATO dal database (Tutor ha premuto cestino)
      if (!snapshot.exists) {
        await FirebaseAuth.instance.signOut();
        // L'AuthGate/Wrapper riporterà automaticamente l'utente al Login
        return;
      }

      // CASO B: Il documento c'è, ma il campo profiloAttivo è FALSE (Tutor ha spento l'interruttore)
      // Se il campo non esiste, diamo per scontato sia attivo (true)
      bool isActive = snapshot.data()?['profiloAttivo'] ?? true;
      
      if (!isActive) {
        // Logout forzato
        await FirebaseAuth.instance.signOut();
      }
    });
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
      ChatListPage(ruolo: RuoloListaMia()), // Indice 0: Sempre visibile
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
    if (_userRole == "Tutor") {
      /**
       * Modifica per fare una pagina finta se stiamo facendo un test
       */
      if (widget.testRole != null) {
        pages.add(const Center(child: Text("Gestione CCN Finta")));
      } else {
        pages.add(const CCNManagePage());
      }
      
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
    /**
     * Modofica per fare la pagina finta quando facciamo i test
     */
    if (widget.testRole != null) {
       pages.add(const Center(child: Text("Settings Finta")));
    } else {
       pages.add(const SettingPage());
    }
    
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