import 'package:flutter/material.dart';
import 'screens/home_shell.dart';

void main() => runApp(const CoWorkHubApp());

class CoWorkHubApp extends StatelessWidget {
  const CoWorkHubApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CoWorkHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const HomeShell(),
      );
}
