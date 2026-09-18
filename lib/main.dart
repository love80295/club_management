import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_clubs_screen.dart';
import 'screens/club_details_screen.dart';
import 'screens/my_clubs_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_club_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/club_admin_panel_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/explore': (context) => const ExploreClubsScreen(),
        '/clubdetails': (context) => const ClubDetailsScreen(),
        '/myclubs': (context) => const MyClubsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/createclub': (context) => const CreateClubScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/adminpanel': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final clubId = args is int ? args : 0;
          return ClubAdminPanelScreen(clubId: clubId);
        },
        '/createevent': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final clubId = args is int ? args : 0;
          return CreateEventScreen(clubId: clubId);
        },
      },
    );
  }
}