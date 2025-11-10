import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/bienestar_provider.dart';
import '../models/bienestar.dart';
import '../utils/profile_helper.dart';
import 'dart:ui';
import 'cuestionario_screen.dart';
import 'chat_bienestar_screen.dart';
import 'contactos_emergencia_screen.dart';

class BienestarScreen extends StatefulWidget {
  const BienestarScreen({super.key});

  @override
  State<BienestarScreen> createState() => _BienestarScreenState();
}

class _BienestarScreenState extends State<BienestarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final GlobalKey _cuestionariosKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
    
    // Cargar datos y verificar cuestionarios mensuales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosYVerificarCuestionarios();
    });
  }

  Future<void> _cargarDatosYVerificarCuestionarios() async {
    final bienestarProvider = Provider.of<BienestarProvider>(context, listen: false);
    await bienestarProvider.cargarDatos();
    
    // Verificar si el usuario ha completado los cuestionarios este mes
    final completados = bienestarProvider.getCuestionariosCompletadosEsteMes();
    final todosCompletados = completados.values.every((completado) => completado);
    
    if (!todosCompletados && mounted) {
      _mostrarModalCuestionariosMensuales(completados);
    }
  }

  void _mostrarModalCuestionariosMensuales(Map<TipoCuestionario, bool> completados) {
    TipoCuestionario? cuestionarioSeleccionado;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.psychology_rounded, color: Colors.pink, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cuestionarios Mensuales',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para un mejor seguimiento de tu bienestar, te recomendamos completar los cuestionarios mensualmente.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ...TipoCuestionario.values.map((tipo) {
              final estaCompletado = completados[tipo] ?? false;
                final estaSeleccionado = cuestionarioSeleccionado == tipo;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      if (!estaCompletado) {
                        setState(() {
                          cuestionarioSeleccionado = tipo;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: estaSeleccionado ? Colors.pink.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: estaSeleccionado ? Colors.pink : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                child: Row(
                  children: [
                    Icon(
                            estaCompletado 
                                ? Icons.check_circle 
                                : (estaSeleccionado ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                            color: estaCompletado 
                                ? Colors.green 
                                : (estaSeleccionado ? Colors.pink : Colors.grey),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                      tipo.nombre,
                      style: TextStyle(
                                color: estaCompletado 
                                    ? Colors.white 
                                    : (estaSeleccionado ? Colors.white : Colors.white70),
                                fontWeight: estaCompletado || estaSeleccionado 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                      ),
                    ),
                  ],
                      ),
                    ),
                ),
              );
            }),
          ],
        ),
          actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
          ),
          ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                
                // Si hay un cuestionario seleccionado, abrirlo directamente
                if (cuestionarioSeleccionado != null) {
                  final canAccess = await ProfileHelper.checkAndShowCompleteProfile(
                    context,
                    onComplete: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CuestionarioScreen(tipo: cuestionarioSeleccionado!),
                        ),
                      );
                    },
                  );
                  
                  if (canAccess) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CuestionarioScreen(tipo: cuestionarioSeleccionado!),
                      ),
                    );
                  }
                } else {
                  // Si no hay selección, ir a la pestaña y hacer scroll
                  _tabController.animateTo(0);
                  
                  // Esperar a que la pestaña cambie y luego hacer scroll
                  await Future.delayed(const Duration(milliseconds: 300));
                  
                  if (_cuestionariosKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _cuestionariosKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ir a Cuestionarios'),
          ),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPaginaInformacionYCuest(),
                        _buildPaginaEmocionesYChat(),
                        _buildPaginaContactos(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pink, Colors.red],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Bienestar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pink, Colors.red],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.psychology_rounded, size: 20),
                  text: 'Salud Mental',
                ),
                Tab(
                  icon: Icon(Icons.mood_rounded, size: 20),
                  text: 'Emociones',
                ),
                Tab(
                  icon: Icon(Icons.phone_rounded, size: 20),
                  text: 'Emergencias',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Página 1: Información sobre salud mental y cuestionarios
  Widget _buildPaginaInformacionYCuest() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionSaludMental(),
          const SizedBox(height: 24),
          _buildSeccionCuestionarios(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSeccionSaludMental() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: Colors.pink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Información sobre Salud Mental',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu bienestar mental es importante. Aquí encontrarás recursos para cuidar de tu salud emocional y psicológica.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                '🧠 Depresión',
                'La depresión es un trastorno del estado de ánimo que causa sentimientos persistentes de tristeza y pérdida de interés.',
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                '💭 Ansiedad',
                'La ansiedad es una respuesta natural al estrés, pero cuando es excesiva puede afectar tu vida diaria.',
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                '😴 Insomnio',
                'El insomnio es la dificultad para conciliar o mantener el sueño, lo que puede afectar tu bienestar general.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String descripcion) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionCuestionarios() {
    return Column(
      key: _cuestionariosKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Cuestionarios de Salud Mental',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCuestionarioCard(
          context,
          TipoCuestionario.phq9,
          'PHQ-9',
          'Cuestionario de Salud del Paciente para Depresión',
          '🧠',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildCuestionarioCard(
          context,
          TipoCuestionario.gad7,
          'GAD-7',
          'Escala de Ansiedad Generalizada',
          '💭',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildCuestionarioCard(
          context,
          TipoCuestionario.isi,
          'ISI',
          'Índice de Severidad del Insomnio',
          '😴',
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildCuestionarioCard(
    BuildContext context,
    TipoCuestionario tipo,
    String titulo,
    String descripcion,
    String emoji,
    Color color,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final canAccess = await ProfileHelper.checkAndShowCompleteProfile(
                  context,
                  onComplete: () {
                    // Después de completar el perfil, abrir el cuestionario
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CuestionarioScreen(tipo: tipo),
                      ),
                    );
                  },
                );
                
                if (canAccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CuestionarioScreen(tipo: tipo),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            descripcion,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Página 2: ¿Cómo te sientes hoy? y Chat
  Widget _buildPaginaEmocionesYChat() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionEmocionHoy(),
          const SizedBox(height: 24),
          _buildSeccionChat(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSeccionEmocionHoy() {
    return Consumer<BienestarProvider>(
      builder: (context, bienestarProvider, child) {
        // Obtener el valor de la emoción (ya está validado en el getter)
        // Agregar verificación adicional por si acaso durante hot reload
        double valor;
        try {
          valor = bienestarProvider.emocionActual;
          // Asegurar que el valor esté en rango válido
          if (valor.isNaN || valor.isInfinite) {
            valor = 5.0;
          } else {
            valor = valor.clamp(0.0, 10.0);
          }
        } catch (e) {
          // Si hay algún error, usar valor por defecto
          valor = 5.0;
        }
        
        // Obtener emoji y color según el valor (0-10)
        String getEmoji(double valor) {
          if (valor <= 2) return '😢'; // Muy mal
          if (valor <= 4) return '😐'; // Mal
          if (valor <= 6) return '🙂'; // Neutral
          if (valor <= 8) return '😊'; // Bien
          return '😄'; // Muy bien
        }
        
        Color getColor(double valor) {
          if (valor <= 2) return Colors.red;
          if (valor <= 4) return Colors.orange;
          if (valor <= 6) return Colors.yellow;
          if (valor <= 8) return Colors.lightGreen;
          return Colors.green;
        }
        
        String getTexto(double valor) {
          if (valor <= 2) return 'Muy mal';
          if (valor <= 4) return 'Mal';
          if (valor <= 6) return 'Regular';
          if (valor <= 8) return 'Bien';
          return 'Muy bien';
        }
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo te sientes hoy?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Emoji grande central
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: getColor(valor).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: getColor(valor).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          getEmoji(valor),
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Texto descriptivo
                  Center(
                    child: Text(
                      getTexto(valor),
                      style: TextStyle(
                        color: getColor(valor),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: getColor(valor),
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: getColor(valor),
                      overlayColor: getColor(valor).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: valor,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (newValue) {
                        bienestarProvider.setEmocionActual(newValue);
                      },
                    ),
                  ),
                  // Etiquetas de los extremos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Muy mal',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Muy bien',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeccionChat() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¿Quieres hablar conmigo?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Desahógate, estoy aquí para escucharte y ayudarte en lo que necesites.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatBienestarScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text(
                    'Abrir Chat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    const url = 'tel:911';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo realizar la llamada'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.emergency_rounded),
                  label: const Text(
                    'Botón de Emergencia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Página 3: Contactos de emergencia
  Widget _buildPaginaContactos() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Contactos de Emergencia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<BienestarProvider>(
            builder: (context, bienestarProvider, child) {
              final contactos = bienestarProvider.contactosEmergencia;
              
              if (contactos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay contactos de emergencia',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: contactos.map((contacto) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildContactoCard(context, contacto),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactosEmergenciaScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Ver Todos / Añadir Contacto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContactoCard(BuildContext context, ContactoEmergencia contacto) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contacto.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (contacto.esNacional)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Nacional',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (contacto.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        contacto.descripcion!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      contacto.telefono,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: Colors.green),
                onPressed: () async {
                  final url = 'tel:${contacto.telefono}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
