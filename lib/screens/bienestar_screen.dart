import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/bienestar_provider.dart';
import '../models/bienestar.dart';
import '../utils/profile_helper.dart';
import '../config/app_colors.dart';
import 'dart:ui';
import 'cuestionario_screen.dart';
import 'chat_bienestar_screen.dart';

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
        builder: (context, setState) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
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
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
          children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.bienestarPrimary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.psychology_rounded, color: AppColors.bienestarPrimary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
              child: Text(
                'Cuestionarios Mensuales',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                          onPressed: () => Navigator.pop(dialogContext),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
            ),
          ],
        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para un mejor seguimiento de tu bienestar, te recomendamos completar los cuestionarios mensualmente.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
                        const SizedBox(height: 12),
            ...TipoCuestionario.values.map((tipo) {
              final estaCompletado = completados[tipo] ?? false;
                final estaSeleccionado = cuestionarioSeleccionado == tipo;
              return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
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
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                                  color: estaSeleccionado ? AppColors.bienestarPrimary.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                                    color: estaSeleccionado ? AppColors.bienestarPrimary : Colors.transparent,
                                    width: 1,
                        ),
                      ),
                child: Row(
                  children: [
                    Icon(
                            estaCompletado 
                                ? Icons.check_circle 
                                : (estaSeleccionado ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                            color: estaCompletado 
                                          ? AppColors.bienestarPrimary 
                                          : (estaSeleccionado ? AppColors.bienestarPrimary : Colors.grey),
                                      size: 16,
                    ),
                                    const SizedBox(width: 8),
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
                                          fontSize: 11,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.bienestarPrimary.withOpacity(0.4),
                                    AppColors.bienestarSecondary.withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.bienestarPrimary.withOpacity(0.4),
                                  width: 1,
              ),
          ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
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
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Ir a Cuestionarios',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
            ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.pop(dialogContext),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Cerrar',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 16),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bienestarPrimary, AppColors.bienestarSecondary],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bienestarPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Bienestar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Primera fila: Salud Mental y Emociones
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  'Salud Mental',
                  Icons.psychology_rounded,
                  0,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildTabButton(
                  'Emociones',
                  Icons.mood_rounded,
                  1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Segunda fila: Emergencia (botón largo rojo)
          _buildEmergenciaButton(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final isSelected = _tabController.index == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.bienestarPrimary, AppColors.bienestarSecondary],
                    )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.bienestarPrimary.withOpacity(0.4)
                    : Colors.white.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.bienestarPrimary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergenciaButton() {
    final isSelected = _tabController.index == 2;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(2);
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Colors.red, Color(0xFFC62828)],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.red.withOpacity(0.2),
                      ],
                ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.red.withOpacity(0.5)
                    : Colors.red.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Emergencia',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionSaludMental(),
          const SizedBox(height: 12),
          _buildSeccionCuestionarios(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSeccionSaludMental() {
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
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bienestarPrimary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.bienestarPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Información sobre Salud Mental',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Tu bienestar mental es importante. Aquí encontrarás recursos para cuidar de tu salud emocional y psicológica.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                '🧠 Depresión',
                'La depresión es un trastorno del estado de ánimo que causa sentimientos persistentes de tristeza y pérdida de interés.',
              ),
              const SizedBox(height: 6),
              _buildInfoCard(
                '💭 Ansiedad',
                'La ansiedad es una respuesta natural al estrés, pero cuando es excesiva puede afectar tu vida diaria.',
              ),
              const SizedBox(height: 6),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
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
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
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
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Cuestionarios de Salud Mental',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
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
        const SizedBox(height: 6),
        _buildCuestionarioCard(
          context,
          TipoCuestionario.gad7,
          'GAD-7',
          'Escala de Ansiedad Generalizada',
          '💭',
          Colors.orange,
        ),
        const SizedBox(height: 6),
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
      borderRadius: BorderRadius.circular(10),
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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
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
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            descripcion,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white70,
                      size: 14,
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeccionEmocionHoy(),
          const SizedBox(height: 14),
          _buildSeccionChat(),
          const SizedBox(height: 16),
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
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo te sientes hoy?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Emoji grande central
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: getColor(valor).withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: getColor(valor).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          getEmoji(valor),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Texto descriptivo
                  Center(
                    child: Text(
                      getTexto(valor),
                      style: TextStyle(
                        color: getColor(valor),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: getColor(valor),
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: getColor(valor),
                      overlayColor: getColor(valor).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      trackHeight: 3,
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
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '¿Quieres hablar conmigo?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Desahógate, estoy aquí para escucharte y ayudarte en lo que necesites.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bienestarPrimary.withOpacity(0.3),
                          AppColors.bienestarSecondary.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.bienestarPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatBienestarScreen(),
                      ),
                    );
                  },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.bienestarPrimary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.chat_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                    'Abrir Chat',
                    style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                    ),
                  ),
                            ],
                    ),
                  ),
                ),
              ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
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
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.emergency_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Emergencia',
                    style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                    ),
                  ),
                            ],
                          ),
                        ),
                      ),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Contactos de Emergencia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
                        size: 48,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No hay contactos de emergencia',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: contactos.map((contacto) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildContactoCard(context, contacto),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bienestarPrimary.withOpacity(0.3),
                      AppColors.bienestarSecondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.bienestarPrimary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _mostrarDialogoAgregarContacto(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.bienestarPrimary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Añadir Contacto',
                style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                ),
              ),
                        ],
                ),
              ),
            ),
          ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildContactoCard(BuildContext context, ContactoEmergencia contacto) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bienestarPrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.bienestarPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contacto.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (contacto.esNacional)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Nacional',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (contacto.descripcion != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        contacto.descripcion!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      contacto.telefono,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              IconButton(
                    icon: const Icon(Icons.phone_rounded, color: AppColors.bienestarPrimary, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                onPressed: () async {
                  final url = 'tel:${contacto.telefono}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
                    tooltip: 'Llamar',
                  ),
                  if (!contacto.esNacional)
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final bienestarProvider = Provider.of<BienestarProvider>(context, listen: false);
                        final confirmacion = await showDialog<bool>(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                                      color: Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.warning_rounded,
                                            color: Colors.red,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Eliminar Contacto',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '¿Estás seguro de que deseas eliminar a ${contacto.nombre}?',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.white.withOpacity(0.2),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => Navigator.pop(context, false),
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 12),
                                                          child: Center(
                                                            child: Text(
                                                              'Cancelar',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.red.withOpacity(0.4),
                                                          Colors.red.withOpacity(0.3),
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.red.withOpacity(0.4),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => Navigator.pop(context, true),
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 12),
                                                          child: Center(
                                                            child: Text(
                                                              'Eliminar',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        if (confirmacion == true && mounted) {
                          final eliminado = await bienestarProvider.eliminarContactoEmergencia(contacto.id);
                          if (eliminado && mounted) {
                            await bienestarProvider.cargarContactosEmergencia();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contacto eliminado'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'Eliminar',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoAgregarContacto(BuildContext context) async {
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();
    final descripcionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final bienestarProvider = Provider.of<BienestarProvider>(context, listen: false);

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            bool isAdding = false;

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.bienestarPrimary.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.contact_page_outlined,
                                    color: AppColors.bienestarPrimary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Agregar Contacto',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildDialogTextField(
                              controller: nombreController,
                              label: 'Nombre',
                              hint: 'Ingresa el nombre',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa un nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildDialogTextField(
                              controller: telefonoController,
                              label: 'Teléfono',
                              hint: 'Ingresa el teléfono',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa un teléfono';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildDialogTextField(
                              controller: descripcionController,
                              label: 'Descripción (opcional)',
                              hint: 'Descripción del contacto',
                              icon: Icons.description_outlined,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                                        onTap: () {
                                                          Navigator.pop(dialogContext);
                                                        },
                                            borderRadius: BorderRadius.circular(12),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              child: Center(
                                                child: Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.bienestarPrimary.withOpacity(0.4),
                                              AppColors.bienestarSecondary.withOpacity(0.3),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.bienestarPrimary.withOpacity(0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () async {
                                              if (formKey.currentState!.validate()) {
                                                setDialogState(() {
                                                  isAdding = true;
                                                });

                                                final agregado = await bienestarProvider.agregarContactoEmergencia(
                                                  nombre: nombreController.text.trim(),
                                                  telefono: telefonoController.text.trim(),
                                                  descripcion: descripcionController.text.trim().isEmpty
                                                      ? null
                                                      : descripcionController.text.trim(),
                                                );

                                                setDialogState(() {
                                                  isAdding = false;
                                                });

                                                if (agregado) {
                                                  Navigator.pop(dialogContext, true);
                                                } else {
                                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                                    SnackBar(
                                                      content: Text(bienestarProvider.error ?? 'Error al agregar contacto'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Center(
                                                child: isAdding
                                                    ? const SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Agregar',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          },
        );
      },
    );
    
    // Disponer controllers después de que el diálogo se cierre
    nombreController.dispose();
    telefonoController.dispose();
    descripcionController.dispose();
    
    // Si el contacto fue agregado exitosamente, recargar y mostrar mensaje
    if (resultado == true && mounted) {
      await bienestarProvider.cargarContactosEmergencia();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacto agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                validator: validator,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(icon, color: AppColors.bienestarPrimary, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
