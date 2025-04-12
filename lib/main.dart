import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petzy/firebase_options.dart';
import 'package:petzy/providers/activities_provider.dart';
import 'package:petzy/providers/auth_provider.dart';
import 'package:petzy/providers/favorites_provider.dart';
import 'package:petzy/providers/pet_provider.dart';
import 'package:petzy/screens/add_pet_screen.dart';
import 'package:petzy/screens/auth/auth_wrapper.dart';
import 'package:petzy/screens/auth/login_screen.dart';
import 'package:petzy/screens/auth/register_screen.dart';
import 'package:petzy/screens/home/home_screen.dart';
import 'package:petzy/screens/pet_detail_screen.dart';
import 'package:petzy/screens/pet_swipe_screen.dart';
import 'package:petzy/utils/theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: '.env');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed: $e',
              style: const TextStyle(color: Colors.red, fontSize: 18)),
        ),
      ),
    ));
  }
  }

  class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PetProvider>(
          create: (context) => PetProvider(),
          update: (context, auth, petProvider) => petProvider!..loadPets(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (context) => FavoritesProvider(),
          update: (context, auth, favoritesProvider) {
            if (auth.user != null) {
              favoritesProvider!.initialize(auth.user!.uid);
            }
            return favoritesProvider!;
          },
        ),
        ChangeNotifierProvider(
            create: (_) => ActivitiesProvider()..loadActivities()),
      ],
      child: MaterialApp(
        title: 'Pet Adoption & Fostering',
        theme: appTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/pet_detail': (context) => const PetDetailScreen(),
          '/add_pet': (context) => const AddPetScreen(),
          '/swipe': (context) => const PetSwipeScreen(),
        },
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          );
        },
      ),
    );
  }
}
