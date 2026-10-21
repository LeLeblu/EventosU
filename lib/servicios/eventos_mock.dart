import 'evento.dart';

/// Catálogo de eventos de ejemplo (datos fijos, sin base de datos).

// ----------------------------- Tecnología -----------------------------
const conferenciaIaMock = Evento(
  nombre: 'Conferencia de Inteligencia Artificial',
  descripcion:
      'Un espacio donde se compartirán las novedades de la inteligencia '
      'artificial y su uso en la educación y el desarrollo de software.\n\n'
      'La conferencia tendrá una duración de 45 minutos, seguida de un '
      'espacio de preguntas del público.\n\n'
      'Importante: se recomiendan conocimientos básicos sobre IA.',
  categoria: 'Tecnología',
  subcategoria: 'Conferencias',
  organizador: 'Facultad de Tecnología',
  fecha: '2 de octubre de 2026',
  hora: '10:00 a.m.',
  ubicacion: 'Auditorio principal',
  precio: 'Gratis',
  cupos: 80,
);

const tallerFlutterMock = Evento(
  nombre: 'Taller de Flutter',
  descripcion:
      'Taller práctico para crear tu primera aplicación móvil con Flutter y '
      'Dart. Trae tu portátil con Flutter instalado.\n\n'
      'Al final del taller tendrás una app funcionando en el emulador.',
  categoria: 'Tecnología',
  subcategoria: 'Talleres',
  organizador: 'Facultad de Tecnología',
  fecha: '5 de octubre de 2026',
  hora: '2:00 p.m.',
  ubicacion: 'Sala de sistemas 3',
  precio: '\$15.000',
  cupos: 25,
);

const hackathonMock = Evento(
  nombre: 'Feria de innovación UNAD',
  descripcion:
      'Muestra de proyectos tecnológicos de estudiantes, con zona de '
      'prototipos, robótica y realidad virtual.\n\n'
      'Habrá premiación a los tres mejores proyectos.',
  categoria: 'Tecnología',
  subcategoria: 'Ferias',
  organizador: 'Escuela de Ciencias Básicas, Tecnología e Ingeniería',
  fecha: '10 de octubre de 2026',
  hora: '8:00 a.m.',
  ubicacion: 'Laboratorio de innovación',
  precio: 'Gratis',
  cupos: 8,
  disponibilidad: 'A punto de cerrar',
);

const foroMock = Evento(
  nombre: 'Foro de ciberseguridad',
  descripcion:
      'Panel con expertos sobre cómo proteger tus datos y tus aplicaciones. '
      'Incluye casos reales y recomendaciones prácticas.',
  categoria: 'Tecnología',
  subcategoria: 'Foros',
  organizador: 'Facultad de Tecnología',
  fecha: '14 de octubre de 2026',
  hora: '4:00 p.m.',
  ubicacion: 'Sala virtual',
  precio: 'Gratis',
  cupos: 120,
);

// ------------------------------ Deportes ------------------------------
const voleibolMock = Evento(
  nombre: 'Campeonato de Voleibol',
  descripcion:
      'Encuentro interfacultades de voleibol mixto. Los equipos se arman '
      'el mismo día; solo debes llegar con ropa deportiva.',
  categoria: 'Deportes',
  subcategoria: 'Voleibol',
  organizador: 'Bienestar Universitario · Deportes',
  fecha: '1 de octubre de 2026',
  hora: '6:00 p.m.',
  ubicacion: 'Cancha Bloque 3',
  precio: 'Gratis',
  cupos: 30,
);

const futbolMock = Evento(
  nombre: 'Partido Ligas menores',
  descripcion:
      'Torneo relámpago de fútbol 5. La inscripción es individual y se '
      'asigna equipo al llegar.\n\nIncluye hidratación para los jugadores.',
  categoria: 'Deportes',
  subcategoria: 'Fútbol',
  organizador: 'Bienestar Universitario · Deportes',
  fecha: '4 de octubre de 2026',
  hora: '3:00 p.m.',
  ubicacion: 'Cancha B',
  precio: '\$10.000',
  cupos: 40,
);

const baloncestoMock = Evento(
  nombre: 'Torneo de baloncesto 3x3',
  descripcion:
      'Torneo de baloncesto en modalidad 3x3 con premiación para el equipo '
      'campeón.',
  categoria: 'Deportes',
  subcategoria: 'Baloncesto',
  organizador: 'Bienestar Universitario · Deportes',
  fecha: '9 de octubre de 2026',
  hora: '5:00 p.m.',
  ubicacion: 'Coliseo central',
  precio: '\$5.000',
  cupos: 0,
  disponibilidad: 'Agotado',
);

// ------------------------------- Música -------------------------------
const talentosMock = Evento(
  nombre: 'Música en vivo',
  descripcion:
      'Presentaciones musicales de estudiantes de todas las escuelas. '
      'Ven a apoyar el talento de la universidad.',
  categoria: 'Música',
  subcategoria: 'Conciertos',
  organizador: 'Bienestar Universitario · Cultura',
  fecha: '3 de octubre de 2026',
  hora: '7:00 p.m.',
  ubicacion: 'Plaza central',
  precio: 'Gratis',
  cupos: 6,
  disponibilidad: 'A punto de cerrar',
);

const conciertoMock = Evento(
  nombre: 'Concierto acústico en vivo',
  descripcion:
      'Concierto universitario en formato acústico con artistas invitados.',
  categoria: 'Música',
  subcategoria: 'Conciertos',
  organizador: 'Bienestar Universitario · Cultura',
  fecha: '6 de octubre de 2026',
  hora: '8:00 p.m.',
  ubicacion: 'Auditorio A',
  precio: '\$20.000',
  cupos: 35,
);

const festivalMock = Evento(
  nombre: 'Festival universitario',
  descripcion:
      'Festival con bandas locales, comida y actividades culturales durante '
      'toda la tarde.',
  categoria: 'Música',
  subcategoria: 'Festivales',
  organizador: 'Bienestar Universitario · Cultura',
  fecha: '12 de octubre de 2026',
  hora: '6:00 p.m.',
  ubicacion: 'Auditorio B',
  precio: '\$25.000',
  cupos: 100,
);

const djMock = Evento(
  nombre: 'Noche electrónica DJ\'s',
  descripcion:
      'Sesión de música electrónica con DJ\'s estudiantes y luces en vivo.',
  categoria: 'Música',
  subcategoria: 'DJ\'s',
  organizador: 'Bienestar Universitario · Cultura',
  fecha: '17 de octubre de 2026',
  hora: '9:00 p.m.',
  ubicacion: 'Plazoleta de comidas',
  precio: '\$15.000',
  cupos: 50,
);

const eventosMock = [
  conferenciaIaMock,
  tallerFlutterMock,
  hackathonMock,
  foroMock,
  voleibolMock,
  futbolMock,
  baloncestoMock,
  talentosMock,
  conciertoMock,
  festivalMock,
  djMock,
];

/// Eventos que se muestran en "Próximos eventos" del inicio.
const proximosEventosMock = [
  talentosMock,
  futbolMock,
  conferenciaIaMock,
  conciertoMock,
];
