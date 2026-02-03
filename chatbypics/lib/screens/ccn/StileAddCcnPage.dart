import 'package:flutter/material.dart';

abstract class Stileaddccnpage {
  ///[buildAppBar] metodo che costruisce l'app bar della schermata di aggiunta di un nuovo CCN
  static AppBar buildAppBar = AppBar(
    title: const Text("Nuovo Utente CCN"),
    backgroundColor: Colors.deepPurple.shade100,
  );

  ///[_inputDecoration] si occupa dello stile che ha il campo usato per l'inserimento dei dati in fase di registrazione
  ///del ccn
  static InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  ///[buildScrollView] si occupa di creare tutta la schermata grafica per la registrazione del nuovo ccn
  ///[formKey] chiave globale per identificare il form
  ///[nameController] controller per l'inserimento del nome
  ///[surnameController] controller per l'inserimento del cognome
  ///[emailController] controller per l'inserimento dell'email
  ///[passwordController] controller per l'inserimento della password
  ///[isLoading] variabile per disabilitare il bottone di per registrare il ccn mentre l'app elabora il primo click
  ///[registerUser] funzione che chiama il salvataggio su firebase
  static SingleChildScrollView buildScrollView(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController surnameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    bool isLoading,
    Future<void> Function() registerUser,
  ){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Crea un account per il tuo assistito.\nLui dovrà solo fare il login.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            buildCampoNome(nameController),
            const SizedBox(height: 15),
            buildCampoCognome(surnameController),
            const SizedBox(height: 15),
            buildCampoEmail(emailController),
            const SizedBox(height: 15),
            buildCampoPassword(passwordController),
            const SizedBox(height: 30),
            buildBottoneRegistrazione(isLoading, registerUser),
          ],
        ),
      ),
    );
  }

  ///[buildCampoNome] funzione che costruisce il campo per il nome del ccn
  static TextFormField buildCampoNome(TextEditingController nameController){
    return TextFormField(
      controller: nameController,
      decoration: _inputDecoration("Nome"),
      validator: (val) => val!.isEmpty ? "Inserisci il nome" : null,
    );
  }
  ///[buildCampoCognome] funzione che costruisce il campo per il cognome del ccn
  static TextFormField buildCampoCognome(TextEditingController surnameController){
    return TextFormField(
      controller: surnameController,
      decoration: _inputDecoration("Cognome"),
      validator: (val) => val!.isEmpty ? "Inserisci il cognome" : null,
    );
  }
  ///[buildCampoEmail] funzione che costruisce il campo per l'email del ccn
  static TextFormField buildCampoEmail(TextEditingController emailController){
    return TextFormField(
      controller: emailController,
      decoration: _inputDecoration("Email"),
      keyboardType: TextInputType.emailAddress,
      validator: (val) => val!.contains("@") ? null : "Email non valida",
    );
  }
  ///[buildCampoPassword] funzione che costruisce il campo per la password del ccn
  static TextFormField buildCampoPassword(TextEditingController passwordController){
    return TextFormField(
      controller: passwordController,
      decoration: _inputDecoration("Password provvisoria"),
      obscureText: true,
      validator: (val) => val!.length < 6 ? "Minimo 6 caratteri" : null,
    );
  }

  ///[buildBottoneRegistrazione] funzione che costruisce il bottone per la registrazione del ccn
  static SizedBox buildBottoneRegistrazione(bool isLoading, Future<void> Function() registerUser){
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: isLoading ? null : registerUser,
        child: isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Registra Utente CCN", style: TextStyle(fontSize: 18)),
      ),
    ); 
  }




}