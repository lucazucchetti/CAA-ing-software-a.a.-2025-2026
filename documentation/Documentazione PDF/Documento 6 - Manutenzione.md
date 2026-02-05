# Software maintenance

Poiché la consegna del progetto relativo all’applicazione chatbypics vede come termine ultimo il 09/02/2026 con l’esposizione ai docenti del lavoro svolto, nell’attività di manutenzione verrà inclusa l’attività di refactoring del codice e non l’aggiunta di nuovi requisiti con la conseguente modifica e rilascio di nuovi versioni future.  

## CASO Refatoring ChatPage e ChatList
La classe ChatPage, cuore dell'applicazione, è stata soggetta ad una grande operazine di refactoring, prevista comunque dato l'approcio di prototipazione evolutiva utilizzato.

### Coerenza con l'architettura
La classe inizalmente è stata sviluppata in modo prototipazionale, quindi le sezioni logiche di interazione con le interfaccie verso servizi esterni e grafiche erano tutte insieme. Al fine di seguire l'architettura prevista in modo da migliorare il livello di manutentibilità è stata svolta un operazione di refactoring consistente nella divisione a strati delle funzionalità.

#### STRUTTURA:

Abbiamo inanzitutto diviso la classe in 4 sezioni
+ Attribuiti di stile
+ Grafica
+ Logica
+ Interfacce a servizi

Gli attribuiti di stile sono classi astratte contenenti gli oggetti grafici che saranno utilizzati dai Widget Stateless corrispondenti per la grafica, qui rientrano ad esempio i colori utilizzati dal widget oppure le dimensioni di padding o margin ecc.

La parte grafica composta dai singoli Widget Stateless presenti nella chat page come SezioneInput, GrigliaCategorie, SingoliMessaggi, PersistentPicker ecc. Tutti questi Widget realizzano solo la parte grafica, interagiscono solo con la parte logica per segnalare se eventualmente è stato premuto un particolare Widget (al fine di far svolgere un funzionalità da parte della Logica)

La parte logica composta dai Widget Statefull SezioneScrittura e SezioneLettura  decidono quali Widget della schermata costruire e gestiscono l'interazione dell'utente con gli stessi interfacciandosi eventualmente con le interfacce apposite per interagire con entità esterne come il database. In particolare:

+ SezioneLettura si occupa di mostrare i messaggi della chat secondo le impostazioni dell'utente e gestire la logica di richiesta di lettura vocale(utilizzando gli appositi servizi)

+ SezioneScrittura si occupa di mostrare i Widget necessari alla composizione del messaggio gestento la logica e quindi le funzionalità da eseguire quando l'utente interagisce con i vari Widget Stateless utilizzando se necessario appositi servizi

La parte di interfacce a servizi invece va a separare la parte di interazione con database o servizi esterni alla applicazione(come lettura vocale) dalla chatPage

La classe chatPage ottenuta non è altro che un direttore, che in base al ruolo(descritto nella sezione successiva), deciderà quale schermata costruire(e quindi anche quali gestori logici attivare).

### Aggiunta funzionalità ControlloChat
Aggiungendo la funzionalità di controllo delle chat dei CCN da parte del proprio tutor al fine di riutilizzare la stessa classe si è deciso di svolgere un operazione di refactoring, l'operazione ha consistito nell'andare ad implementrare il pattern Player-Role per la ChatPage. Dividendo in ruolo di Osservatore e RuoloDiScrittore.
I due ruoli implementano i metodi logici utilizzati per costruire i componenti logici per la scrittura e composizione dei messaggi: caso scrittore costruisce l'oggetto RuoloChat, caso lettore non lo costruisce; ed implementano la gestione logica dell'eliminazione di un messaggio costruendo nel caso il banner di richiesta di eliminazione e gestendo l'interazione con la classe ChatService per eliminare il messaggio.

In modo analogo è stato necessario eseguire un operazione di refactoring per la classe ChatList, introducendo il pattern Player-Role per la classe, creando i ruoli ListaMia e ListaTerzi che costruiscono la lista in base a se è la lista dell'utente oppure la lista di un CCN che il tutor sta visualizzando.

### Documentazione

Infine si è eseguita un operazione di refactoring andando a integrare la documentazione per tutte le parti sviluppate seguendo lo standard di documentazione di dart(simile a JavaDoc in java)

## Altre operazioni di refactoring

Durante l’attività di refactoring sono state separate principalmente le parti di codice dedicate allo stile e personalizzazione grafica dell’interfaccia dalla parte di logica e struttura delle pagine dell’applicazione. 

