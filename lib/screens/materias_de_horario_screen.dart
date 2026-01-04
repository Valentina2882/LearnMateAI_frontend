import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../models/materia.dart';
import '../services/materias_service.dart';
import '../services/horarios_materias_service.dart';
import '../config/app_colors.dart';
import 'dart:ui';

class MateriasDeHorarioScreen extends StatefulWidget {
  final Horario horario;

  const MateriasDeHorarioScreen({super.key, required this.horario});

  @override
  State<MateriasDeHorarioScreen> createState() => _MateriasDeHorarioScreenState();
}

class _MateriasDeHorarioScreenState extends State<MateriasDeHorarioScreen> {
  static const List<String> dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  static const List<String> horas = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00',
    '20:00', '21:00', '22:00',
  ];

  final ScrollController _scrollController = ScrollController();

  final MateriasService _materiasService = MateriasService();
  final HorariosMaterialsService _horariosMateriasService = HorariosMaterialsService();

  List<Map<String, dynamic>> _materiasHorario = [];
  bool _isLoading = false;
  
  // Colores predefinidos
  static const List<Color> _colores = [
    Color(0xFF2196F3), // Azul
    Color(0xFF4CAF50), // Verde
    Color(0xFFFF9800), // Naranja
    Color(0xFF9C27B0), // Morado
    Color(0xFFE91E63), // Rosa
    Color(0xFF00BCD4), // Cyan
    Color(0xFFF44336), // Rojo
    Color(0xFFFFEB3B), // Amarillo
    Color(0xFF795548), // Marrón
    Color(0xFF607D8B), // Azul gris
  ];
  
  String _selectedColor = '#2196F3';

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Función auxiliar para obtener datos de materia desde materiaHorario
  Map<String, dynamic> _getMateriaData(Map<String, dynamic> materiaHorario) {
    // Supabase puede devolver 'materias' (plural) o 'materia' (singular) en el join
    dynamic materiaDataRaw = materiaHorario['materias'] ?? materiaHorario['materia'];
    Map<String, dynamic> materiaData = {};
    
    if (materiaDataRaw != null) {
      if (materiaDataRaw is Map<String, dynamic>) {
        materiaData = materiaDataRaw;
      } else if (materiaDataRaw is Map) {
        materiaData = Map<String, dynamic>.from(materiaDataRaw);
      }
    }
    
    return materiaData;
  }

  Future<void> _loadMaterias() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final materias = await _horariosMateriasService.getMateriasByHorario(widget.horario.id!);
      print('=== MATERIAS CARGADAS ===');
      print('Total materias: ${materias.length}');
      for (var materia in materias) {
        print('Materia completa: $materia');
        final materiaData = _getMateriaData(materia);
        print('Materia data extraída: $materiaData');
        print('Nombre: ${materiaData['nombre']}');
      }
      print('========================');
      
      if (!mounted) return;
      
      setState(() {
        _materiasHorario = materias;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar materias: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showSnackBar('Error al cargar las materias: $e');
      }
    }
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.horarioPrimary.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildWeekHeader(),
                            Divider(
                              height: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTimeColumn(),
                                    VerticalDivider(
                                      width: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    Expanded(
                                      child: _buildWeekGrid(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.horarioPrimary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showMainMenu();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
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
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.horarioPrimary,
                  AppColors.horarioSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.horarioPrimary.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.horario.nombrehor ?? 'Horario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Gestión de materias',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
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

  Widget _buildWeekHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 56), // Espacio para columna de horas
          ...dias.asMap().entries.map((entry) {
            final index = entry.key;
            final dia = entry.value;
            final isToday = _isToday(index);
            
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: isToday
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.horarioPrimary.withOpacity(0.3),
                            AppColors.horarioSecondary.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                child: Text(
                  dia,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.white : Colors.white.withOpacity(0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Container(
      width: 56,
      child: Column(
        children: horas.map((hora) {
          return SizedBox(
            height: 80,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 0),
                child: Text(
                  hora,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekGrid() {
    return Column(
      children: List.generate(horas.length, (hourIndex) {
        return Row(
          children: dias.asMap().entries.map((entry) {
            final dayIndex = entry.key;
            return Expanded(
              child: _buildGridCell(dayIndex, hourIndex),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildGridCell(int dayIndex, int hourIndex) {
    final dia = dias[dayIndex];
    final hora = horas[hourIndex];
    
    // Debug: imprimir todas las materias
    if (dayIndex == 0 && hourIndex == 0) {
      print('=== DEBUG GRID ===');
      print('Total materias en horario: ${_materiasHorario.length}');
      for (var m in _materiasHorario) {
        print('Materia: dia=${m['dia']}, hora_inicio=${m['hora_inicio']}, materia=${m['materia']}');
      }
    }
    
    // Buscar materias que coincidan con este día y hora
    final materiasEnCelda = _materiasHorario.where((materiaHorario) {
      final materiaDia = materiaHorario['dia'] as String?;
      final horaInicio = materiaHorario['hora_inicio'] as String?;
      final horaFin = materiaHorario['hora_fin'] as String?;
      
      // Convertir día completo a abreviación
      String diaAbreviado = '';
      if (materiaDia != null) {
        switch (materiaDia) {
          case 'Lunes':
            diaAbreviado = 'Lun';
            break;
          case 'Martes':
            diaAbreviado = 'Mar';
            break;
          case 'Miércoles':
            diaAbreviado = 'Mié';
            break;
          case 'Jueves':
            diaAbreviado = 'Jue';
            break;
          case 'Viernes':
            diaAbreviado = 'Vie';
            break;
          case 'Sábado':
            diaAbreviado = 'Sáb';
            break;
        }
      }
      
      // Si el día no coincide, no hay match
      if (diaAbreviado != dia) return false;
      
      // Comparar solo HH:MM (ignorar segundos)
      if (horaInicio != null && horaFin != null) {
        final horaInicioSinSegundos = horaInicio.substring(0, 5); // "07:00:00" -> "07:00"
        final horaFinSinSegundos = horaFin.substring(0, 5); // "10:00:00" -> "10:00"
        
        // Verificar si la hora actual está dentro del rango [horaInicio, horaFin)
        // La clase aparece desde horaInicio hasta (horaFin - 1)
        // Ejemplo: clase de 08:00 a 10:00 aparece en 08:00 y 09:00 (NO en 10:00)
        final matches = hora.compareTo(horaInicioSinSegundos) >= 0 && 
                       hora.compareTo(horaFinSinSegundos) < 0;
        
        return matches;
      }
      
      return false;
    }).toList();
    
    return GestureDetector(
      onTap: () => _onCellTap(dayIndex, hourIndex),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: materiasEnCelda.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: materiasEnCelda.map((materiaHorario) {
                    final materiaData = _getMateriaData(materiaHorario);
                    final nombre = materiaData['nombre']?.toString() ?? 'Materia';
                    final colorHex = materiaData['color']?.toString() ?? '#2196F3';
                    final aula = materiaHorario['aula'] as String?;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (aula != null && aula.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              aula,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            : null,
      ),
    );
  }

  bool _isToday(int dayIndex) {
    final today = DateTime.now().weekday - 1;
    return dayIndex == today && today < 6;
  }

  String? _validarConflictoHorario(String diaAbreviado, String horaInicio, String horaFin, {String? materiaIdToIgnore, String? materiaIdIgnoring}) {
    // Convertir día abreviado a nombre completo
    String diaCompleto = '';
    switch (diaAbreviado) {
      case 'Lun':
        diaCompleto = 'Lunes';
        break;
      case 'Mar':
        diaCompleto = 'Martes';
        break;
      case 'Mié':
        diaCompleto = 'Miércoles';
        break;
      case 'Jue':
        diaCompleto = 'Jueves';
        break;
      case 'Vie':
        diaCompleto = 'Viernes';
        break;
      case 'Sáb':
        diaCompleto = 'Sábado';
        break;
    }

    // Buscar materias que se solapen con el horario nuevo
    for (var materiaHorario in _materiasHorario) {
      final materiaHorarioId = materiaHorario['id'] as String?;
      final materiaDia = materiaHorario['dia'] as String?;
      final materiaHoraInicio = materiaHorario['hora_inicio'] as String?;
      final materiaHoraFin = materiaHorario['hora_fin'] as String?;
      final materiaData = _getMateriaData(materiaHorario);
      final materiaId = materiaData['id'] as String?;
      
      // Ignorar la materia si es la misma que estamos verificando (para edición)
      if (materiaIdToIgnore != null && materiaId == materiaIdToIgnore) {
        continue;
      }
      
      // Si es la misma materia que queremos agregar, permitirla en diferentes horarios
      if (materiaIdIgnoring != null && materiaId == materiaIdIgnoring) {
        continue;
      }
      
      // Si no es el mismo día, no hay conflicto
      if (materiaDia != diaCompleto) continue;
      
      if (materiaHoraInicio != null && materiaHoraFin != null) {
        final materiaInicioSinSegundos = materiaHoraInicio.substring(0, 5);
        final materiaFinSinSegundos = materiaHoraFin.substring(0, 5);
        
        // Verificar si hay solapamiento
        // Hay conflicto si:
        // 1. El nuevo inicio está entre el inicio y fin de la materia existente
        // 2. El nuevo fin está entre el inicio y fin de la materia existente
        // 3. La nueva materia envuelve completamente a la existente
        final nuevoInicioEnRango = horaInicio.compareTo(materiaInicioSinSegundos) >= 0 && 
                                    horaInicio.compareTo(materiaFinSinSegundos) < 0;
        final nuevoFinEnRango = horaFin.compareTo(materiaInicioSinSegundos) > 0 && 
                                horaFin.compareTo(materiaFinSinSegundos) <= 0;
        final envuelveExistente = horaInicio.compareTo(materiaInicioSinSegundos) <= 0 && 
                                   horaFin.compareTo(materiaFinSinSegundos) >= 0;
        
        if (nuevoInicioEnRango || nuevoFinEnRango || envuelveExistente) {
          final nombreMateria = materiaData['nombre'] as String? ?? 'Materia';
          return nombreMateria;
        }
      }
    }
    
    return null; // No hay conflicto
  }

  void _showMainMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 2.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Opciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Botón para agregar materia
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.horarioPrimary.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _showSelectTimeModal();
                              },
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Agregar Materia',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
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
                    const SizedBox(height: 10),
                    // Botón para gestionar materias
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _showManageMateriasModal();
                              },
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Gestionar Materias',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
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
                    const SizedBox(height: 10),
                    // Botón cancelar
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSelectTimeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 2.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Seleccionar Horario',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Toca una celda del horario para agregar una materia en ese horario.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
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
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Text(
                                    'Cerrar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showManageMateriasModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.settings, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gestionar Materias',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                '${_materiasHorario.length} materia${_materiasHorario.length != 1 ? 's' : ''} en este horario',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildMateriasListForManagement(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMateriasListForManagement() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_materiasHorario.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay materias en este horario',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar por materia (materia_id) y sus diferentes horarios
    final Map<String, List<Map<String, dynamic>>> materiasAgrupadas = {};
    
    for (var materiaHorario in _materiasHorario) {
      final materiaData = _getMateriaData(materiaHorario);
      final materiaId = materiaData['id'] as String?;
      
      if (materiaId != null) {
        if (!materiasAgrupadas.containsKey(materiaId)) {
          materiasAgrupadas[materiaId] = [];
        }
        materiasAgrupadas[materiaId]!.add(materiaHorario);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: materiasAgrupadas.length,
      itemBuilder: (context, index) {
        final materiaId = materiasAgrupadas.keys.elementAt(index);
        final horarios = materiasAgrupadas[materiaId]!;
        
        // Usar el primer horario para obtener los datos de la materia
        final materiaHorario = horarios.first;
        final materiaData = _getMateriaData(materiaHorario);
        final nombre = materiaData['nombre']?.toString() ?? 'Sin nombre';
        final colorHex = materiaData['color']?.toString() ?? '#2196F3';
        final color = Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
        
        // Construir texto con todos los horarios
        final horariosTexto = horarios.map((h) {
          final dia = h['dia'] as String? ?? '';
          final horaInicio = h['hora_inicio'] as String? ?? '';
          final horaFin = h['hora_fin'] as String? ?? '';
          return '$dia, $horaInicio - $horaFin';
        }).join('\n');
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.school, color: color, size: 22),
                ),
                title: Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  horariosTexto,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  color: const Color(0xFF1A2634),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  elevation: 8,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppColors.horarioPrimary, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Editar',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.redAccent, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      // Guardar el contexto del modal de gestión
                      final modalContext = context;
                      
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar materia'),
                          content: Text('¿Estás seguro de que deseas eliminar "$nombre" de este horario?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        // Mostrar loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (loadingContext) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        
                        try {
                          // Guardar el materia_id antes de eliminar los horarios
                          final materiaData = horarios.isNotEmpty 
                              ? _getMateriaData(horarios[0])
                              : _getMateriaData(materiaHorario);
                          
                          final materiaId = materiaData['id'] as String?;
                          if (materiaId == null) {
                            throw Exception('No se pudo obtener el ID de la materia');
                          }
                          
                          // Eliminar todos los horarios de esta materia
                          for (var horario in horarios) {
                            final materiaHorarioId = horario['id'] as String;
                            await _horariosMateriasService.deleteMateriaDeHorario(
                              widget.horario.id!,
                              materiaHorarioId,
                            );
                          }
                          
                          // Eliminar la materia de la tabla materias
                          await _materiasService.deleteMateria(materiaId);
                          
                          // Cerrar loading y el modal de gestión
                          if (mounted) {
                            Navigator.pop(context); // Cerrar loading
                            Navigator.pop(context); // Cerrar modal de gestión
                            _showSnackBar('Materia eliminada');
                            await _loadMaterias();
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context); // Cerrar loading
                            _showSnackBar('Error al eliminar: $e');
                          }
                        }
                      }
                    } else if (value == 'edit') {
                      if (mounted) {
                        Navigator.pop(context); // Cerrar modal de gestión
                        _showEditMateriaModal(materiaHorario, horarios);
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  void _showEditMateriaModal(Map<String, dynamic> materiaHorario, List<Map<String, dynamic>> horarios) {
    // Obtener datos de la materia
    final materiaData = horarios.isNotEmpty 
        ? _getMateriaData(horarios[0])
        : _getMateriaData(materiaHorario);
    
    print('=== EDIT MODAL DATA ===');
    print('Materia data: $materiaData');
    print('Keys: ${materiaData.keys.toList()}');
    print('Nombre: ${materiaData['nombre']}');
    print('=======================');
    
    final nombre = materiaData['nombre']?.toString() ?? '';
    final codigo = materiaData['codigo']?.toString() ?? '';
    final creditos = (materiaData['creditos'] is int) 
        ? materiaData['creditos'] as int 
        : (materiaData['creditos']?.toInt() ?? 3);
    final profesor = materiaData['profesor']?.toString() ?? '';
    final colorHex = materiaData['color']?.toString() ?? '#2196F3';
    
    final nombreController = TextEditingController(text: nombre);
    final codigoController = TextEditingController(text: codigo);
    final creditosController = TextEditingController(text: creditos.toString());
    final profesorController = TextEditingController(text: profesor);
    String selectedColor = colorHex;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.horarioPrimary.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Editar Materia',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Modifica la información de la materia',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                    onPressed: () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            _buildTextField(
                              controller: nombreController,
                              label: 'Nombre de la materia',
                              hint: 'Ej: Cálculo I',
                              icon: Icons.book,
                              required: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: codigoController,
                              label: 'Código',
                              hint: 'Ej: MAT101',
                              icon: Icons.tag,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: creditosController,
                              label: 'Créditos',
                              hint: 'Ej: 3',
                              icon: Icons.star,
                              required: true,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: profesorController,
                              label: 'Profesor',
                              hint: 'Ej: Dr. Juan Pérez',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 12),
                            _buildColorPickerField(
                              selectedColor,
                              (color) {
                                setModalState(() {
                                  selectedColor = color;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Botones
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
                                            onTap: () => Navigator.pop(context),
                                            borderRadius: BorderRadius.circular(12),
                                            splashColor: Colors.white.withOpacity(0.1),
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
                                      gradient: const LinearGradient(
                                        colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.horarioPrimary.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          if (nombreController.text.isEmpty) {
                                            _showSnackBar('El nombre de la materia es requerido');
                                            return;
                                          }
                                          
                                          Navigator.pop(context);
                                          
                                          // Mostrar indicador de carga
                                          BuildContext? loadingContext;
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (dialogContext) {
                                              loadingContext = dialogContext;
                                              return const Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                          );
                                          
                                          try {
                                            // Obtener materiaId del primer horario de la lista
                                            final materiaDataForUpdate = horarios.isNotEmpty 
                                                ? _getMateriaData(horarios[0])
                                                : _getMateriaData(materiaHorario);
                                            
                                            final materiaId = materiaDataForUpdate['id'] as String?;
                                            if (materiaId == null) {
                                              throw Exception('No se pudo obtener el ID de la materia');
                                            }
                                            
                                            final creditos = int.tryParse(creditosController.text) ?? 3;
                                            
                                            // Actualizar la materia
                                            await _materiasService.updateMateria(
                                              materiaId,
                                              nombre: nombreController.text.trim(),
                                              codigo: codigoController.text.trim(),
                                              creditos: creditos,
                                              profesor: profesorController.text.trim().isNotEmpty 
                                                  ? profesorController.text.trim() 
                                                  : null,
                                              color: selectedColor,
                                            );
                                            
                                            if (mounted && loadingContext != null) {
                                              Navigator.pop(loadingContext!);
                                              _showSnackBar('Materia actualizada exitosamente');
                                              await _loadMaterias();
                                            }
                                          } catch (e) {
                                            print('Error al actualizar materia: $e');
                                            if (mounted && loadingContext != null) {
                                              Navigator.pop(loadingContext!);
                                              _showSnackBar('Error al actualizar: $e');
                                            }
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        splashColor: Colors.white.withOpacity(0.2),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Guardar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
          },
        );
      },
    );
  }

  void _showMateriaDetails(Map<String, dynamic> materiaHorario) {
    // Obtener datos de la materia usando la función auxiliar
    final materiaData = _getMateriaData(materiaHorario);
    
    print('=== MATERIA HORARIO DATA ===');
    print('Keys: ${materiaHorario.keys.toList()}');
    print('Materia data: $materiaData');
    print('Materia keys: ${materiaData.keys.toList()}');
    print('Nombre: ${materiaData['nombre']}');
    print('===========================');
    
    final nombre = materiaData['nombre']?.toString() ?? 'Sin nombre';
    final codigo = materiaData['codigo']?.toString() ?? '';
    final creditos = (materiaData['creditos'] is int) 
        ? materiaData['creditos'] as int
        : (materiaData['creditos']?.toInt() ?? 0);
    final profesor = materiaData['profesor']?.toString() ?? '';
    final colorHex = materiaData['color']?.toString() ?? '#2196F3';
    final dia = materiaHorario['dia']?.toString() ?? '';
    final horaInicio = materiaHorario['hora_inicio']?.toString() ?? '';
    final horaFin = materiaHorario['hora_fin']?.toString() ?? '';
    final aula = materiaHorario['aula']?.toString() ?? '';
    final notas = materiaHorario['notas']?.toString() ?? '';
    
    // Guardar el contexto del widget antes de abrir el modal
    final widgetContext = context;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final color = Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
        
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A2634).withOpacity(0.95),
                    const Color(0xFF0F1923).withOpacity(0.98),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.8), color],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.school, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (codigo.isNotEmpty)
                                Text(
                                  codigo,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
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
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                onPressed: () => Navigator.pop(modalContext),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Horario
                            _buildDetailRow(Icons.access_time, 'Horario', '$dia, $horaInicio - $horaFin'),
                            const SizedBox(height: 12),
                            // Créditos
                            _buildDetailRow(Icons.star, 'Créditos', '$creditos créditos'),
                            const SizedBox(height: 12),
                            // Profesor
                            if (profesor.isNotEmpty) ...[
                              _buildDetailRow(Icons.person, 'Profesor', profesor),
                              const SizedBox(height: 12),
                            ],
                            // Aula
                            if (aula.isNotEmpty) ...[
                              _buildDetailRow(Icons.meeting_room, 'Aula', aula),
                              const SizedBox(height: 12),
                            ],
                            // Notas
                            if (notas.isNotEmpty) ...[
                              _buildDetailRow(Icons.note, 'Notas', notas),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Botones de acción
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
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
                                        // Cerrar el modal de detalles
                                        Navigator.pop(modalContext);
                                        
                                        // Obtener todos los horarios de esta materia
                                        final materiaData = _getMateriaData(materiaHorario);
                                        final materiaId = materiaData['id'] as String?;
                                        
                                        if (materiaId != null && mounted) {
                                          // Filtrar todos los horarios de esta materia
                                          final horariosDeMateria = _materiasHorario.where((mh) {
                                            final mData = _getMateriaData(mh);
                                            final mId = mData['id'] as String?;
                                            return mId == materiaId;
                                          }).toList();
                                          
                                          if (horariosDeMateria.isNotEmpty) {
                                            _showEditMateriaModal(materiaHorario, horariosDeMateria);
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      splashColor: Colors.white.withOpacity(0.1),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit, color: Colors.white, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
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
                                        Colors.red.withOpacity(0.8),
                                        Colors.red[700]!.withOpacity(0.9),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        // Cerrar el modal de detalles primero
                                        Navigator.pop(modalContext);
                                        
                                        // Esperar un frame para que el modal se cierre completamente
                                        await Future.delayed(const Duration(milliseconds: 200));
                                        
                                        // Verificar que el widget aún esté montado
                                        if (!mounted) return;
                                        
                                        // Mostrar confirmación usando el contexto del widget
                                        final confirm = await showDialog<bool>(
                                          context: widgetContext,
                                          builder: (dialogContext) => AlertDialog(
                                            backgroundColor: const Color(0xFF1A2634),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            title: const Text(
                                              'Eliminar materia',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            content: Text(
                                              '¿Estás seguro de que deseas eliminar "$nombre" de este horario?',
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(dialogContext, false),
                                                child: const Text(
                                                  'Cancelar',
                                                  style: TextStyle(color: Colors.white70),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(dialogContext, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirm == true && mounted) {
                                          // Mostrar loading
                                          showDialog(
                                            context: widgetContext,
                                            barrierDismissible: false,
                                            builder: (loadingContext) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                          
                                          try {
                                            final materiaHorarioId = materiaHorario['id'] as String;
                                            await _horariosMateriasService.deleteMateriaDeHorario(
                                              widget.horario.id!,
                                              materiaHorarioId,
                                            );
                                            
                                            if (mounted) {
                                              Navigator.pop(widgetContext); // Cerrar loading
                                              _showSnackBar('Materia eliminada del horario');
                                              await _loadMaterias();
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              Navigator.pop(widgetContext); // Cerrar loading
                                              _showSnackBar('Error al eliminar: $e');
                                            }
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      splashColor: Colors.white.withOpacity(0.2),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete, color: Colors.white, size: 16),
                                            SizedBox(width: 6),
                                            Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value, {bool isDark = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isDark ? Colors.white.withOpacity(0.8) : AppColors.horarioPrimary,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onCellTap(int dayIndex, int hourIndex) {
    final dia = dias[dayIndex];
    final hora = horas[hourIndex];
    
    // Buscar materias en esta celda
    final materiasEnCelda = _materiasHorario.where((materiaHorario) {
      final materiaDia = materiaHorario['dia'] as String?;
      final horaInicio = materiaHorario['hora_inicio'] as String?;
      final horaFin = materiaHorario['hora_fin'] as String?;
      
      // Convertir día completo a abreviación
      String diaAbreviado = '';
      if (materiaDia != null) {
        switch (materiaDia) {
          case 'Lunes':
            diaAbreviado = 'Lun';
            break;
          case 'Martes':
            diaAbreviado = 'Mar';
            break;
          case 'Miércoles':
            diaAbreviado = 'Mié';
            break;
          case 'Jueves':
            diaAbreviado = 'Jue';
            break;
          case 'Viernes':
            diaAbreviado = 'Vie';
            break;
          case 'Sábado':
            diaAbreviado = 'Sáb';
            break;
        }
      }
      
      // Si el día no coincide, no hay match
      if (diaAbreviado != dia) return false;
      
      // Comparar solo HH:MM (ignorar segundos)
      if (horaInicio != null && horaFin != null) {
        final horaInicioSinSegundos = horaInicio.substring(0, 5);
        final horaFinSinSegundos = horaFin.substring(0, 5);
        
        // Verificar si la hora actual está dentro del rango
        return hora.compareTo(horaInicioSinSegundos) >= 0 && 
               hora.compareTo(horaFinSinSegundos) < 0;
      }
      
      return false;
    }).toList();
    
    if (materiasEnCelda.isNotEmpty) {
      // Si hay una materia, mostrar sus detalles
      _showMateriaDetails(materiasEnCelda.first);
    } else {
      // Si no hay materia, mostrar opciones
      _showCellOptions(dia, hora);
    }
  }
  
  void _showCellOptions(String dia, String hora) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 2.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Agregar Clase',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dia, $hora',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón para agregar nueva materia
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.horarioPrimary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _showAddMateriaModal(dia, hora);
                              },
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Nueva Materia',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
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
                    const SizedBox(height: 10),
                    // Botón para agregar materia existente
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _showAddExistingMateriaModal(dia, hora);
                              },
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.list_alt,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Materia Existente',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
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
                    const SizedBox(height: 10),
                    // Botón cancelar
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showAddExistingMateriaModal(String dia, String hora) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.horarioPrimary.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.list_alt, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Materias Existentes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildExistingMateriasList(dia, hora),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showHoraFinDialog(Materia materia, String dia, String hora) {
    final horaFinController = TextEditingController();
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
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
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.horarioPrimary.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.horarioPrimary.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Seleccionar Hora Fin',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        materia.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Horario: $dia, $hora',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTimePickerField(
                        controller: horaFinController,
                        label: 'Hora fin',
                        hint: 'Seleccionar hora',
                        icon: Icons.access_time,
                        required: true,
                        isDialog: true,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: dialogContext,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.horarioPrimary,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF1A2634),
                                    onSurface: Colors.white,
                                    brightness: Brightness.dark,
                                  ),
                                  dialogBackgroundColor: const Color(0xFF1A2634),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.horarioPrimary,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            horaFinController.text = 
                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.horarioPrimary.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      if (horaFinController.text.isEmpty) {
                                        _showSnackBar('Por favor selecciona una hora fin');
                                        return;
                                      }
                                      
                                      // Validar que la hora fin sea mayor que la hora inicio
                                      if (horaFinController.text.compareTo(hora) <= 0) {
                                        _showSnackBar('La hora fin debe ser posterior a la hora inicio');
                                        return;
                                      }
                                      
                                      Navigator.pop(dialogContext); // Cerrar dialog de hora
                                      Navigator.pop(context); // Cerrar modal de materias
                                      
                                      // Convertir día abreviado a completo
                                      String diaCompleto = '';
                                      switch (dia) {
                                        case 'Lun':
                                          diaCompleto = 'Lunes';
                                          break;
                                        case 'Mar':
                                          diaCompleto = 'Martes';
                                          break;
                                        case 'Mié':
                                          diaCompleto = 'Miércoles';
                                          break;
                                        case 'Jue':
                                          diaCompleto = 'Jueves';
                                          break;
                                        case 'Vie':
                                          diaCompleto = 'Viernes';
                                          break;
                                        case 'Sáb':
                                          diaCompleto = 'Sábado';
                                          break;
                                      }
                                      
                                      // Validar conflicto (permitir la misma materia en horarios/días diferentes)
                                      final conflicto = _validarConflictoHorario(
                                        dia, 
                                        hora, 
                                        horaFinController.text,
                                        materiaIdIgnoring: materia.id, // Permitir la misma materia en diferentes horarios
                                      );
                                      if (conflicto != null) {
                                        _showSnackBar('Conflicto de horario: Ya existe otra materia en este horario');
                                        return;
                                      }
                                      
                                      // Mostrar indicador de carga
                                      BuildContext? loadingContext;
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (loadingDialogContext) {
                                          loadingContext = loadingDialogContext;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      );
                                      
                                      try {
                                        // Crear la relación en horarios_materias
                                        await _horariosMateriasService.createMateriaEnHorario(
                                          horarioId: widget.horario.id!,
                                          materiaId: materia.id,
                                          dia: diaCompleto,
                                          horaInicio: hora,
                                          horaFin: horaFinController.text,
                                          aula: null,
                                          notas: null,
                                        );
                                        
                                        if (mounted && loadingContext != null) {
                                          Navigator.pop(loadingContext!);
                                          _showSnackBar('Materia agregada: ${materia.nombre}');
                                          await _loadMaterias();
                                        }
                                      } catch (e) {
                                        if (mounted && loadingContext != null) {
                                          Navigator.pop(loadingContext!);
                                          _showSnackBar('Error al agregar materia: $e');
                                        }
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    splashColor: Colors.white.withOpacity(0.2),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      child: Text(
                                        'Agregar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
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
        );
      },
    );
  }
  
  Widget _buildExistingMateriasList(String dia, String hora) {
    return FutureBuilder<List<Materia>>(
      future: _materiasService.getMaterias(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.horarioPrimary,
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error al cargar materias',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final materias = snapshot.data ?? [];
        
        if (materias.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No hay materias existentes',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea una nueva materia primero',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: materias.length,
          itemBuilder: (context, index) {
            final materia = materias[index];
            final colorHex = materia.color ?? '#2196F3';
            final color = Color(int.parse(colorHex.substring(1, 7), radix: 16) + 0xFF000000);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showHoraFinDialog(materia, dia, hora);
                        },
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.white.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withOpacity(0.8),
                                      color,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      materia.nombre,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      materia.codigo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 14,
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
            );
          },
        );
      },
    );
  }




  void _showAddMateriaModal(String dia, String hora) {
    final nombreController = TextEditingController();
    final codigoController = TextEditingController();
    final creditosController = TextEditingController(text: '3');
    final profesorController = TextEditingController();
    final aulaController = TextEditingController();
    final horaFinController = TextEditingController();
    final notasController = TextEditingController();
    String selectedColor = '#2196F3'; // Mover fuera del builder
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.horarioPrimary.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.school, color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Agregar Materia',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                Text(
                                  '$dia, $hora',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 12),
                                  onPressed: () => Navigator.pop(context),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: nombreController,
                              label: 'Nombre de la materia',
                              hint: 'Ej: Cálculo I',
                              icon: Icons.book,
                              required: true,
                            ),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: codigoController,
                              label: 'Código',
                              hint: 'Ej: MAT101',
                              icon: Icons.tag,
                            ),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: creditosController,
                              label: 'Créditos',
                              hint: 'Ej: 3',
                              icon: Icons.star,
                              required: true,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: profesorController,
                              label: 'Profesor',
                              hint: 'Ej: Dr. Juan Pérez',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: aulaController,
                                    label: 'Aula',
                                    hint: 'Ej: A-301',
                                    icon: Icons.meeting_room,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _buildTimePickerField(
                                    controller: horaFinController,
                                    label: 'Hora fin',
                                    hint: 'Seleccionar hora',
                                    icon: Icons.access_time,
                                    required: true,
                                    isDialog: true,
                                    onTap: () async {
                                      final TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: AppColors.horarioPrimary,
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF1A2634),
                                                onSurface: Colors.white,
                                                brightness: Brightness.dark,
                                              ),
                                              dialogBackgroundColor: const Color(0xFF1A2634),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: AppColors.horarioPrimary,
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        horaFinController.text = 
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            _buildTextField(
                              controller: notasController,
                              label: 'Notas',
                              hint: 'Ej: Traer calculadora',
                              icon: Icons.note,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            _buildColorPickerField(
                              selectedColor,
                              (color) {
                                setModalState(() {
                                  selectedColor = color;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            // Botones
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => Navigator.pop(context),
                                            borderRadius: BorderRadius.circular(8),
                                            splashColor: Colors.white.withOpacity(0.1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              child: Center(
                                                child: Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.horarioPrimary, AppColors.horarioSecondary],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.horarioPrimary.withOpacity(0.4),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () async {
                                              if (nombreController.text.isEmpty || 
                                                  horaFinController.text.isEmpty) {
                                                _showSnackBar('Por favor completa los campos requeridos');
                                                return;
                                              }
                                              
                                              // Guardar los datos antes de cualquier operación asíncrona
                                              final nombre = nombreController.text.trim();
                                              final codigo = codigoController.text.trim();
                                              final creditos = int.tryParse(creditosController.text) ?? 3;
                                              final descripcion = notasController.text.trim().isNotEmpty 
                                                  ? notasController.text.trim() 
                                                  : null;
                                              final profesor = profesorController.text.trim().isNotEmpty 
                                                  ? profesorController.text.trim() 
                                                  : null;
                                              final aula = aulaController.text.trim().isNotEmpty 
                                                  ? aulaController.text.trim() 
                                                  : null;
                                              // Validar que la hora fin sea mayor que la hora inicio
                                              final horaFinStr = horaFinController.text;
                                              if (horaFinStr.compareTo(hora) <= 0) {
                                                _showSnackBar('La hora fin debe ser posterior a la hora inicio');
                                                return;
                                              }
                                              
                                              // Validar que no haya conflicto de horarios
                                              final conflicto = _validarConflictoHorario(dia, hora, horaFinStr);
                                              if (conflicto != null) {
                                                _showSnackBar('Conflicto de horario: Ya existe la materia "$conflicto" en este horario');
                                                return;
                                              }
                                              
                                              // Cerrar el modal primero
                                              Navigator.pop(context);
                                              
                                              // Mostrar indicador de carga
                                              BuildContext? loadingContext;
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (dialogContext) {
                                                  loadingContext = dialogContext;
                                                  return const Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                },
                                              );
                                              
                                              try {
                                                // Validar campos requeridos
                                                if (nombre.isEmpty) {
                                                  throw Exception('El nombre de la materia es requerido');
                                                }
                                                if (codigo.isEmpty) {
                                                  throw Exception('El código es requerido');
                                                }
                                                
                                                // Validar créditos
                                                if (creditos < 1 || creditos > 10) {
                                                  throw Exception('Los créditos deben estar entre 1 y 10');
                                                }
                                                
                                                // Construir el string de horario
                                                final horarioStr = '$dia $hora - ${horaFinController.text}';
                                                
                                                // Primero crear la materia
                                                final materia = await _materiasService.createMateria(
                                                  nombre: nombre,
                                                  codigo: codigo,
                                                  creditos: creditos,
                                                  descripcion: descripcion,
                                                  profesor: profesor,
                                                  aula: aula,
                                                  horario: horarioStr,
                                                  color: selectedColor,
                                                );
                                                
                                                // Convertir el día de abreviación a nombre completo
                                                String diaCompleto = '';
                                                switch (dia) {
                                                  case 'Lun':
                                                    diaCompleto = 'Lunes';
                                                    break;
                                                  case 'Mar':
                                                    diaCompleto = 'Martes';
                                                    break;
                                                  case 'Mié':
                                                    diaCompleto = 'Miércoles';
                                                    break;
                                                  case 'Jue':
                                                    diaCompleto = 'Jueves';
                                                    break;
                                                  case 'Vie':
                                                    diaCompleto = 'Viernes';
                                                    break;
                                                  case 'Sáb':
                                                    diaCompleto = 'Sábado';
                                                    break;
                                                  default:
                                                    diaCompleto = 'Lunes';
                                                }
                                                
                                                // Crear la relación en horarios_materias
                                                await _horariosMateriasService.createMateriaEnHorario(
                                                  horarioId: widget.horario.id!,
                                                  materiaId: materia.id,
                                                  dia: diaCompleto,
                                                  horaInicio: hora,
                                                  horaFin: horaFinController.text,
                                                  aula: aulaController.text.isNotEmpty 
                                                      ? aulaController.text 
                                                      : null,
                                                  notas: notasController.text.isNotEmpty 
                                                      ? notasController.text 
                                                      : null,
                                                );
                                                
                                                // Cerrar el dialog de carga y recargar
                                                if (mounted && loadingContext != null) {
                                                  Navigator.pop(loadingContext!); // Cerrar loading
                                                  _showSnackBar('Materia agregada exitosamente: $nombre');
                                                  await _loadMaterias();
                                                }
                                              } catch (e) {
                                                // Cerrar el dialog de carga y mostrar error
                                                if (mounted && loadingContext != null) {
                                                  Navigator.pop(loadingContext!); // Cerrar loading
                                                  _showSnackBar('Error al guardar: $e');
                                                }
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(10),
                                            splashColor: Colors.white.withOpacity(0.2),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Text(
                                                    'Guardar',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.1,
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isDark = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: isDark ? Colors.red[300] : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 32,
                maxHeight: 40,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                        ]
                      : [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.15),
                        ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 11,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[600],
                    fontSize: 11,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: isDark ? Colors.white : AppColors.horarioPrimary,
                    size: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    bool required = false,
    bool isDialog = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDialog ? Colors.white.withOpacity(0.9) : Colors.black87,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 32,
                maxHeight: 40,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDialog
                      ? [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                        ]
                      : [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.15),
                        ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                readOnly: true,
                onTap: onTap,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: isDialog ? Colors.white : Colors.black87,
                  fontSize: 11,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: isDialog
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[600],
                    fontSize: 11,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: isDialog ? Colors.white : AppColors.horarioPrimary,
                    size: 14,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: isDialog ? Colors.white.withOpacity(0.8) : AppColors.horarioPrimary,
                    size: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerField(String selectedColor, Function(String) onColorSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la materia',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _colores.map((color) {
            final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
            final isSelected = selectedColor == colorHex;
            
            return GestureDetector(
              onTap: () {
                onColorSelected(colorHex);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(0, 255, 255, 255),
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}