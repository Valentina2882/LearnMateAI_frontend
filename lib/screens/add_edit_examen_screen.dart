import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/examen.dart';
import '../models/materia.dart';
import '../providers/examenes_provider.dart';
import '../providers/auth_provider.dart';
import '../services/materias_service.dart';
import '../services/horarios_service.dart';
import '../config/app_colors.dart';
import 'dart:ui';

class AddEditExamenScreen extends StatefulWidget {
  final Examen? examen;

  const AddEditExamenScreen({super.key, this.examen});

  @override
  State<AddEditExamenScreen> createState() => _AddEditExamenScreenState();
}

class _AddEditExamenScreenState extends State<AddEditExamenScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notaController = TextEditingController();
  final _ponderacionController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TipoEvaluacion? _selectedTipo;
  String? _selectedMateriaId;
  DateTime? _selectedDate;
  EstadoEvaluacion? _selectedEstado;
  List<Materia> _materias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    
    _loadMaterias();
    _initializeFields();
  }

  @override
  void dispose() {
    _animController.dispose();
    _notaController.dispose();
    _ponderacionController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (widget.examen != null) {
      _selectedTipo = widget.examen!.tipoEval;
      _selectedMateriaId = widget.examen!.materiaId;
      _selectedDate = widget.examen!.fechaEval;
      _selectedEstado = widget.examen!.estadoEval;
      
      if (widget.examen!.notaEval != null) {
        _notaController.text = widget.examen!.notaEval.toString();
      }
      if (widget.examen!.ponderacionEval != null) {
        _ponderacionController.text = widget.examen!.ponderacionEval.toString();
      }
    }
  }

  Future<void> _loadMaterias() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final materiasService = MateriasService();
      _materias = await materiasService.getMaterias();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error al cargar materias: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    // Obtener el inicio del semestre del usuario
    DateTime? fechaInicioSemestre;
    try {
      final horariosService = HorariosService();
      final horarios = await horariosService.getHorarios();
      if (horarios.isNotEmpty) {
        // Ordenar por fecha de inicio más reciente
        horarios.sort((a, b) {
          if (a.fechainiciosemestre == null || b.fechainiciosemestre == null) return 0;
          return DateTime.parse(b.fechainiciosemestre!)
              .compareTo(DateTime.parse(a.fechainiciosemestre!));
        });
        final horarioMasReciente = horarios.first;
        if (horarioMasReciente.fechainiciosemestre != null) {
          fechaInicioSemestre = DateTime.parse(horarioMasReciente.fechainiciosemestre!);
        }
      }
    } catch (e) {
      print('[AddEditExamenScreen] Error al obtener horarios: $e');
    }

    // Establecer firstDate: inicio del semestre o 1 año atrás si no hay horario
    final firstDate = fechaInicioSemestre ?? DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.examenesPrimary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF2C2C2C),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      // Validar que no sea antes del inicio del semestre
      if (fechaInicioSemestre != null && picked.isBefore(fechaInicioSemestre)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'La fecha no puede ser antes del inicio del semestre (${fechaInicioSemestre.day}/${fechaInicioSemestre.month}/${fechaInicioSemestre.year})',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExamen() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMateriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Por favor selecciona una materia'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ExamenesProvider>(context, listen: false);
      bool success;

      if (widget.examen != null) {
        // Actualizar examen existente
        success = await provider.updateExamen(
          widget.examen!.id,
          tipoEval: _selectedTipo,
          fechaEval: _selectedDate,
          notaEval: _notaController.text.isNotEmpty 
              ? double.tryParse(_notaController.text) 
              : null,
          ponderacionEval: _ponderacionController.text.isNotEmpty 
              ? double.tryParse(_ponderacionController.text) 
              : null,
          estadoEval: _selectedEstado,
        );
      } else {
        // Crear nuevo examen
        success = await provider.createExamen(
          materiaId: _selectedMateriaId!,
          tipoEval: _selectedTipo,
          fechaEval: _selectedDate,
          notaEval: _notaController.text.isNotEmpty 
              ? double.tryParse(_notaController.text) 
              : null,
          ponderacionEval: _ponderacionController.text.isNotEmpty 
              ? double.tryParse(_ponderacionController.text) 
              : null,
          estadoEval: _selectedEstado,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.examen != null 
                    ? 'Examen actualizado exitosamente' 
                    : 'Examen creado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                child: _isLoading && _materias.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.examenesPrimary,
                          strokeWidth: 3,
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildFormCard(),
                                  const SizedBox(height: 8),
                                  _buildSaveButton(),
                                  const SizedBox(height: 8),
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
                width: 28,
                height: 28,
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
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 14),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.examenesPrimary,
                  AppColors.examenesSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.examenesPrimary.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.examen != null ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.examen != null ? 'Editar Examen' : 'Nuevo Examen',
              style: const TextStyle(
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

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.examenesPrimary.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.examenesPrimary,
                      AppColors.examenesSecondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.examenesPrimary.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Información del Examen',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Selector de materia
          _buildFieldLabel('Materia', isRequired: true),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.book_rounded,
                      size: 14,
                      color: Colors.cyan,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.examenesPrimary.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  dropdownColor: const Color(0xFF1A2634),
                  value: _selectedMateriaId,
                  hint: Text(
                    'Selecciona una materia',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 14,
                  ),
                  isExpanded: true,
                  items: _materias.map((materia) {
                    return DropdownMenuItem<String>(
                      value: materia.id,
                      child: Text(
                        materia.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) {
                    return _materias.map((materia) {
                      return Text(
                        materia.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedMateriaId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona una materia';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Selector de tipo de evaluación
          _buildFieldLabel('Tipo de Evaluación'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<TipoEvaluacion>(
            decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.category_rounded,
                      size: 14,
                      color: Colors.cyan,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
              border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.examenesPrimary.withOpacity(0.5),
                        width: 2,
                      ),
              ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  dropdownColor: const Color(0xFF1A2634),
            value: _selectedTipo,
                  hint: Text(
                    'Selecciona el tipo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  isExpanded: true,
            items: TipoEvaluacion.values.map((tipo) {
              return DropdownMenuItem<TipoEvaluacion>(
                value: tipo,
                      child: Text(
                        tipo.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              );
            }).toList(),
                  selectedItemBuilder: (context) {
                    return TipoEvaluacion.values.map((tipo) {
                      return Text(
                        tipo.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }).toList();
                  },
            onChanged: (value) {
              setState(() {
                _selectedTipo = value;
              });
            },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Selector de fecha
          _buildFieldLabel('Fecha del Examen'),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: InkWell(
            onTap: _selectDate,
                borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
              ),
              child: Row(
                children: [
                      const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                        color: Colors.cyan,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: _selectedDate != null 
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                        fontSize: 12,
                            fontWeight: _selectedDate != null 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                        color: Colors.white.withOpacity(0.6),
                  ),
                ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Campo de nota (dinámico según sistema de calificación)
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final maxNota = authProvider.user?.sistemaCalificacion ?? 5;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Nota (0-$maxNota)'),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                    controller: _notaController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                    decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.grade_rounded,
                              size: 14,
                              color: Colors.cyan,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                      hintText: 'Ej: ${maxNota == 10 ? '8.5' : '4.5'}',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                      border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.examenesPrimary.withOpacity(0.5),
                                width: 1,
                              ),
                      ),
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final nota = double.tryParse(value);
                        if (nota == null || nota < 0 || nota > maxNota) {
                          return 'La nota debe estar entre 0 y $maxNota';
                        }
                      }
                      return null;
                    },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),

          // Campo de ponderación
          _buildFieldLabel('Ponderación (0-1)'),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: TextFormField(
            controller: _ponderacionController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
            decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.percent_rounded,
                      size: 14,
                      color: Colors.cyan,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
              hintText: 'Ej: 0.3',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
              border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.examenesPrimary.withOpacity(0.5),
                        width: 1,
                      ),
              ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    isDense: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final ponderacion = double.tryParse(value);
                if (ponderacion == null || ponderacion < 0 || ponderacion > 1) {
                  return 'La ponderación debe estar entre 0 y 1';
                }
              }
              return null;
            },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Selector de estado
          _buildFieldLabel('Estado'),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<EstadoEvaluacion>(
            decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.info_rounded,
                      size: 14,
                      color: Colors.cyan,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
              border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.examenesPrimary.withOpacity(0.5),
                        width: 1,
                      ),
              ),
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  dropdownColor: const Color(0xFF1A2634),
            value: _selectedEstado,
                  hint: Text(
                    'Selecciona el estado',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 14,
                  ),
                  isExpanded: true,
            items: EstadoEvaluacion.values.map((estado) {
              return DropdownMenuItem<EstadoEvaluacion>(
                value: estado,
                child: Row(
                  children: [
                    Icon(estado.icon, size: 14, color: estado.color),
                    const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                            estado.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                              overflow: TextOverflow.ellipsis,
                          ),
                          ),
                  ],
                ),
              );
            }).toList(),
                  selectedItemBuilder: (context) {
                    return EstadoEvaluacion.values.map((estado) {
                      return Row(
                        children: [
                          Icon(estado.icon, size: 14, color: estado.color),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                            estado.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                              overflow: TextOverflow.ellipsis,
                          ),
                          ),
                        ],
                      );
                    }).toList();
                  },
            onChanged: (value) {
              setState(() {
                _selectedEstado = value;
              });
            },
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

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.2,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 2),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.examenesPrimary.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _saveExamen,
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.white.withOpacity(0.1),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.examenesPrimary, AppColors.examenesSecondary],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              widget.examen != null ? Icons.save_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.examen != null ? 'Actualizar Examen' : 'Crear Examen',
                            style: const TextStyle(
                              fontSize: 13,
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
        ),
      ),
    );
  }
}