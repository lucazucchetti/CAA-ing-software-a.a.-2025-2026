import 'package:chatbypics/screens/ccnManagePage.dart';
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
  //Indice della tab selezionata (0 = Chat)
  int _selectedIndex = 0; 

  //Lista delle pagine da mostrare
  static final List<Widget> _pages = <Widget>[
    const ChatListPage(), //pagina 0: Lista delle chat
    const CCNManagePage(), //pagina 1: Lista per gestire CCN
    const SettingPage(), //pagina 2: Impostazioni
  ];
  
  //Funzione per cambiare tab quando si clicca
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      /*
      App bar viene messa nelle singole pagine, così da 
      personalizzare il titolo per ogni pagina
      */
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),    
          ),
        ),
        child: NavigationBar(
          height: 70,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            // 0. CHAT
            NavigationDestination(
              icon: Badge(
                label: Text('6'), //esempio numero notifiche
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                child: Icon(Icons.chat_bubble_outline),
              ),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chats'
            ),

            //1. GESTIONE CCN
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined), 
              selectedIcon: Icon(Icons.people_alt_rounded),
              label: 'Utenti CCN'
            ),

            //2. Impostazioni
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Impostazioni'
            ),
          ]
        ),
      ),
    );
  }
}