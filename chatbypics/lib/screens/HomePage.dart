import 'package:chatbypics/screens/ccn/ccnManagePage.dart';
import 'package:chatbypics/screens/chatList/RuoloListaMia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatbypics/screens/chatList/chatListPage.dart';
import 'package:chatbypics/screens/setting/settingPage.dart';

/*
Classe che gestisce la barra per navigare tra le varie pagine all'interno
dell'applicazione
*/ 
class Homepage extends StatefulWidget{
  final String? testRole;
  const Homepage({super.key, this.testRole});
  

  @override
  ///[createState] Riceve lo Stato della Homepage
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  ///[_userRole] Contine lo stato del ruolo dell'account
  String _userRole = "";
  ///[_isLoading] aspetta il caricamento del ruolo
  bool _isLoading = true;

  @override
  ///[initState] verifichiamo che la homepage si stia caricando altrimenti fermiamo tutto
  void initState() {
    super.initState();

    /**
     * Modifica che consente ai casi di test di non effettuare la chiamata a firebase facendo fallire il test.
     * Quando facciamo i test viene passato un ruolo fittizio per consentire di testare anche questa parte di codice
     */
    if (widget.testRole != null) {
      setState(() {
        _userRole = widget.testRole!;
        _isLoading = false;
      });
    } else {
      _checkUserRole();
      _checkProfiloStatus();
    }
  }

  ///[_checkUserRole] serve per vedere e restituire il ruolo dell'user
  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _userRole = doc.data()?['ruolo'] ?? "Utente"; 
          _isLoading = false;
        });
      }
    }
  }

  ///[_checkProfiloStatus] check continuo per vedere se il tutor cambia lo status dell'account
  void _checkProfiloStatus() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) async {

      if (!snapshot.exists) {
        await FirebaseAuth.instance.signOut();
        return;
      }

     ///[isActive] se è attivo forziamo l'attivazione
      bool isActive = snapshot.data()?['profiloAttivo'] ?? true;
      
      if (!isActive) {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  @override
  ///[build] Carica la homepage
  ///se effettivamente si carica fa vedere la lista delle chat
  /// altrimenti mostra la rotella per il caricamento
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    List<Widget> pages = [];
    if (widget.testRole != null) {
      // Se siamo in test, mettiamo un widget stupido che non chiama Firebase
      pages.add(const Center(child: Text("Chat List Finta"))); 
    } else {
      // Se siamo nell'app vera, carichiamo la ChatListPage che chiama Firebase
      pages.add(ChatListPage(ruolo: RuoloListaMia()));
    }

    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline), 
        activeIcon: Icon(Icons.chat_bubble),
        label: "Chats"
      ),
    ];

    // se l'user è un tutor allora può bloccare
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
    ///[Scaffold] mostra e va navigare nella chat
    return Scaffold(
      // Mostra la pagina corretta dalla lista dinamica
      body: pages[_selectedIndex],
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: navItems.map((item) {
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