import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ebook_provider.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EbookProvider()),
      ],
      child: const EbookLibraryApp(),
    ),
  );
}

class EbookLibraryApp extends StatelessWidget {
  const EbookLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Ebook Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4037), // Brown wooden color
          primary: const Color(0xFF5D4037),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), 
      ),
      home: const LibraryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
