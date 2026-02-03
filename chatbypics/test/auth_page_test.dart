import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatbypics/screens/AuthPage.dart';

bool isEmailValid(String email) {
  return email.contains('@') && email.contains('.');
}

void main() {
  
  // TEST 1: Verifica lo stato alla prima apertura dell'applicazione
  testWidgets('AuthPage parte in modalità Registrazione', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AuthPage(),
    ));

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Cognome'), findsOneWidget);
    expect(find.text('Registrati come Tutor'), findsOneWidget);
    
    
    expect(find.text('Registrati'), findsOneWidget); // Deve dire "Registrati"

    expect(find.text('Hai già un account? Accedi'), findsOneWidget);
  });

  // TEST 2: Verifica il passaggio alla modalità LOGIN
  testWidgets('Cliccando su accedi scompare il nome e resta solo email/password', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AuthPage(),
    ));

    final toggleButton = find.text('Hai già un account? Accedi');
    await tester.tap(toggleButton);
    await tester.pump(); // Ridisegna la pagina

    expect(find.text('Accedi'), findsOneWidget); // Il bottone ora dice "Accedi"
    
    expect(find.text('Nome'), findsNothing);
    expect(find.text('Cognome'), findsNothing);
    
  });

  // TEST 3: Verifica la maschera della password
  testWidgets('Cliccando l\'occhio della password cambia l\'icona', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthPage()));

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  // TEST 4: Verifica la spunta sulla registrazione come tutor
  testWidgets('La checkbox Tutor si attiva e disattiva correttamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AuthPage(),
    ));

    final checkboxFinder = find.widgetWithText(CheckboxListTile, "Registrati come Tutor");
    
    expect(checkboxFinder, findsOneWidget);

    CheckboxListTile checkboxWidget = tester.widget(checkboxFinder);
    expect(checkboxWidget.value, false); // Di default isTutor = false

    await tester.tap(checkboxFinder);
    await tester.pump(); // aggiorna la schermata per vedere la spunta cliccata

    checkboxWidget = tester.widget(checkboxFinder);
    expect(checkboxWidget.value, true);

    await tester.tap(checkboxFinder);
    await tester.pump();

    checkboxWidget = tester.widget(checkboxFinder);
    expect(checkboxWidget.value, false);
  });

  group('Test Validazione Email', () {
    
    // CASO 1: Email valida
    test('Deve ritornare true se la mail è corretta', () {
      String email = "test@example.com";
      bool result = isEmailValid(email);
      expect(result, true); //expect è l'equivalente della funzione assertEquals per i test junit
    });

    // CASO 2: Email non valida
    test('Deve ritornare false se manca la chiocciola', () {
      expect(isEmailValid("testexample.com"), false);
    });

    // CASO 3: Stringa vuota
    test('Deve ritornare false se vuota', () {
      expect(isEmailValid(""), false);
    });
  });
}