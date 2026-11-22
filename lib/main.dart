import 'servicios/sesion_usuario.dart';

import 'package:eventos_app/base_datos/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper.iniciarDB();
  final version = await db.getVersion();
  debugPrint(
    'Versión de la base de datos: $version',
  ); // Imprime la versión actual de la base de datos

  final tablas = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'",
  );

  debugPrint(
    'Tablas en la base de datos: $tablas',
  ); // Imprime las tablas existentes en la base de datos
  runApp(const EventosApp());
}

class EventosApp extends StatelessWidget {
  const EventosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventos',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,

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
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ).apply(fontFamily: GoogleFonts.poppins().fontFamily),

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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: colorPrimario, width: 2),
          ),
        ),

        // Tarjetas
        cardTheme: const CardThemeData(
          color: colorTarjeta,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      initialRoute: '/login',

      routes: {
        // Define las rutas de la aplicación
        '/registro': (context) => const Registro(),
        '/login': (context) => const Login(),
        '/perfil': (context) =>
            SesionUsuario.estaAutenticado ? const Perfil() : const Login(),
        '/wallet/wallet': (context) => SesionUsuario.estaAutenticado
            ? const WalletScreen()
            : const Login(),
        '/recharge': (context) => SesionUsuario.estaAutenticado
            ? const RechargeScreen()
            : const Login(),
        '/home': (context) =>
            SesionUsuario.estaAutenticado ? const HomeScreen() : const Login(),
        '/mis-eventos': (context) => SesionUsuario.estaAutenticado
            ? const MisEventosScreen()
            : const Login(),
        '/notificaciones': (context) => SesionUsuario.estaAutenticado
            ? const NotificacionesScreen()
            : const Login(),
      },
    );
  }
}
