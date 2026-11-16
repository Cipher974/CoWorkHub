import 'package:flutter/material.dart';
import 'screens/resources_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoWorkHub',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const ResourcesScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'screens/home_shell.dart';

// void main() => runApp(const CoWorkHubApp());

// class CoWorkHubApp extends StatelessWidget {
//   const CoWorkHubApp({super.key});

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         title: 'CoWorkHub',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
//         home: const HomeShell(),
//       );
// }