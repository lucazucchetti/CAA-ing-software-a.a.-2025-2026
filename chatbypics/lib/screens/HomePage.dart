import 'package:chatbypics/services/auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget{
  const Homepage({super.key});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Benvenuto'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: Auth().signOut),
    );
  }

}