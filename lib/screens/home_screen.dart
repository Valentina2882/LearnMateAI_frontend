import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/horarios_provider.dart';
import '../providers/examenes_provider.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/horarios_screen.dart';
import '../screens/examenes_screen.dart';
import '../screens/bienestar_screen.dart';
import '../screens/kora_ia_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../widgets/smart_insight_card.dart';
import '../widgets/ai_alert_card.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _horariosLoaded = false;
  bool _examenesLoaded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
              Colors.grey[900]!,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer3<AuthProvider, HorariosProvider, ExamenesProvider>(
            builder: (context, authProvider, horariosProvider, examenesProvider, child) {
              if (authProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.cyan[300],
                    strokeWidth: 3,
                  ),
                );
              }

              final user = authProvider.user;
              
              // Cargar datos si no están cargados (solo una vez)
              if (user != null) {
                if (!_horariosLoaded && horariosProvider.horarios.isEmpty && !horariosProvider.isLoading) {
                  _horariosLoaded = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    horariosProvider.fetchHorarios();
                  });
                }
                if (!_examenesLoaded && examenesProvider.examenes.isEmpty && !examenesProvider.isLoading) {
                  _examenesLoaded = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    examenesProvider.fetchExamenes();
                  });
                }
              }
              
              return Column(
                children: [
                  // Header fijo
                  _buildCognitiveHeader(context, authProvider, user),
                  // Contenido scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUserGreeting(context, user),
                              _buildSmartInsightsSection(context, horariosProvider, examenesProvider, user),
                              const SizedBox(height: 20),
                              _buildAiAlertsSection(context, examenesProvider),
                              const SizedBox(height: 20),
                              _buildTodayActivitiesSection(context, horariosProvider),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ==================== HEADER COGNITIVO ====================
  Widget _buildCognitiveHeader(BuildContext context, AuthProvider authProvider, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF4F46E5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Icono sutil
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            // Texto sutil
            const Text(
              'LearnMate',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            // Badge decorativo sutil
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Menú de tres puntos sutil
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: const Color(0xFF1E1E1E),
              onSelected: (value) async {
                if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen(),
                    ),
                  );
                } else if (value == 'logout') {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Configurar perfil',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red.withOpacity(0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SALUDO DEL USUARIO ====================
  Widget _buildUserGreeting(BuildContext context, dynamic user) {
    final firstName = user?.nombre?.split(' ')[0] ?? 'Estudiante';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar del usuario con gradiente
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'E',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Saludo con emoji
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '👋',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Nombre del usuario con gradiente
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          firstName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ==================== TARJETAS INTELIGENTES ====================
  List<Widget> _buildSmartInsightCards(BuildContext context, HorariosProvider horariosProvider, ExamenesProvider examenesProvider, dynamic user) {
    final cards = <Widget>[];
    
    // CARD 1 - Próxima Clase
    if (horariosProvider.horarios.isEmpty) {
      // No hay horario cargado
      cards.add(
        SmartInsightCard(
          emoji: '📘',
          title: 'Próxima Clase',
          subtitle: 'Aún no tenemos tu horario.',
          extra: 'Agrega tus clases para comenzar a ayudarte.',
          buttonText: 'Agregar horario',
          gradientColors: const [
            Color(0xFF6366F1),
            Color(0xFF4F46E5),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HorariosScreen(),
              ),
            );
          },
        ),
      );
    } else {
      // Buscar próxima clase de hoy
      // TODO: Implementar lógica para encontrar próxima clase usando horariosMateriasService
      cards.add(
        SmartInsightCard(
          emoji: '📘',
          title: 'Próxima Clase',
          subtitle: 'Hoy no tienes clases programadas.',
          extra: 'Buen día para adelantar materias 😉',
          buttonText: 'Ver horario',
          gradientColors: const [
            Color(0xFF6366F1),
            Color(0xFF4F46E5),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HorariosScreen(),
              ),
            );
          },
        ),
      );
    }
    
    // CARD 2 - Examen
    final examenesProximos = examenesProvider.getExamenesProximos();
    if (examenesProximos.isEmpty) {
      if (examenesProvider.examenes.isEmpty) {
        // Sin exámenes cargados
        cards.add(
          SmartInsightCard(
            emoji: '📝',
            title: 'Exámenes',
            subtitle: 'No se detectan exámenes hoy.',
            extra: 'Aprovecha para repasar.',
            buttonText: 'Agregar examen',
            gradientColors: const [
              Color(0xFFFF7043),
              Color(0xFFE64A19),
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamenesScreen(),
                ),
              );
            },
          ),
        );
      } else {
        // Hay exámenes pero no próximos
        cards.add(
          SmartInsightCard(
            emoji: '📝',
            title: 'Exámenes',
            subtitle: 'No se detectan exámenes próximos.',
            extra: 'Aprovecha para repasar.',
            buttonText: 'Ver exámenes',
            gradientColors: const [
              Color(0xFFFF7043),
              Color(0xFFE64A19),
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamenesScreen(),
                ),
              );
            },
          ),
        );
      }
    } else {
      // Hay examen próximo
      final examen = examenesProximos.first;
      final diasRestantes = examen.fechaEval != null 
          ? examen.fechaEval!.difference(DateTime.now()).inDays
          : 0;
      String riskLevel = '🟢 Bajo';
      Color riskColor = const Color(0xFF66BB6A);
      if (diasRestantes <= 2) {
        riskLevel = '🔴 Alto';
        riskColor = const Color(0xFFEF5350);
      } else if (diasRestantes <= 5) {
        riskLevel = '🟡 Medio';
        riskColor = const Color(0xFFFFA726);
      }
      
      cards.add(
        SmartInsightCard(
          emoji: '📝',
          title: examen.materia?.nombre ?? 'Examen',
          subtitle: diasRestantes == 0 
              ? 'Es hoy'
              : diasRestantes == 1 
                  ? 'Es mañana'
                  : 'Faltan $diasRestantes días',
          riskLevel: riskLevel,
          riskColor: riskColor,
          buttonText: 'Estudiar ahora',
          gradientColors: const [
            Color(0xFFFF7043),
            Color(0xFFE64A19),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExamenesScreen(),
              ),
            );
          },
        ),
      );
    }
    
    // CARD 3 - Kora AI
    final tieneDatos = horariosProvider.horarios.isNotEmpty || examenesProvider.examenes.isNotEmpty;
    if (!tieneDatos) {
      cards.add(
        SmartInsightCard(
          emoji: '🤖',
          title: 'Kora AI',
          subtitle: 'Aún te estoy conociendo.',
          extra: 'Cuéntame por dónde empezamos.',
          buttonText: 'Comenzar',
          gradientColors: const [
            Color(0xFFEF5350),
            Color(0xFFE53935),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KoraIAScreen(),
              ),
            );
          },
        ),
      );
    } else {
      cards.add(
        SmartInsightCard(
          emoji: '🤖',
          title: 'Kora AI',
          subtitle: 'Hoy no necesitas un plan intensivo.',
          extra: 'Buen trabajo 😌',
          buttonText: 'Comenzar',
          gradientColors: const [
            Color(0xFFEF5350),
            Color(0xFFE53935),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KoraIAScreen(),
              ),
            );
          },
        ),
      );
    }
    
    // CARD 4 - Bienestar
    cards.add(
      SmartInsightCard(
        emoji: '🧠',
        title: 'Bienestar',
        subtitle: 'Aún estamos conociéndote.',
        extra: 'Estamos aquí para ti.',
        buttonText: 'Ver estado',
        gradientColors: const [
          Color(0xFF66BB6A),
          Color(0xFF43A047),
        ],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BienestarScreen(),
            ),
          );
        },
      ),
    );
    
    // CARD 5 - Perfil
    final isProfileCompleted = user?.isProfileCompleted ?? false;
    if (!isProfileCompleted) {
      // Calcular porcentaje de completitud
      int camposCompletados = 0;
      int totalCampos = 6;
      if (user?.nombre != null && user!.nombre.isNotEmpty) camposCompletados++;
      if (user?.apellido != null && user!.apellido!.isNotEmpty) camposCompletados++;
      if (user?.telefono != null && user!.telefono!.isNotEmpty) camposCompletados++;
      if (user?.carrera != null && user!.carrera!.isNotEmpty) camposCompletados++;
      if (user?.semestre != null) camposCompletados++;
      if (user?.sistemaCalificacion != null) camposCompletados++;
      
      final porcentaje = camposCompletados / totalCampos;
      
      String mensaje = 'Completa tu perfil para personalizar tu experiencia.';
      if (porcentaje >= 0.5) {
        mensaje = 'Vas muy bien, solo falta un poco más ✨';
      }
      
      cards.add(
        SmartInsightCard(
          emoji: '👤',
          title: 'Perfil',
          subtitle: mensaje,
          progressValue: porcentaje,
          buttonText: 'Completar',
          gradientColors: const [
            Color(0xFF26C6DA),
            Color(0xFF00ACC1),
          ],
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CompleteProfileScreen(),
            );
          },
        ),
      );
    } else {
      cards.add(
        SmartInsightCard(
          emoji: '👤',
          title: 'Perfil',
          subtitle: 'Perfil completo. ',
          extra: 'Gracias por confiar en LearnMate.',
          progressValue: 1.0,
          buttonText: 'Ver perfil',
          gradientColors: const [
            Color(0xFF26C6DA),
            Color(0xFF00ACC1),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileSettingsScreen(),
              ),
            );
          },
        ),
      );
    }
    
    return cards;
  }

  Widget _buildSmartInsightsSection(BuildContext context, HorariosProvider horariosProvider, ExamenesProvider examenesProvider, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Insights Inteligentes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            children: _buildSmartInsightCards(context, horariosProvider, examenesProvider, user),
          ),
        ),
      ],
    );
  }

  // ==================== ALERTAS IA ====================
  Widget _buildAiAlertsSection(BuildContext context, ExamenesProvider examenesProvider) {
    // Verificar si hay alertas reales
    final examenesProximos = examenesProvider.getExamenesProximos();
    final tieneAlertas = examenesProximos.isNotEmpty && 
        examenesProximos.any((e) => e.fechaEval != null && 
            e.fechaEval!.difference(DateTime.now()).inDays <= 3);
    
    if (!tieneAlertas) {
      // Sin alertas
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Alertas IA',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.15),
                        Colors.green.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF66BB6A).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF66BB6A),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No se detectan riesgos hoy. Buena suerte 💚',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Hay alertas
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Alertas IA',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...examenesProximos
              .where((e) => e.fechaEval != null && 
                  e.fechaEval!.difference(DateTime.now()).inDays <= 3)
              .take(2)
              .map((examen) {
                final diasRestantes = examen.fechaEval!.difference(DateTime.now()).inDays;
                return AiAlertCard(
                  type: diasRestantes <= 1 ? AlertType.danger : AlertType.warning,
                  title: 'Examen próximo: ${examen.materia?.nombre ?? 'Examen'}',
                  message: diasRestantes == 0 
                      ? '¡Tu examen es hoy! Asegúrate de repasar los puntos clave.'
                      : diasRestantes == 1
                          ? 'Tu examen es mañana. Te sugiero hacer un repaso final.'
                          : 'Tienes un examen en $diasRestantes días. Es buen momento para estudiar.',
                  actionText: 'Ver detalles',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExamenesScreen(),
                      ),
                    );
                  },
                );
              }),
        ],
      ),
    );
  }

  // ==================== ACTIVIDAD DE HOY ====================
  Widget _buildTodayActivitiesSection(BuildContext context, HorariosProvider horariosProvider) {
    final actividades = <Widget>[];
    
    // Verificar si hay horarios
    if (horariosProvider.horarios.isEmpty) {
      // No hay horario cargado
      actividades.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aún no tenemos tu horario.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Agrega tus clases para comenzar.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HorariosScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Agregar horario',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // TODO: Implementar lógica para obtener clases de hoy usando HorariosMaterialsService
      // Por ahora mostrar mensaje de que no hay clases hoy
      actividades.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoy no tienes clases programadas.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Buen día para adelantar materias 😉',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Actividad de Hoy',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...actividades,
        ],
      ),
    );
  }
}
