import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatbypics/screens/addCcnPage.dart';

void main() {
  
  // TEST 1: Verifica che tutti i campi siano presenti all'avvio
  testWidgets('AddCcnPage mostra i 4 campi di testo e il bottone', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AddCcnPage(),
    ));

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Cognome'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password provvisoria'), findsOneWidget);
    expect(find.text('Registra Utente CCN'), findsOneWidget);
  });

  // TEST 2: Verifica errore se si preme il tasto con campi VUOTI
  testWidgets('Premendo registra con campi vuoti appaiono gli errori', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCcnPage()));

    await tester.tap(find.text('Registra Utente CCN'));
    await tester.pump();

    expect(find.text('Inserisci il nome'), findsOneWidget);
    expect(find.text('Inserisci il cognome'), findsOneWidget);
    expect(find.text('Email non valida'), findsOneWidget); 
    expect(find.text('Minimo 6 caratteri'), findsOneWidget);
  });

  // TEST 3: Verifica validazione specifica (Email senza @ e Password corta)
  testWidgets('Mostra errori specifici per Email non valida e Password corta', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCcnPage()));

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Mario');
    await tester.enterText(find.widgetWithText(TextFormField, 'Cognome'), 'Rossi');

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'mariorossi.it');

    await tester.enterText(find.widgetWithText(TextFormField, 'Password provvisoria'), '123');

    await tester.tap(find.text('Registra Utente CCN'));
    
    await tester.pump();

    expect(find.text('Inserisci il nome'), findsNothing);
    expect(find.text('Email non valida'), findsOneWidget);
    expect(find.text('Minimo 6 caratteri'), findsOneWidget);
  });
}