import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatbypics/screens/homepage.dart'; // Controlla che il percorso sia giusto

void main() {
  
  // TEST 1: Verifica interfaccia per il TUTOR (Deve vedere 3 bottoni)
  testWidgets('Homepage per Tutor mostra 3 tab (Chats, Utenti, Impostazioni)', (WidgetTester tester) async {
    // Impostiamo una dimensione schermo realistica per evitare errori grafici
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    //creazione della home page con il ruolo fittizio di tutor
    await tester.pumpWidget(const MaterialApp(
      home: Homepage(testRole: "Tutor"),
    ));

    
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Utenti CCN'), findsOneWidget); //solo il tutor deve essere in grado di visualizzarlo
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    
    // Pulizia dimensione schermo
    addTearDown(tester.view.resetPhysicalSize);
  });

  // TEST 2: Verifica interfaccia per UTENTE (Deve vedere solo 2 bottoni)
  testWidgets('Homepage per Utente normale mostra solo 2 tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    //creazione della home page con il ruolo fittizio di utente
    await tester.pumpWidget(const MaterialApp(
      home: Homepage(testRole: "Utente"), 
    ));

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Impostazioni'), findsOneWidget);
  
    expect(find.text('Utenti CCN'), findsNothing); 
    expect(find.byType(NavigationDestination), findsNWidgets(2));
    
    addTearDown(tester.view.resetPhysicalSize);
  });

  // TEST 3: Verifica il cambio pagina al click
  testWidgets('Cliccando su una tab la selezione cambia', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const MaterialApp(
      home: Homepage(testRole: "Utente"),
    ));

    //cerca il bottone impostazioni
    final settingsTab = find.text('Impostazioni');
    await tester.tap(settingsTab);
    await tester.pump(); // Ridisegna l'interfaccia

    //verifico che si sia aggiornato il selected index
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 1);

    addTearDown(tester.view.resetPhysicalSize);
  });
}