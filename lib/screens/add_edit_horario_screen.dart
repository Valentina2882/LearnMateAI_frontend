import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/horario.dart';
import '../providers/horarios_provider.dart';
import '../config/app_colors.dart';
import 'dart:ui';

class AddEditHorarioScreen extends StatefulWidget {
  final Horario? horario;

  const AddEditHorarioScreen({super.key, this.horario});

  @override
  State<AddEditHorarioScreen> createState() => _AddEditHorarioScreenState();
}

class _AddEditHorarioScreenState extends State<AddEditHorarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombrehorController = TextEditingController();
  final _descripcionhorController = TextEditingController();
  final _fechainiciosemestreController = TextEditingController();
  final _fechafinsemestreController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.horario != null) {
      _nombrehorController.text = widget.horario!.nombrehor ?? '';
      _descripcionhorController.text = widget.horario!.descripcionhor ?? '';
      _fechainiciosemestreController.text = widget.horario!.fechainiciosemestre ?? '';
      _fechafinsemestreController.text = widget.horario!.fechafinsemestre ?? '';
    }
  }

  @override
  void dispose() {
    _nombrehorController.dispose();
    _descripcionhorController.dispose();
    _fechainiciosemestreController.dispose();
    _fechafinsemestreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.horario != null;
    
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
              _buildAppBar(context, isEditing),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
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
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Información del Horario', Icons.info_outline_rounded),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                controller: _nombrehorController,
                                label: 'Nombre del horario',
                                hint: 'Ej: Horario Semestre 2024-1',
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa el nombre del horario';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                controller: _descripcionhorController,
                                label: 'Descripción del horario',
                                hint: 'Descripción del horario académico',
                                maxLines: 3,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingresa la descripción del horario';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 32),
                              _buildSectionTitle('Periodo Académico', Icons.calendar_month_rounded),
                              const SizedBox(height: 20),
                              
                              _buildDateField(
                                controller: _fechainiciosemestreController,
                                label: 'Fecha inicio semestre',
                                isRequired: true,
                                isStartDate: true,
                                endDateController: _fechafinsemestreController,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              _buildDateField(
                                controller: _fechafinsemestreController,
                                label: 'Fecha fin semestre (opcional)',
                                isStartDate: false,
                                startDateController: _fechainiciosemestreController,
                              ),
                              
                              const SizedBox(height: 40),
                              _buildSaveButton(isEditing),
                              const SizedBox(height: 20),
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

  Widget _buildAppBar(BuildContext context, bool isEditing) {
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
              gradient: LinearGradient(
                colors: [
                  AppColors.celeste,
                  AppColors.verdeAzulado,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.celeste.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Horario' : 'Nuevo Horario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  isEditing ? 'Modifica los detalles' : 'Configura tu semestre',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.white),
                    onPressed: _showDeleteConfirmation,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.azulOscuro, AppColors.verdeAzulado],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.azulOscuro.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: TextFormField(
                controller: controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  prefixIcon: icon != null
                      ? Icon(icon, color: Colors.cyan[300], size: 20)
                      : null,
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
                    borderSide: BorderSide(
                      color: AppColors.celeste.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                maxLines: maxLines,
                validator: validator,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isStartDate = false,
    TextEditingController? startDateController,
    TextEditingController? endDateController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: TextFormField(
                controller: controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Seleccionar fecha (YYYY-MM-DD)',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.cyan[300],
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                  ),
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
                    borderSide: BorderSide(
                      color: AppColors.celeste.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
                readOnly: true,
                onTap: () async {
        DateTime initialDate = DateTime.now();
        DateTime firstDate = DateTime(2020);
        DateTime lastDate = DateTime(2030);

        // Si es fecha de inicio, establecer límites normales
        if (isStartDate) {
          firstDate = DateTime(2020);
          lastDate = DateTime(2030);
          // Si hay fecha fin, no permitir que la inicio sea después
          if (endDateController != null && endDateController.text.isNotEmpty) {
            try {
              final endDate = DateTime.parse(endDateController.text);
              lastDate = endDate;
            } catch (e) {
              // Ignorar si no se puede parsear
            }
          }
        } else {
          // Si es fecha de fin, debe ser después de la inicio
          if (startDateController != null && startDateController.text.isNotEmpty) {
            try {
              final startDate = DateTime.parse(startDateController.text);
              initialDate = startDate.add(const Duration(days: 120)); // 4 meses por defecto
              firstDate = startDate.add(const Duration(days: 1)); // Al menos 1 día después
              lastDate = startDate.add(const Duration(days: 210)); // Máximo 7 meses (un poco más de 6 para flexibilidad)
            } catch (e) {
              firstDate = DateTime(2020);
              lastDate = DateTime(2030);
            }
          } else {
            firstDate = DateTime(2020);
            lastDate = DateTime(2030);
          }
        }

        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.azulOscuro,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            controller.text = picked.toIso8601String().split('T')[0];
          });
          // Validar el formulario después de cambiar la fecha
          _formKey.currentState?.validate();
        }
      },
      validator: (value) {
        if (isRequired) {
          if (value == null || value.isEmpty) {
            return 'Selecciona la fecha de inicio del semestre';
          }
        }

        // Validar fecha de inicio
        if (isStartDate && value != null && value.isNotEmpty) {
          try {
            final startDate = DateTime.parse(value);
            
            // Si hay fecha fin, validar que la inicio sea antes
            if (endDateController != null && endDateController.text.isNotEmpty) {
              try {
                final endDate = DateTime.parse(endDateController.text);
                if (startDate.isAfter(endDate) || startDate.isAtSameMomentAs(endDate)) {
                  return 'La fecha de inicio debe ser anterior a la fecha de fin';
                }
              } catch (e) {
                // Ignorar si no se puede parsear la fecha fin
              }
            }
          } catch (e) {
            return 'Fecha inválida';
          }
        }

        // Validar fecha de fin
        if (!isStartDate && value != null && value.isNotEmpty) {
          if (startDateController == null || startDateController.text.isEmpty) {
            return 'Primero selecciona la fecha de inicio';
          }

          try {
            final endDate = DateTime.parse(value);
            final startDate = DateTime.parse(startDateController.text);

            // Validar que la fecha fin sea después de la inicio
            if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
              return 'La fecha de fin debe ser posterior a la fecha de inicio';
            }

            // Validar que la duración esté entre 4 y 6 meses
            final diferencia = endDate.difference(startDate);
            final meses = diferencia.inDays / 30.0;

            if (meses < 4) {
              return 'El semestre debe durar al menos 4 meses (${meses.toStringAsFixed(1)} meses actuales)';
            }
            if (meses > 6) {
              return 'El semestre no debe durar más de 6 meses (${meses.toStringAsFixed(1)} meses actuales)';
            }
          } catch (e) {
            return 'Fecha inválida';
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
  }

  Widget _buildSaveButton(bool isEditing) {
    return Consumer<HorariosProvider>(
      builder: (context, horariosProvider, child) {
        final isLoading = _isSaving || horariosProvider.isLoading;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLoading
                      ? [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ]
                      : [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(isLoading ? 0.2 : 0.3),
                  width: 1.5,
                ),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.celeste.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : _handleSave,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          Icon(
                            isEditing ? Icons.check_circle_rounded : Icons.add_circle_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          isLoading
                              ? (isEditing ? 'Actualizando...' : 'Creando...')
                              : (isEditing ? 'Actualizar Horario' : 'Crear Horario'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white.withOpacity(isLoading ? 0.7 : 1.0),
                            height: 1.2,
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
      },
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validación adicional de fechas antes de guardar
    final fechaInicio = _fechainiciosemestreController.text.trim();
    final fechaFin = _fechafinsemestreController.text.trim();

    // Validar que la fecha de inicio esté presente (es requerida)
    if (fechaInicio.isEmpty) {
      _showErrorSnackBar('Debes seleccionar la fecha de inicio del semestre');
      return;
    }

    if (fechaFin.isNotEmpty) {
      try {
        final inicio = DateTime.parse(fechaInicio);
        final fin = DateTime.parse(fechaFin);

        // Validar que la fecha fin sea después de la inicio
        if (fin.isBefore(inicio) || fin.isAtSameMomentAs(inicio)) {
          _showErrorSnackBar('La fecha de fin debe ser posterior a la fecha de inicio');
          return;
        }

        // Validar que la duración esté entre 4 y 6 meses
        final diferencia = fin.difference(inicio);
        final meses = diferencia.inDays / 30.0;

        if (meses < 4) {
          _showErrorSnackBar('El semestre debe durar al menos 4 meses (${meses.toStringAsFixed(1)} meses)');
          return;
        }
        if (meses > 6) {
          _showErrorSnackBar('El semestre no debe durar más de 6 meses (${meses.toStringAsFixed(1)} meses)');
          return;
        }
      } catch (e) {
        _showErrorSnackBar('Error al validar las fechas: ${e.toString()}');
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final horariosProvider = Provider.of<HorariosProvider>(context, listen: false);
      
      bool success;
      if (widget.horario == null) {
        success = await horariosProvider.createHorario(
          nombrehor: _nombrehorController.text.trim(),
          descripcionhor: _descripcionhorController.text.trim(),
          fechainiciosemestre: fechaInicio,
          fechafinsemestre: fechaFin.isEmpty ? null : fechaFin,
        );
      } else {
        success = await horariosProvider.updateHorario(
          id: widget.horario!.id,
          nombrehor: _nombrehorController.text.trim(),
          descripcionhor: _descripcionhorController.text.trim(),
          fechainiciosemestre: fechaInicio,
          fechafinsemestre: fechaFin.isEmpty ? null : fechaFin,
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        if (mounted) {
          _showSuccessSnackBar(widget.horario == null 
              ? 'Horario creado exitosamente 🎉' 
              : 'Horario actualizado exitosamente ✅');
        }
      } else {
        _showErrorSnackBar(horariosProvider.error ?? 'Error al guardar el horario');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error inesperado: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Eliminar Horario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            '¿Estás seguro de que quieres eliminar este horario? Esta acción no se puede deshacer.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteHorario();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteHorario() async {
    final horariosProvider = Provider.of<HorariosProvider>(context, listen: false);
    final success = await horariosProvider.deleteHorario(widget.horario!.id);
    
    if (success) {
      Navigator.of(context).pop();
      _showSuccessSnackBar('Horario eliminado exitosamente');
    } else {
      _showErrorSnackBar(horariosProvider.error ?? 'Error al eliminar el horario');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.verdeAzulado, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.verdeAzulado,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_rounded, color: Colors.red, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}