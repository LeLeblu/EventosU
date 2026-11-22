import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // rutaAlternativa permite probar el mismo esquema en una base aislada.
  static Future<Database> iniciarDB({String? rutaAlternativa}) async {
    final ruta = await getDatabasesPath();
    final rutaCompleta = rutaAlternativa ?? join(ruta, 'eventosu.db');

    return await openDatabase(
      rutaCompleta,
      version: 8,
      singleInstance: rutaAlternativa == null,

      // Activar las claves foráneas
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // Crear las tablas por primera vez
      onCreate: (db, version) async {
        // TABLA USUARIO
        await db.execute('''
          CREATE TABLE usuario (
            idUsuarios INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            correo TEXT NOT NULL UNIQUE,
            contrasenaHash TEXT NOT NULL,
            fotoPerfil BLOB,
            fechaRegistro TEXT NOT NULL,
            programa TEXT,
            rol TEXT NOT NULL DEFAULT 'usuario'
          )
        ''');

        // TABLA CATEGORIA
        await db.execute('''
          CREATE TABLE categoria (
            idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL UNIQUE,
            descripcion TEXT
          )
        ''');

        // TABLA EVENTO
        await db.execute('''
          CREATE TABLE evento (
            idEvento INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT,
            fecha TEXT NOT NULL,
            hora TEXT NOT NULL,
            ubicacion TEXT NOT NULL,
            precio INTEGER NOT NULL DEFAULT 0,
            cuposDisponibles INTEGER NOT NULL DEFAULT 0,
            imagen BLOB,
            idCategoria INTEGER NOT NULL,

            FOREIGN KEY (idCategoria)
              REFERENCES categoria(idCategoria)
          )
        ''');

        // TABLA INSCRIPCION
        await db.execute('''
          CREATE TABLE inscripcion (
            idInscripcion INTEGER PRIMARY KEY AUTOINCREMENT,
            idUsuario INTEGER NOT NULL,
            idEvento INTEGER NOT NULL,
            fechaInscripcion TEXT NOT NULL,
            estado TEXT NOT NULL DEFAULT 'activa',

            FOREIGN KEY (idUsuario)
              REFERENCES usuario(idUsuarios),

            FOREIGN KEY (idEvento)
              REFERENCES evento(idEvento),

            UNIQUE (idUsuario, idEvento)
          )
        ''');
        // TABLA BILLETERA
        await db.execute('''
          CREATE TABLE billetera (
          idBilletera INTEGER PRIMARY KEY AUTOINCREMENT,
          idUsuario INTEGER NOT NULL UNIQUE,
          saldo INTEGER NOT NULL DEFAULT 0
          CHECK (saldo >= 0),
          fechaActualizacion TEXT NOT NULL,

          FOREIGN KEY (idUsuario)
            REFERENCES usuario(idUsuarios)
  )
        ''');

        // TABLA PAGO
        await db.execute('''
          CREATE TABLE pago (
          idPago INTEGER PRIMARY KEY AUTOINCREMENT,
          idInscripcion INTEGER NOT NULL UNIQUE,
          monto INTEGER NOT NULL CHECK (monto > 0), 
          fechaPago TEXT NOT NULL,
          estado TEXT NOT NULL DEFAULT 'exitoso',

          FOREIGN KEY (idInscripcion)
            REFERENCES inscripcion(idInscripcion)
  )
''');
        // TABLA MOVIMIENTO
        await db.execute('''
        CREATE TABLE movimiento (
        idMovimiento INTEGER PRIMARY KEY AUTOINCREMENT,
        idBilletera INTEGER NOT NULL,
        idPago INTEGER UNIQUE,
        tipo TEXT NOT NULL
        CHECK (tipo IN ('recarga', 'pago')),
        monto INTEGER NOT NULL CHECK (monto > 0),
        descripcion TEXT,
        fechaMovimiento TEXT NOT NULL,

      FOREIGN KEY (idBilletera)
        REFERENCES billetera(idBilletera),

      FOREIGN KEY (idPago)
        REFERENCES pago(idPago)
  )
''');

        // TABLA NOTIFICACION
        await db.execute('''
          CREATE TABLE notificacion (
          idNotificacion INTEGER PRIMARY KEY AUTOINCREMENT,
          idUsuario INTEGER NOT NULL,
          titulo TEXT NOT NULL,
          mensaje TEXT NOT NULL,
          fecha TEXT NOT NULL,
          leida INTEGER NOT NULL DEFAULT 0
          CHECK (leida IN (0, 1)),

        FOREIGN KEY (idUsuario)
          REFERENCES usuario(idUsuarios)
  )
''');
      },

      // Actualizar la base de datos
      onUpgrade: (db, oldVersion, newVersion) async {
        // De la versión 1 a la 2
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE categoria (
              idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE,
              descripcion TEXT
            )
          ''');
        }

        // De la versión 2 a la 3
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE evento (
              idEvento INTEGER PRIMARY KEY AUTOINCREMENT,
              titulo TEXT NOT NULL,
              descripcion TEXT,
              fecha TEXT NOT NULL,
              hora TEXT NOT NULL,
              ubicacion TEXT NOT NULL,
              precio INTEGER NOT NULL DEFAULT 0,
              cuposDisponibles INTEGER NOT NULL DEFAULT 0,
              imagen BLOB,
              idCategoria INTEGER NOT NULL,

              FOREIGN KEY (idCategoria)
                REFERENCES categoria(idCategoria)
            )
          ''');
        }

        // De la versión 3 a la 4
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE inscripcion (
              idInscripcion INTEGER PRIMARY KEY AUTOINCREMENT,
              idUsuario INTEGER NOT NULL,
              idEvento INTEGER NOT NULL,
              fechaInscripcion TEXT NOT NULL,
              estado TEXT NOT NULL DEFAULT 'activa',

              FOREIGN KEY (idUsuario)
                REFERENCES usuario(idUsuarios),

              FOREIGN KEY (idEvento)
                REFERENCES evento(idEvento),

              UNIQUE (idUsuario, idEvento)
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
              CREATE TABLE billetera (
              idBilletera INTEGER PRIMARY KEY AUTOINCREMENT,
              idUsuario INTEGER NOT NULL UNIQUE,
              saldo INTEGER NOT NULL DEFAULT 0
              CHECK (saldo >= 0),
              fechaActualizacion TEXT NOT NULL,

              FOREIGN KEY (idUsuario)
                REFERENCES usuario(idUsuarios)
    )
  ''');
        }
        // De la versión 5 a la 6
        if (oldVersion < 6) {
          await db.execute('''
              CREATE TABLE pago (
              idPago INTEGER PRIMARY KEY AUTOINCREMENT,
              idInscripcion INTEGER NOT NULL UNIQUE,
              monto INTEGER NOT NULL CHECK (monto > 0),
              fechaPago TEXT NOT NULL,
              estado TEXT NOT NULL DEFAULT 'exitoso',

              FOREIGN KEY (idInscripcion)
                REFERENCES inscripcion(idInscripcion)
    )
            ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
              CREATE TABLE movimiento (
              idMovimiento INTEGER PRIMARY KEY AUTOINCREMENT,
              idBilletera INTEGER NOT NULL,
              idPago INTEGER UNIQUE,
              tipo TEXT NOT NULL
              CHECK (tipo IN ('recarga', 'pago')),
              monto INTEGER NOT NULL CHECK (monto > 0),
              descripcion TEXT,
              fechaMovimiento TEXT NOT NULL,

              FOREIGN KEY (idBilletera)
                REFERENCES billetera(idBilletera),

              FOREIGN KEY (idPago)
                REFERENCES pago(idPago)
    )
            ''');
        }
        // De la versión 7 a la 8
        if (oldVersion < 8) {
          await db.execute('''
              CREATE TABLE notificacion (
              idNotificacion INTEGER PRIMARY KEY AUTOINCREMENT,
              idUsuario INTEGER NOT NULL,
              titulo TEXT NOT NULL,
              mensaje TEXT NOT NULL,
              fecha TEXT NOT NULL,
              leida INTEGER NOT NULL DEFAULT 0
              CHECK (leida IN (0, 1)),

              FOREIGN KEY (idUsuario)
                REFERENCES usuario(idUsuarios)
    )
            ''');
        }
      },
    );
  }
}
