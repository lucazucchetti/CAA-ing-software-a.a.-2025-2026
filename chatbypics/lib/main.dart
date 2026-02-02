import 'package:chatbypics/screens/authPage.dart';
import 'package:chatbypics/screens/verifyEmailPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:chatbypics/screens/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final User? user = authSnapshot.data;

        /// Se non c'è utente, mostra tema base (Login)
        if (user == null) {
          return _buildMaterialApp(ThemeMode.light, const AuthPage());
        }
        ///se l'utente non ha ancora verificato l'email
        if(!user.emailVerified){
          return _buildMaterialApp(ThemeMode.light, const VerifyEmailPage());
        }
        // Se c'è utente, ascoltiamo le sue preferenze su Firestore
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            ThemeMode mode = ThemeMode.light;

            // Se abbiamo dati e la chiave esiste, aggiorniamo il tema
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data != null && data['isDarkMode'] == true) {
                mode = ThemeMode.dark;
              }
            }

            return _buildMaterialApp(mode, const Homepage());
          },
        );
      },
    );
  }

  Widget _buildMaterialApp(ThemeMode themeMode, Widget homeWidget) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatByPics',
      themeMode: themeMode, // Qui si decide se è chiaro o scuro
      // TEMA CHIARO
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple.shade100,
          foregroundColor: Colors.black,
        ),
      ),
      // TEMA SCURO (Definiamo i colori per la notte)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        // Colori specifici per i widget in dark mode
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
          trackColor: MaterialStateProperty.all(Colors.grey.shade700),
        ),
      ),
      home: homeWidget,
    );
  }
}
