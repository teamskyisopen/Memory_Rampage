import 'package:flutter/material.dart';
import 'package:memory_rampage/screens/home_screen.dart';
import 'package:memory_rampage/utils/colors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_rampage/music/background_music_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await BackgroundMusicService.loadMusic();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Rampage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: gamePrimaryPurple,
        scaffoldBackgroundColor: gameBackgroundLightGray,
        fontFamily: 'SansSerif', // Choose a nice font
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gamePrimaryPurple,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
           style: OutlinedButton.styleFrom(
             foregroundColor: gamePrimaryPurple,
             side: const BorderSide(color: gamePrimaryPurple),
             textStyle: const TextStyle(fontSize: 18),
             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
           )
        ),
        cardTheme: CardTheme(
          elevation: 4,
          color: gameCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: gameBackgroundLightGray, // Or Colors.white
           shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}