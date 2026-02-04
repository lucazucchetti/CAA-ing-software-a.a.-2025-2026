# Software maintenance

Poiché la consegna del progetto relativo all’applicazione chatbypics vede come termine ultimo il 09/02/2026 con l’esposizione ai docenti del lavoro svolto, nell’attività di manutenzione verrà inclusa l’attività di refactoring del codice e non l’aggiunta di nuovi requisiti con la conseguente modifica e rilascio di nuovi versioni future.   
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

