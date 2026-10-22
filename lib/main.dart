import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'registro.dart';
import 'login.dart';
import 'perfil.dart';
import 'wallet/wallet_screen.dart';
import 'wallet/recharge_screen.dart';
import 'servicios/home_screen.dart';
import 'servicios/mis_eventos_screen.dart';

import 'notificaciones/notificaciones_screen.dart';

const Color colorPrimario = Color(0xFF6155F5);
const Color colorLogin = Color(0xFF5263FA);
const Color colorFondo = Color(0xFFFFFFFF);
const Color colorTarjeta = Color(0xFFE5E5EA);
const Color colorError = Color(0xFFDC2626);

void main() {
  runApp(const EventosApp());
}

class EventosApp extends StatelessWidget {
  const EventosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventos',
      theme: ThemeData(fontFamily: GoogleFonts.poppins().fontFamily,
        
        useMaterial3: true,
        scaffoldBackgroundColor: colorFondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimario,
          primary: colorPrimario,
          error: colorError,
          surface: colorFondo,
        ),

        // Tipografía general
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ).apply(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),

        // Barra superior
        appBarTheme: AppBarTheme(
          backgroundColor: colorFondo,
          foregroundColor: Colors.black87,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            
          ),
        ),

        // Botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimario,
            foregroundColor: colorFondo,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Campos de texto
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.poppins(fontSize: 16),
          hintStyle: GoogleFonts.poppins(fontSize: 14),
          prefixIconColor: colorPrimario,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: colorPrimario,
              width: 2,
            ),
          ),
        ),

        // Tarjetas
        cardTheme: const CardThemeData(
          color: colorTarjeta,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      initialRoute: '/login',

      routes: { // Define las rutas de la aplicación
        '/registro': (context) => const Registro(),
        '/login': (context) => const Login(),
        '/perfil': (context) => const Perfil(),
        '/wallet/wallet': (context) => const WalletScreen(),
        '/recharge': (context) => const RechargeScreen(),
        '/home': (context) => const HomeScreen(),
        '/mis-eventos': (context) => const MisEventosScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
      },
    );
  }
}