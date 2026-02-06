# ISTRUZIONI


## STRUTTURA DIRECTORY
La cartella del progetto CAA-ing-software-a.a.-2025-2026 è strutturata nel seguente modo:

### documentation
+ documentazione(elaborato)
+ diagrammi UML utilizzati(immagini png e codice sorgente PlantUML)

### chatbypics
+ codice sorgente

## installer

+ link Google Drive per trovare l'apk da installare su dispositivo Android per eseguire l'app(versione 1.0)

## ESECUZIONE APP
Di seguito le istruzioni per eseguire l'app chatbypics

### Esecuzione da simulatore Android su AndroidStudio

+ Avere installato e configurato flutterSDK

+ Recarsi su chatbypics/pubspec.yaml ed eseguire Pub get

+ Avviare simulatore Android

+ Configurare il simulatore android per permettere la comunicazione in rete, sulla rete AndroidWiFi:
  + IP statico
  + IP Address: 10.0.2.15 (anche .16 o .17 va bene)
  + Gateway: 10.0.2.2
  + Network prefix lenght: 4
  + DNS primario: 8.8.8.8
  + DNS secondario: 8.8.4.4

+ Posizionarsi su chatbypics/lib e lanciare il comando: flutter run

### Esecuzione da simulatore iOS su Visual Studio Code
+ Avere installato e configurato flutterSDK
+ eseguire dal terminale dell'editor: "*flutter pub get*" per installare le dipendenze 
+ assicurarsi che sia scaricato il simulatore di iOS presente con l'installazione di XCode sul Mac
+ premere la seguente combinazione "*Shift+Command+P*" seguito da "*Select Device*", da cui si seleziona la versione del simulatore scaricata
+ Dal main del progetto su *chatbypics/lib* premere il pulsante di debug, oppure da terminale "*flutter run*"

### Esecuzione su Smartphonen Android

+ Installare l'apk sul dispositivo Android e farlo partire



