# CAA-ing-software-a.a.-2025-2026
# Introduzione

Il presente progetto si inserisce nel corso di Ingegneria del Software (AA 2025/26) tenuto dal Prof. Angelo Gargantini e dalla Dott.ssa Silvia Bonfanti.

Lo scopo del progetto è migliorare e integrare nuove funzionalità in un’applicazione che permetta la comunicazione da remoto utilizzando la Comunicazione Aumentativa e Alternativa (CAA). La CAA è un insieme di strategie, tecnologie e strumenti che supportano o sostituiscono la comunicazione verbale per persone con difficoltà nel linguaggio orale.

Questo progetto mira ad applicare sistematicamente i principi dell'ingegneria del software per analizzare i requisiti forniti dai docenti, progettare un'architettura robusta, implementare le funzionalità richieste e testare il prodotto finale.

Responsabili:

* Steven Paglialunga, 1093434;  
* Luca Zucchetti, 1094075;  
* Igli Daja, 1093047;  
* Fabio Mariani, 1082488 ;

# Modello di processo

Per questo progetto, abbiamo deciso di adottare il **Rational Unified Process (RUP)**.

**Giustificazione della Scelta:** Il RUP è un processo iterativo e incrementale, fortemente "use-case driven"  e incentrato sulla produzione di modelli e documenti. Questa scelta è motivata dai seguenti fattori:

1. **Enfasi sulla Modellazione:** I requisiti del corso obbligano all'uso estensivo di UML  e dello strumento Papyrus . Il RUP è nativamente allineato con UML e pone la modellazione (analisi e design) al centro del processo.  
2. **Focalizzazione sui Requisiti:** L'approccio "use-case driven" del RUP si adatta bene alla natura del progetto CAA, dove le interazioni dell'utente (sia il paziente che il caregiver) sono fondamentali e devono essere definite chiaramente.  
3. **Natura Iterativa:** Il RUP permette di affrontare i rischi principali nelle prime iterazioni e di sviluppare il software in modo incrementale, producendo versioni eseguibili.  
4. **Gestione della Documentazione:** Il corso richiede che circa il 70% del tempo sia speso in attività di modellazione e documentazione . Il RUP fornisce una struttura chiara per la produzione e la gestione dei molteplici Documenti richiesti

**Fasi del Processo:** Il progetto seguirà le quattro fasi canoniche del RUP:

1. **Inception:** L'obiettivo è definire lo scopo del progetto, l'architettura preliminare e ottenere l'approvazione del Project Plan , risolvendo i rischi critici.  
2. **Elaboration:**  L'obiettivo è analizzare il dominio, definire un'architettura stabile, e specificare la maggior parte dei casi d'uso e del design.  
3. **Construction:** L'obiettivo è sviluppare iterativamente il software, component per componente, completando l'implementazione e i test di unità.  
4. **Transition:** L'obiettivo è finalizzare il prodotto, completare i test di accettazione e consegnare il sistema completo.

# Organizzazione del progetto

**Relazioni Esterne:**

* **Organizzazione Madre:** L'Università degli Studi di Bergamo, nell'ambito del corso di Ingegneria del Software AA 2025/26.  
* **Organizzazione Utente :** Data l'assenza di utenti finali reali, questo ruolo è ricoperto dai docenti del corso (Prof. A. Gargantini, Dott.ssa S. Bonfanti). I docenti agiscono come "clienti" del progetto: forniscono i requisiti di base , approvano i deliverable, e valutano il prodotto finale.

**Organizzazione Interna del Team:**

* **Modello Organizzativo:** In linea con il processo RUP e i principi agili, il team adotta un modello senza una gerarchia formale e promuovendo la "collective ownership" del codice e dei documenti.  
* **Aree di Responsabilità :**   
  L’organizzazione del team è di tipo agile quindi tutti i membri del team sono equi responsabili di tutte le attività e quindi tutti svolgeranno tutte le attività. Sottolineiamo però delle macro responsabilità dei singoli individui del team.  
  * **Luca Zucchetti: Referente Pianificazione e Processo.**  
    * *Responsabilità:* Comunicazione formale con il cliente, gestione della organizzazione della documentazione, gestione dell’organizzazione delle riunioni di allineamento, gestione della kanban board e gestione di github  
  * **Steven Paglialunga: Referente Analisi e Modellazione.**  
    * *Responsabilità:* Guida la stesura del DOCUMENTO 3 (Requisiti), supervisiona la creazione e la coerenza dei diagrammi UML (Use Case, Activity, State) in Papyrus.  
  * **Igli Daja: Referente Architettura e Design.**  
    * *Responsabilità:* Guida la stesura del DOCUMENTO 4 (Design), definisce l'architettura software, supervisiona la modellazione (Class, Sequence, Component) e la generazione di codice da Papyrus, assicura l'applicazione dei design pattern.  
  * **Fabio Mariani: Referente Qualità e Configuration Management.**  
    * *Responsabilità:* Guida la stesura del DOCUMENTO 5 (Testing), supervisiona la scrittura dei test flutter, gestisce le policy di branching/merging su GitHub, la build e l'integrazione.  
