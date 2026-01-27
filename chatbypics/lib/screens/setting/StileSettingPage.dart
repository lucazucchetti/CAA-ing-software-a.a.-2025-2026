import 'package:flutter/material.dart';

///[StileSettingPage] In questa classe vengono riportati tutti i parametri
///di personalizzazione della pagina delle impostazioni 
abstract class StileSettingPage{
  
  ///[titoloPagina] questa variabile da il titolo alla pagina
  static Text titoloPagina = Text("Impostazioni");


  static Color coloreSfondoPagina = Colors.deepPurple.shade50;

  ///***SETTAGGI STILE GRAFICO SEZIONE PROFILO***
  static String headerProfilo = "Profilo";
  static Color coloreSfondoIconaProfilo = Colors.deepPurple;
  
  static TextStyle stileNomeProfilo = TextStyle(color: Colors.white);
  static Text testoSottotitolo = Text("Tocca per modificare il profilo");

  static Icon iconaFrecciaAperturaSezione = Icon(Icons.arrow_forward_ios, size: 16);

  static Widget buildSettingProfilo(String emailPerLogo, String email){
    buildSectionHeader(headerProfilo);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: coloreSfondoIconaProfilo,
        child: Text(emailPerLogo, style: stileNomeProfilo
        ),
      ),
      title: Text(email),
      subtitle: testoSottotitolo,
      trailing: iconaFrecciaAperturaSezione,
      onTap: () {
        // TODO: Naviga a pagina modifica profilo
      },
    );
  }
  

  ///***SETTAGGI STILE GRAFICO SEZIONE ACCESSIBILITà CAA***
  static String headerAccessibilita = "Accessibilità CAA";
  static Text titoloTestoSimboli = Text("Mostra testo sotto i simboli");

  static Text sottotitoloTestoSimboli = Text("Aiuta l'associazione immagine-parola");

  static Color coloreLabel = Colors.deepPurple;

  static Text titoloGrandezzaSimboli = Text("Grandezza Griglia Simboli");

  static String dimensioneAttuale = "DimensioneAttuale";

  static Widget buildSettingAccessibilita(bool showLabels, void Function(bool) salvaStatoEtichetta, double gridSize, void Function(double) salvaStatoSlider){
    buildSectionHeader(StileSettingPage.headerAccessibilita);
    return Column(
      children: [
        SwitchListTile(
            title: StileSettingPage.titoloTestoSimboli,
            subtitle: StileSettingPage.sottotitoloTestoSimboli,
            value: showLabels,
            activeThumbColor: StileSettingPage.coloreLabel,
              onChanged: salvaStatoEtichetta,
        ),
        ListTile(
            title: StileSettingPage.titoloGrandezzaSimboli,
            subtitle: Text("${StileSettingPage.dimensioneAttuale} ${gridSize.toInt()}"),
        ),
        Slider(
            value: gridSize,
            min: 1,
            max: 5,
            divisions: 4,
            label: gridSize.toInt().toString(),
            activeColor: Colors.deepPurple,
            onChanged: salvaStatoSlider
          ),
      ],
    );
  }

  ///***SETTAGGI STILE GRAFICO SINTESI VOCALE***
  static String headerSintesiVocale = "Sintesi vocale";
  static Text titoloSintesi = Text("Lettura Automatica");
  static Text sottoTitoloSintesi = Text("Leggi i messaggi appena arrivano");

  static Text titoloVelocita = Text("Velocità Voce");
  static const List<String> attributiVelocita = <String>['Lenta', 'Normale', 'Veloce'];
  static String defaultValue = "Normale";

  static Widget buildSettingSintesiVocale(bool autoReadMessages, void Function(bool) updatePreferenceAutoRead){
    return Column(
      children: [
        buildSectionHeader(headerSintesiVocale),
          SwitchListTile(
            title: titoloSintesi,
            subtitle: sottoTitoloSintesi,
            value: autoReadMessages,
            activeThumbColor: Colors.deepPurple,
            onChanged: updatePreferenceAutoRead,
          ),

          ListTile(
            title: titoloVelocita,
            trailing: DropdownButton<String>(
              value: defaultValue,
              items: attributiVelocita.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {
                // TODO: Implementa logica TTS
              },
            ),
          )
      ],
    );
  }

  ///***SETTAGGI STILE GRAFICO APP & SISTEMA
  static String headerAppSistema = "App & sistema";
  static Text titoloAppSistema = Text("Modalità Scura");

  static EdgeInsets padding = EdgeInsets.all(20.0);

  static ButtonStyle bottoneDisconnessione = ElevatedButton.styleFrom(
    backgroundColor: Colors.red.shade100,
    foregroundColor: Colors.red,
    elevation: 0);

  static Icon iconaDisconnessione = Icon(Icons.logout);
  static Text labelBottoneDisconnessione = Text("Disconnetti");

  // Widget helper per i titoli delle sezioni
  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  ///
  static AppBar buildAppBar= AppBar(
    title: StileSettingPage.titoloPagina,
    backgroundColor: StileSettingPage.coloreSfondoPagina,
  );
  
  


} 
