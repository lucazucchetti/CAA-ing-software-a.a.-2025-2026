
//CREDO SI POSSA RIMUOVERE, ERA IL SELETTORE DI PITTOGRAMMI CHE
//SI CHIUDEVA DOPO L'INSERIMENTO DI OGNI SINGOLO PITTOGRAMMA
//COSTRINGENDO L'UTENTE A RIAPRIRE IL SELETTORE PER OGNI PITTOGRAMMA
//DA INSERIRE
/*
  // --- LOGICA SELEZIONE PITTOGRAMMI ---
  void _showPictogramSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            const Text("Scegli un concetto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _samplePictograms.length,
                itemBuilder: (context, index) {
                  final pic = _samplePictograms[index];
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          // AGGIUNGI ALLA LISTA INVECE DI INVIARE SUBITO
                          _composingMessage.add({'url': pic['url']!, 'desc': pic['desc']!});
                        });
                        Navigator.pop(context);
                      },

                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(pic['url']!, height: 60),
                          Text(pic['desc']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
/*
  Widget _buildPersistentPicker() {
    return Container(
      height: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Barra superiore del selettore con tasto chiudi
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Seleziona simboli", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isPickerVisible = false),
                ),
              ],
            ),
          ),
          // Griglia pittogrammi
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _samplePictograms.length,
              itemBuilder: (context, index) {
                final pic = _samplePictograms[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _composingMessage.add({'url': pic['url']!, 'desc': pic['desc']!});
                    });
                    // Nessun Navigator.pop quindi La finestra resta aperta.
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(pic['url']!, height: 40),
                        Text(pic['desc']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  */