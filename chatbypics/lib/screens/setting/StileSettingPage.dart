import 'package:flutter/material.dart';

///[StileSettingPage] In questa classe vengono riportati tutti i parametri
///di personalizzazione della pagina delle impostazioni 
abstract class StileSettingPage{
  
  ///[titoloPagina] questa variabile da il titolo alla pagina
  static Text titoloPagina = Text("Impostazioni");

  ///[coloreSfondoPagina] questa variabile imposta il colore dello sfondo della pagina
  static Color coloreSfondoPagina = Colors.deepPurple.shade50;

  ///***SETTAGGI STILE GRAFICO SEZIONE PROFILO***
  ///[headerProfilo] questa variabile imposta il titolo della sezione
  static String headerProfilo = "Profilo";

  ///[coloreSfondoIconaProfilo] imposta il colore dello sfondo dell'icona
  static Color coloreSfondoIconaProfilo = Colors.deepPurple;
  
  ///[stileNomeProfilo] imposta lo stile del testo all'interno dell'icona
  static TextStyle stileNomeProfilo = TextStyle(color: Colors.white);

  ///[testoSottotitolo] imposta il sottotitolo della sezione 
  static Text testoSottotitolo = Text("Tocca per modificare il profilo");

  ///[iconaFrecciaAperturaSezione] imposta l'icona per espandere la sezione del profilo per un ulteriore modifica
  static Icon iconaFrecciaAperturaSezione = Icon(Icons.arrow_forward_ios, size: 16);

  ///[buildSettingProfilo] questo metodo costruisce la sezione del profilo
  static Widget buildSettingProfilo(String emailPerLogo, String email){
    return Column(
      children: [
        buildSectionHeader(headerProfilo),
        ListTile(
      leading: CircleAvatar(
        backgroundColor: coloreSfondoIconaProfilo,
        child: Text(emailPerLogo, style: stileNomeProfilo
        ),
      ),
      title: Text(email),
      subtitle: testoSottotitolo,
      trailing: iconaFrecciaAperturaSezione,
      onTap: () {
        //pagina per la modifica del profilo
      },
    )
      ],
    );
    
  }
  

  ///***SETTAGGI STILE GRAFICO SEZIONE ACCESSIBILITà CAA***
  ///[headerAccessibilita] questa variabile da il titolo alla sezione
  static String headerAccessibilita = "Accessibilità CAA";

  ///[titoloTestoSimboli] questa variabile imposta il titolo relativo alla prima impostazione di questa sezione
  static Text titoloTestoSimboli = Text("Mostra testo sotto i simboli");

  ///[sottotitoloTestoSimboli] questa variabile imposta il sottotitolo della prima impostazione
  static Text sottotitoloTestoSimboli = Text("Aiuta l'associazione immagine-parola");

  ///[coloreLabel] questa variabile imposta il colore dell'etichetta azionabile
  static Color coloreLabel = Colors.deepPurple;

  ///[titoloGrandezzaSimboli] questa variabile imposta il titolo della seconda impostazione della sezione
  static Text titoloGrandezzaSimboli = Text("Grandezza Griglia Simboli");

  ///[dimensioneAttuale] questa variabile imposta il titolo per fare vedere a che grandezza è impostata in tempo reale
  static String dimensioneAttuale = "DimensioneAttuale";

  ///[buildSettingAccessibilita] questo metodo costruisce la sezione delle impostazioni per l'accessibilità
  static Widget buildSettingAccessibilita(bool showLabels, void Function(bool) salvaStatoEtichetta, double gridSize, void Function(double) salvaStatoSlider){
    return Column(
      children: [
        buildSectionHeader(StileSettingPage.headerAccessibilita),
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
  ///[headerSintesiVocale] questa variabile imposta il titolo della sezione
  static String headerSintesiVocale = "Sintesi vocale";

  ///[titoloSintesi] questa variabile imposta il titolo all'impostazione
  static Text titoloSintesi = Text("Lettura Automatica");

  ///[sottoTitoloSintesi] questa variabile imposta il sottotitolo
  static Text sottoTitoloSintesi = Text("Leggi i messaggi appena arrivano");

  ///[titoloVelocita] questa impostazione da il titolo all'impostazione per la velocità della lettura 
  static Text titoloVelocita = Text("Velocità Voce");

  ///[attributiVelocita] elenco delle velocità in cui può avvenire la lettura
  static const List<String> attributiVelocita = <String>['Lenta', 'Normale', 'Veloce'];

  ///[defaultValue] variabile che imposta il valore di lettura di default
  static String defaultValue = "Normale";

  ///[buildSettingSintesiVocale] questo metodo costruisce la sezione delle impostazioni per la sintesi vocale
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
                //implementazione per modificare la velocità di lettura
              },
            ),
          )
      ],
    );
  }

  ///***SETTAGGI STILE GRAFICO APP & SISTEMA
  ///[headerAppSistema] variabile che imposta il titolo della sezione
  static String headerAppSistema = "App & sistema";

  ///[titoloAppSistema] variabile che imposta il titolo dell'impostazione
  static Text titoloAppSistema = Text("Modalità Scura");

  ///[padding] variabile che imposta l'inserzione degli angoli
  static EdgeInsets padding = EdgeInsets.all(20.0);

  ///[bottoneDisconnessione] variabile che definisce lo stile del bottone per la disconnessione
  static ButtonStyle bottoneDisconnessione = ElevatedButton.styleFrom(
    backgroundColor: Colors.red.shade100,
    foregroundColor: Colors.red,
    elevation: 0);

  ///[iconaDisconnessione] variabile utilizzata per l'icona di disconnessione
  static Icon iconaDisconnessione = Icon(Icons.logout);

  ///[labelBottoneDisconnessione] variabile del testo usato all'interno del bottone della disconnessione
  static Text labelBottoneDisconnessione = Text("Disconnetti");

  ///[buildSettingAppSistema] questo metodo costruisce la sezione delle impostazioni per il tema
  static Widget buildSettingAppSistema(bool isDarkMode, void Function(bool) updatePreferenceDarkMode){
    return Column(
      children: [
        buildSectionHeader(StileSettingPage.headerAppSistema),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: StileSettingPage.titoloAppSistema,
            value: isDarkMode,
            onChanged: updatePreferenceDarkMode,
          ),
      ],
    );
  }

  ///[tastoLogout] metodo che costruisce il bottone di logout
  static Widget tastoLogout(Future<void> Function() azioneLogoutFirebase){
    return Padding(
            padding: padding,
            child: ElevatedButton.icon(
              style: bottoneDisconnessione,
              icon: iconaDisconnessione,
              label: labelBottoneDisconnessione,
              onPressed: () async {
                await azioneLogoutFirebase();
                // AuthPage gestirà il cambio di stato grazie allo StreamBuilder nel main
              },
            ),
          );
  }

  ///[buildSectionHeader] metodo che va a costruire una sezione delle impostazioni
  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      ),
    );
  }

  ///[buildAppBar] metodo che costruisce l'app bar della pagina
  static AppBar buildAppBar= AppBar(
    title: titoloPagina,
    backgroundColor: coloreSfondoPagina,
  );
  
  


} 