Quest'attività comporta l'aumento della futura manutenibilità per una modifica della grafica della pagina futura.
Di seguito vengono riportati degli esempi per mostrare nel concreto di cosa si è appena parlato.

### addCcnPage.dart
Questo esempio vuole mostrare come nel metodo che costruisce la pagina di aggiunta dei un nuovo ccn, nella funzione build vengono chiamate le relative funzioni situate nell'apposita classe di stile riportata di seguito.
```
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Stileaddccnpage.buildAppBar,
      body: Stileaddccnpage.buildScrollView(
        _formKey, 
        _nameController, 
        _surnameController, 
        _emailController, 
        _passwordController, 
        _isLoading, 
        _registerUser
      ),
    );
  }
```
Nella classe di *StileAddCcnPage.dart* troviamo: 
* Variabile responsabile della costruzione dell'appBar
```
static AppBar buildAppBar = AppBar(
    title: const Text("Nuovo Utente CCN"),
    backgroundColor: Colors.deepPurple.shade100,
  );
```
* Metodo dedicato alla costruzione dei campi per la registrazione del nuovo utente ccn
```
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
```
Da questa parte di codice è possibile notare anche la separazione dello stile grafico di ogni campo, che è stato separato ulteriormente dal metodo principale per consentire una maggiore flessibilità di modifica e di lettura del codice, evitando di avere un metodo composto da moltissime righe che faceva aumentare solamente la difficoltà nella lettura, facendo passare in secondo piano la parte di struttura che costruisce la pagina, utile al programmatore.

Lo stesso lavoro di separazione tra grafica e logica è stato fatto per le pagine: 
* chatPage
* editCcnPage
* settingPage
* authPage

## Analisi statica
Con lo strumento DCM, abbiamo potuto effettuare un'analisi statica del sistema che ha portato alla rilevazione automatica di issue per migliorare la stabilità del progetto, attraverso le seguenti azioni, che verranno implementate in una versione futura.
Di seguito viene riportato il risultato dell'analisi statica prodotto con gli issue da correggere per aumentarne la stabilità.
```
Analyzing chatbypics...                                                 

   info • The file name 'AuthPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/Authentication/AuthPage.dart:1:1 • file_names
   info • Don't use 'BuildContext's across async gaps • lib/screens/Authentication/AuthPage.dart:51:28 • use_build_context_synchronously
   info • Don't invoke 'print' in production code • lib/screens/Authentication/AuthPage.dart:72:7 • avoid_print
   info • Don't use 'BuildContext's across async gaps • lib/screens/Authentication/AuthPage.dart:87:28 • use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps • lib/screens/Authentication/AuthPage.dart:91:28 • use_build_context_synchronously
   info • The file name 'StileAuthPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/Authentication/StileAuthPage.dart:1:1 • file_names
   info • The file name 'verifyEmailPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/Authentication/verifyEmailPage.dart:1:1 • file_names
   info • Don't invoke 'print' in production code • lib/screens/Authentication/verifyEmailPage.dart:64:7 • avoid_print
   info • The file name 'HomePage.dart' isn't a lower_case_with_underscores identifier • lib/screens/HomePage.dart:1:1 • file_names
   info • The file name 'StileAddCcnPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/ccn/StileAddCcnPage.dart:1:1 • file_names
   info • The file name 'StileCcnEditPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/ccn/StileCcnEditPage.dart:1:1 • file_names
   info • The file name 'StileCcnManagePage.dart' isn't a lower_case_with_underscores identifier • lib/screens/ccn/StileCcnManagePage.dart:1:1 • file_names
   info • The file name 'addCcnPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/ccn/addCcnPage.dart:1:1 • file_names
   info • The file name 'ccnManagePage.dart' isn't a lower_case_with_underscores identifier • lib/screens/ccn/ccnManagePage.dart:1:1 • file_names
   info • The file name 'editCcnPage.dart' isn't a lower_case_with_underscores identifier • lib/screens/ccn/editCcnPage.dart:1:1 • file_names
   info • The file name 'CategoriePittogrammi.dart' isn't a lower_case_with_underscores identifier • lib/screens/chat/CategoriePittogrammi.dart:1:1 • file_names
   info • The file name 'ComposizioneMessaggio.dart' isn't a lower_case_with_underscores identifier •
          lib/screens/chat/ComposizioneMessaggio/ComposizioneMessaggio.dart:1:1 • file_names
```