* **Formazione :** Il team possiede le competenze di base richieste (OOP, Git). Eventuali lacune su strumenti specifici (Papyrus) e lacune complete per quanto riguarda l’ambiente di programmazione (Flutter) e linguaggio dart saranno colmate come auto-formazione tramite video corso, documentazione ufficiale e supporto di intelligenza artificiale

# Standard, linee guida e procedure

Le metodologie gestionali e operative adottate per il ciclo di vita del progetto sono differenziate in base alla fase di sviluppo:

1. **Fase Iniziale (Analisi e Progettazione):** Le procedure per l'elicitazione e la definizione dei requisiti si basano su riunioni in presenza (o sincrone). Tali incontri sono finalizzati all'identificazione e alla validazione delle specifiche fondamentali del software.  
2. **Fasi Esecutive (Implementazione e Test):** Per la gestione delle fasi di implementazione e collaudo, lo standard adottato è l'utilizzo della **project board (Kanban) integrata in GitHub**. Questo strumento funge da canale primario sia per la comunicazione asincrona relativa ai task, sia per il **monitoraggio continuo dello stato di avanzamento** delle attività pianificate.

Standard di implementazione: linguaggio utilizzato dart con utilizzo del framework flutter seguendo lo standard dart.

# Attività di gestione

Quasi ogni giorno il team organizzerà una breve riunione informale per valutare il punto della situazione che potrà avvenire sia in presenza che in modalità telematica.

# Rischi

Data la **mancanza di competenza specifica in Dart e Flutter**,rappresenta una **criticità per il raggiungimento degli obiettivi** nei tempi stabiliti. È possibile che il progetto non venga completato entro la scadenza prevista o che la consegna risulti incompleta.

# Personale

I membri del team di sviluppo sono:

* Steven Paglialunga, 1093434;  
* Luca Zucchetti, 1094075;  
* Igli Daja, 1093047;  
* Fabio Mariani, 1082488 ;

Non si prevedono modifiche al team o eventuali aggiunte di altro personale.

# Metodi e tecniche

## 1\. Metodi per l’ingegneria dei requisiti

* **Metodologia**: User-Centered-Design (UCD): la partenza si ha dai requisiti specificati nel documento 3, volti a garantire all’utente finale un’esperienza di utilizzo semplice ed efficace.  
* **Tecniche di elicitazione dei requisiti**: chiedere alla docente Silvia Bonfanti cosa ci si aspetta dal sistema; analisi del compito facendosi descrivere il processo di funzionamento generale dell’applicazione; derivazione da un sistema esistente, partendo dall’applicazione esistente fatta da altri studenti, per osservarne le funzionalità e possibili miglioramenti

## 2\. Metodi per la progettazione

* **Piattaforma**: Cross-Platform con Flutter  
* **Pattern architetturale**:  
* **Progettazione dell’architettura software**: la tecnica prevede che gli utenti possano scambiarsi messaggi da remoto. I dati utente e le chat saranno salvate su un database Firebase. L’applicazione garantirà una copia in locale delle chat per evitare i tempi di attesa per il caricamento ad ogni apertura dell’applicazione.  
* **Progettazione dell’interfaccia utente (UI) e dell’esperienza (UX)**: creazione di un design con alta leggibilità e contrasto, caratterizzati dalla semplicità nel gestire le operazioni, per garantire un’esperienza d’uso fluida e intuitiva.  
* **Progettazione del sistema di pittogrammi**: metodo di gestione e caricamento dei set di pittogrammi tramite API di ARASAAC

## 3\. Metodi per l’implementazione

* **Metodologia di sviluppo**: agile, nello specifico il framework RUP  
* **Stack tecnologico**: linguaggio dart in flutter, firebase per il backup sul cloud

## 4\. Metodi e tecniche di prova

* **Software**: simulatore (Xcode simulator e Android Emulator)  
* **Hardware**: dispositivi elettronici degli studenti che sviluppano il progetto (iPhone e Android)  
* **Ordine di integrazione e test**:  
  * Unit Test: test automatici sulle singole funzioni  
  * Test di integrazione: test sul collegamento tra moduli  
  * Test del sistema: test dell’app completa   
* **Procedure di test di accettazione**:  
  * Definizione di casi d’uso reali  (es. dire a un amico che sono andato a scuola)  
  * Svolgimento dei test in un ambiente controllato dal team di sviluppo  
  * Raccolta di feedback qualitativi e quantitativi nella fase finale

## 5\. Controllo della versione

* **Metodo**: Utilizzo del sistema di controllo della versione Git  
* **Piattaforma**: GitHub

# Garanzia di qualità

## 1\. Strategia generale di garanzia della qualità

