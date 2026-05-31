import 'package:blood_link_app/screens/history/HistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/AuthProvider.dart';
import 'providers/BloodProvider.dart';
import 'screens/splash/SplashScreen.dart';
import 'screens/auth/LoginScreen.dart';
import 'screens/auth/SignUpScreen.dart';
import 'screens/home/HomeScreen.dart';
import 'screens/profile/ProfileScreen.dart';
import 'screens/profile/EditProfileScreen.dart';
import 'providers/ThemeProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BloodProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BloodLink',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFFC62828),
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
              fontFamily: 'Outfit',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFC62828),
                primary: const Color(0xFFC62828),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFFC62828),
              scaffoldBackgroundColor: const Color(0xFF121212),
              useMaterial3: true,
              fontFamily: 'Outfit',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFC62828),
                primary: const Color(0xFFC62828),
                brightness: Brightness.dark,
              ),
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/home': (context) => const HomeScreen(),
              '/history': (context) => const HistoryScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
