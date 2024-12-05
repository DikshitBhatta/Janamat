import 'package:flutter/material.dart';
import 'package:janamatfront/Pages/authScreen.dart';
import 'package:janamatfront/ocr/ocr.dart';
import 'package:provider/provider.dart';
import 'package:janamatfront/Pages/home.dart';
import 'package:janamatfront/providers/voting_provider.dart';
import 'package:janamatfront/providers/authenticationProvider.dart';  // Import AuthenticationProvider
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VotingProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()), // Add AuthenticationProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Janamat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, _) {
          // Check if user is authenticated, then navigate to Home, else show AuthScreen
          if (authProvider.user != null) {
            return Home();  // HomePage for authenticated users
          } else {
            return AuthScreen();  // AuthScreen for authentication (sign in or sign up)
          }
        },
      ),
    );
  }
}
