import 'package:flutter/material.dart';
import 'package:steps_tracker/data/BootsState.dart';
import 'package:steps_tracker/bootsEditorPage.dart';
import 'package:steps_tracker/distanceEditorPage.dart';
import 'package:steps_tracker/mainPage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (ctx) => BootsState(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Steps Counter',
      initialRoute: '/',
      routes: {
        '/': (ctx) => MainPage(),
        '/edit-boots': (ctx) => BootsEditorPage(),
        '/edit-distance': (ctx) => DistanceEditorPage(),
      },
    );
  }
}
