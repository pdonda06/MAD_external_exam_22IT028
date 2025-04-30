import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/helpers/custom_route_animation.dart';
import '/screens/text_to_speech_screen.dart';
import 'package:provider/provider.dart';
import '/screens/app_screen.dart';
import '/providers/auth.dart';
import '/screens/auth_screen.dart';
import 'providers/notes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.bottom,
    ],
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Notes>(
          update: (ctx, authData, previousNotes) => Notes(
            authData.token != null ? authData.token! : '',
            authData.userId != null ? authData.userId! : '',
            previousNotes!.notes,
          ),
          create: (ctx) => Notes('', '', []),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomRouteAnimation(),
              },
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6C63FF),
              primary: const Color(0xFF6C63FF),
              secondary: const Color(0xFF03DAC5),
              tertiary: const Color(0xFFFF6B6B),
              background: const Color(0xFFF8F9FA),
              surface: Colors.white,
              error: const Color(0xFFFF4B4B),
              brightness: Brightness.light,
            ),
            textTheme: TextTheme(
              displayLarge: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 32,
              ),
              displayMedium: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
              titleLarge: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
              titleMedium: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
              titleSmall: GoogleFonts.poppins(
                color: const Color(0xFF757575),
                fontSize: 14,
              ),
              bodyLarge: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontSize: 16,
              ),
              bodyMedium: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontSize: 14,
              ),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF6C63FF),
              unselectedItemColor: Color(0xFF757575),
              elevation: 8,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          home: (authData.isAuth)
              ? const AppScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator())
                          : const AuthScreen(),
                ),
          routes: {
            TextToSpeechScreen.routeName: (context) =>
                const TextToSpeechScreen(),
            AppScreen.routeName: (context) => const AppScreen(),
          },
        ),
      ),
    );
  }
}
