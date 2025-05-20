import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
       appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: 
          const EdgeInsets.all(12.0),
          child: Form(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 50.0,),
              Text(
                'No info',
                textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 64.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.red,
              ),
              ),
            ],
          ))
        ),
      ),
    );
  }
}