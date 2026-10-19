import 'package:flutter/material.dart';
import 'demo_store.dart';
import 'theme.dart';
import 'screens/welcome_screen.dart';

class LoopChatApp extends StatefulWidget {
  const LoopChatApp({super.key});

  @override
  State<LoopChatApp> createState() => _LoopChatAppState();
}

class _LoopChatAppState extends State<LoopChatApp> {
  final store = DemoStore();

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      title: 'Loop Chat',
      debugShowCheckedModeBanner: false,
      theme: LoopTheme.light,
      darkTheme: LoopTheme.dark,
      themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: WelcomeScreen(store: store),
    ),
  );
}
