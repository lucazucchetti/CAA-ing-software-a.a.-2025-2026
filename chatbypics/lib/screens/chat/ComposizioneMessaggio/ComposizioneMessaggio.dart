import 'package:flutter/material.dart';

class ComposizioneMessaggio extends StatelessWidget {

  final List<Map<String, String>> composingMessage;
  final VoidCallback invio;
  final Function(int) rimozione;

  const ComposizioneMessaggio({
    required this.composingMessage,
    required this.invio,
    required this.rimozione,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 110,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: composingMessage.length,
                    itemBuilder: (context, index) {
                      final pic = composingMessage[index];
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.deepPurple.shade100),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                    pic['url']!, height: 60, width: 60),
                                const SizedBox(height: 4),
                                Text(
                                  pic['desc']!,
                                  style: const TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Bottone per rimuovere il singolo pittogramma
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => rimozione(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.close, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Tasto INVIO
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FloatingActionButton(
                    mini: false,
                    backgroundColor: Colors.deepPurple,
                    onPressed: invio,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