* Obiettivo della QA: l’obiettivo non è trovare bug, ma garantire all’utente che l’applicazione sia uno strumento di comunicazione affidabile e intuitivo.  
* Approccio: test continuo

## 2\. Pianificazione dei test

* **Test automatici** scritti dagli sviluppatori per verificare il corretto funzionamento delle singole unità di codice  
* **Test di integrazione** per verificare che i diversi moduli lavorino correttamente tra di loro  
* **Test di sistema** per verificare il corretto funzionamento direttamente sul dispositivo e se sono soddisfatti tutti i requisiti

## 3\. Ambiente di test

* **Ambiente di sviluppo**, tramite l’utilizzo di simulatori  
* **Ambiente di staging**, tramite build dell’applicazione distribuite internamente ai membri del team di sviluppo

# Pacchetti di lavoro 

## 1\. Gestione e coordinamento del progetto

Responsabile: project manager

* **Pianificazione**: requisiti del progetto  
* **Monitoraggio**: meeting settimanali e gestione dei rischi  
* **Documentazione**: stesura della documentazione e manualistica finale

## 2\. Sviluppo front-end 

Responsabile: mobile developer

* **Motore griglia**: implementazione della logica di visualizzazione e navigazione tra le pagine di pittogrammi  
* **Sistema di input**  
* **Database locale**: implementazione persistenza dei dati per la copia locale dei pittogrammi

## 3\. Sviluppo back-end 

* **Autenticazione degli utenti**  
* **Infrastruttura client-server e database remoto**   
* **API messaggistica real-time**  
* **Logica di traduzione dei dati**: deve esserci un algoritmo che consenta la traduzione dei pittogrammi scambiati nei messaggi come stringa in un file di testo   
* **Notifiche push**: sistema per l’avviso di ricezione di messaggi

## 4\. Testing e validazione

* **Unit & Integration Test:** Verifica automatica dei singoli moduli software.  
* **Test di Carico (Messaggistica):** Verifica della stabilità del server con molti messaggi contemporanei.  
* **Test di Usabilità (UAT):** Sessioni di prova con utenti CAA per validare l'ergonomia e la comprensione.  
* **Validazione Clinica:** Verifica della correttezza linguistica/comunicativa con esperti.

# Risorse

**Hardware:**

* **Sviluppo**: 4 PC che supportano flutter per lo sviluppo emulazione e compilazione del codice  
* **Testing:** 1 Dispositivo Ios per il testing dell’interfaccia utente e performance su ios  
* **Testing :**1 Dispositivo Android per il testing e la compatibilità con android

**Servizi Backend**

* **Database:** Firebase Firestore (per la sincronizzazione dei profili utente e delle schede CAA).  
* **Autenticazione:** Firebase Authentication  
* **Hosting:** Firebase Hosting

###  **Gestione del Progetto e Collaborazione**

* **Controllo Versione:** Git.  
* **Repository:** GitHub (per il codice sorgente e la gestione delle Pull Request).  
* **Project Management:** Kanban board

# Budget

Le attività richieste non richiedono investimenti di capitale, a fronte di ciò non è previsto alcuno stanziamento di budget. Per le ore delle risorse umane, sono previste dalle 40 alle 50 ore per ogni risorsa per il completamento del progetto, dalla stesura dei documenti al completamento del software

# Cambiamenti

Le eventuali correzioni degli errori nel codice verranno affrontate tramite apertura e risoluzione degli issue su github tramite assegnazione degli issue a individui del team.  
L’aggiunta di requisiti: viene fatto attraverso l’utilizzo della kanban board integrata in github così da monitorare lo stato di completamento.

# Consegna

Il progetto sarà considerato completo solo dopo la consegna di tutti i seguenti artefatti:

1. **Codice Sorgente dell'Applicazione CAA:** Implementazione completa, documentata e funzionante dell'applicazione multi-piattaforma.  
2. **Documentazione di Progetto :**	  
   **●PROJECT PLAN :**   
   Software Engineering Management   
   **●GESTIONE DEL PROGETTO:**   
    Software Life Cycle   
    Configuration Management   
    People Management and Team Organization   
   **●REQUISITI :**   
    Requirements Engineering   
    Software Quality   
   **●DESIGN :**   
    **Modelling (I diagrammi possono anche essere distribuiti come suggerito sopra)**   
    Software Architecture   
    Software Design pattern   
   **●TESTING:**   
    Software Testing   
   **●MAINTENANCE:**   
    Software Maintenance

La consegna avverrà condividendo l'accesso alla repository del codice sorgente che contiene sia l'applicazione che la documentazione:

* **Repository Unica:** Tutti i file di codice sorgente e l'intera documentazione di progetto saranno ospitati in un'unica repository privata.  
* **Condivisione Accesso:** L'accesso alla repository deve essere garantito al Prof. Gargantini e alla Prof. Bonfanti aggiungendoli come collaboratori.  
    
