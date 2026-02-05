import 'package:flutter/material.dart';

abstract class Stileauthpage {
  ///[buildAppBar] costruisce l'appBar
  static AppBar buildAppBar = AppBar(
    title: const Text('ChatByPics'),
  );

  ///[buildScrollView] costruisce tutti i campi per la registrazione/login
  //////[name] controller per l'inserimento del nome
  ///[surname] controller per l'inserimento del cognome
  ///[email] controller per l'inserimento dell'email
  ///[password] controller per l'inserimento della password
  ///[isLogin] variabile usata per gestire la chiamata della pagina corretta in base allo stato dell'utente
  ///[onToggleVisibility] funzione che gestisce la maschera della password
  ///[onTutorChanged] funzione che gestisce la registrazione dell'utente con il ruolo ti TUTOR
  ///[forgotPassword] funzione che chiama la pagina di reset della password
  ///[createUser] funzione che chiama la creazione dell'utente su firebase
  ///[signIn] funzione che chiama l'accesso verificando le credenziali salvate su firebase
  ///[resetCampi] funzione che pulisce i campi quando si passa tra schermata di accesso e registrazione o viceversa 
  static SingleChildScrollView buildScrollView(
    bool isLogin,
    bool isTutor,
    TextEditingController name,
    TextEditingController surname,
    TextEditingController email,
    TextEditingController password,
    bool obscurePassword,
    void Function() onToggleVisibility,
    void Function(bool) onTutorChanged,
    Future<void> Function() forgotPassword,
    Future<void> Function() createUser,
    Future<void> Function() signIn,
    void Function() resetCampi,
  ){
    return SingleChildScrollView( 
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (!isLogin) ...[
            buildCampoNome(name),
            const SizedBox(height: 10),
            buildCampoCognome(surname),
            const SizedBox(height: 10),
          ],

          buildCampoEmail(email),
          const SizedBox(height: 10),
          buildCampoPassword(password, obscurePassword, onToggleVisibility),

          if (!isLogin)
            buildCheckBoxTutor(isTutor, onTutorChanged),
          const SizedBox(height: 20),
          if(isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: forgotPassword, 
                child: const Text(
                  'Password Dimenticata?', 
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold
                    ),
                ),
              ),
            ),
          buildBottoneAzione(isLogin,createUser,signIn),
          buildAccediRegistrati(resetCampi, isLogin),
        ]
      ),
    );
  }
  ///[buildCampoNome] funzione che costruisce il campo per l'inserimento del nome
  static TextField buildCampoNome(TextEditingController name){
    return TextField(
      controller: name,
      decoration: const InputDecoration(label: Text('Nome')),
    );
  }
  ///[buildCampoCognome] funzione che costruisce il campo per l'inserimento del cognome
  static TextField buildCampoCognome(TextEditingController surname){
    return TextField(
      controller: surname,
      decoration: const InputDecoration(label: Text('Cognome')),
    );
  }
  ///[buildCampoEmail] funzione che costruisce il campo per l'inserimento dell'email
  static TextField buildCampoEmail(TextEditingController email){
    return TextField(
      controller: email,
      decoration: const InputDecoration(label: Text('Email')),
    );
  }
  ///[buildCampoPassword]funzione che costruisce il campo per l'inserimento della password e la visualizzazione cliccando l'icona dell'occhio
  static TextField buildCampoPassword(TextEditingController password, bool obscurePassword, void Function() onToggleVisibility){
    return TextField(
      controller: password,
      obscureText: obscurePassword, 
      decoration: InputDecoration(
        label: const Text('Password'),
        suffixIcon: IconButton(
          icon: Icon(
          obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
  ///[buildCheckBoxTutor] funzione che aggiunge la checkbox per la registrazione dell'utente come tutor
  static CheckboxListTile buildCheckBoxTutor(bool isTutor, void Function(bool) onTutorChanged){
    return CheckboxListTile(
      title: const Text("Registrati come Tutor"),
      value: isTutor,
      onChanged: (val) {
        if (val != null) {
          onTutorChanged(val);
        }
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
  ///[buildBottoneAzione] funzione che crea il pulsante di accesso/registrazione dinamico in base alla situazione in cui ci troviamo:
  ///accesso, piuttosto che resitrazione
  static ElevatedButton buildBottoneAzione(bool isLogin,Future<void> Function() createUser, Future<void> Function() signIn ){
    return ElevatedButton(
      onPressed: (){
        isLogin ? signIn() : createUser(); 
      }, 
      child: Text(
        isLogin ? 'Accedi' : 'Registrati',
        style: TextStyle(color: Colors.blue) 
      )
    );
  }
  ///[buildAccediRegistrati] funzione che costruisce il bottone cliccabile per l'accesso/registrazione
  static TextButton buildAccediRegistrati(void Function() resetCampi, bool isLogin){
    return TextButton(
      onPressed: resetCampi, 
      child: Text(
        isLogin ? 'Non hai un account? Registrati' : 'Hai già un account? Accedi',
        style: TextStyle(
          color: Colors.blue,
        ),
      )
    );
  }

}