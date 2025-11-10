import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bienestar.dart';
import '../providers/bienestar_provider.dart';
import 'dart:ui';

class CuestionarioScreen extends StatefulWidget {
  final TipoCuestionario tipo;

  const CuestionarioScreen({
    super.key,
    required this.tipo,
  });

  @override
  State<CuestionarioScreen> createState() => _CuestionarioScreenState();
}

class _CuestionarioScreenState extends State<CuestionarioScreen> {
  final Map<String, int> _respuestas = {};
  bool _isCompletado = false;

  List<PreguntaCuestionario> _getPreguntas() {
    switch (widget.tipo) {
      case TipoCuestionario.phq9:
        return [
          PreguntaCuestionario(
            id: 'phq9_1',
            texto: 'Poco interés o placer en hacer cosas',
          ),
          PreguntaCuestionario(
            id: 'phq9_2',
            texto: 'Sentirse deprimido(a), desanimado(a) o sin esperanzas',
          ),
          PreguntaCuestionario(
            id: 'phq9_3',
            texto: 'Dificultad para quedarse dormido(a), mantenerse dormido(a) o dormir demasiado',
          ),
          PreguntaCuestionario(
            id: 'phq9_4',
            texto: 'Sentirse cansado(a) o tener poca energía',
          ),
          PreguntaCuestionario(
            id: 'phq9_5',
            texto: 'Poco apetito o comer en exceso',
          ),
          PreguntaCuestionario(
            id: 'phq9_6',
            texto: 'Sentirse mal con uno mismo(a) - o que es un fracaso o que ha decepcionado a su familia o a usted mismo(a)',
          ),
          PreguntaCuestionario(
            id: 'phq9_7',
            texto: 'Dificultad para concentrarse en ciertas actividades, tales como leer el periódico o ver la televisión',
          ),
          PreguntaCuestionario(
            id: 'phq9_8',
            texto: 'Moverse o hablar tan lento que otras personas podrían haberlo notado. O lo contrario - estar tan inquieto(a) o agitado(a) que ha estado moviéndose mucho más de lo normal',
          ),
          PreguntaCuestionario(
            id: 'phq9_9',
            texto: 'Pensamientos de que estaría mejor muerto(a) o de lastimarse de alguna manera',
          ),
        ];
      case TipoCuestionario.gad7:
        return [
          PreguntaCuestionario(
            id: 'gad7_1',
            texto: 'Sentirse nervioso(a), ansioso(a) o muy inquieto(a)',
          ),
          PreguntaCuestionario(
            id: 'gad7_2',
            texto: 'No ser capaz de detener o controlar la preocupación',
          ),
          PreguntaCuestionario(
            id: 'gad7_3',
            texto: 'Preocuparse demasiado por diferentes cosas',
          ),
          PreguntaCuestionario(
            id: 'gad7_4',
            texto: 'Dificultad para relajarse',
          ),
          PreguntaCuestionario(
            id: 'gad7_5',
            texto: 'Estar tan inquieto(a) que es difícil quedarse quieto(a)',
          ),
          PreguntaCuestionario(
            id: 'gad7_6',
            texto: 'Molestarse o irritarse fácilmente',
          ),
          PreguntaCuestionario(
            id: 'gad7_7',
            texto: 'Sentir miedo como si algo terrible fuera a suceder',
          ),
        ];
      case TipoCuestionario.isi:
        return [
          PreguntaCuestionario(
            id: 'isi_1',
            texto: 'Dificultad para quedarse dormido(a)',
          ),
          PreguntaCuestionario(
            id: 'isi_2',
            texto: 'Dificultad para mantenerse dormido(a)',
          ),
          PreguntaCuestionario(
            id: 'isi_3',
            texto: 'Problemas para despertarse muy temprano',
          ),
          PreguntaCuestionario(
            id: 'isi_4',
            texto: '¿Qué tan satisfecho(a) o insatisfecho(a) está con su patrón actual de sueño?',
          ),
          PreguntaCuestionario(
            id: 'isi_5',
            texto: '¿Qué tan visible o problemático considera que su patrón de sueño es para su calidad de vida?',
          ),
          PreguntaCuestionario(
            id: 'isi_6',
            texto: '¿Qué tan preocupado(a) o angustiado(a) está acerca de su problema actual de sueño?',
          ),
          PreguntaCuestionario(
            id: 'isi_7',
            texto: '¿En qué medida considera que este problema de sueño interfiere con su funcionamiento diario?',
          ),
        ];
    }
  }

  List<String> _getOpcionesRespuesta() {
    switch (widget.tipo) {
      case TipoCuestionario.phq9:
      case TipoCuestionario.gad7:
        return [
          'Nada en absoluto',
          'Varios días',
          'Más de la mitad de los días',
          'Casi todos los días',
        ];
      case TipoCuestionario.isi:
        return [
          'Ninguno',
          'Leve',
          'Moderado',
          'Severo',
          'Muy severo',
        ];
    }
  }

  int _getPuntuacionTotal() {
    return _respuestas.values.fold(0, (sum, value) => sum + value);
  }

  String _getInterpretacion(int puntuacion) {
    switch (widget.tipo) {
      case TipoCuestionario.phq9:
        if (puntuacion >= 0 && puntuacion <= 4) {
          return 'Depresión mínima';
        } else if (puntuacion >= 5 && puntuacion <= 9) {
          return 'Depresión leve';
        } else if (puntuacion >= 10 && puntuacion <= 14) {
          return 'Depresión moderada';
        } else if (puntuacion >= 15 && puntuacion <= 19) {
          return 'Depresión moderadamente severa';
        } else {
          return 'Depresión severa';
        }
      case TipoCuestionario.gad7:
        if (puntuacion >= 0 && puntuacion <= 4) {
          return 'Ansiedad mínima';
        } else if (puntuacion >= 5 && puntuacion <= 9) {
          return 'Ansiedad leve';
        } else if (puntuacion >= 10 && puntuacion <= 14) {
          return 'Ansiedad moderada';
        } else {
          return 'Ansiedad severa';
        }
      case TipoCuestionario.isi:
        if (puntuacion >= 0 && puntuacion <= 7) {
          return 'Ausencia de insomnio clínicamente significativo';
        } else if (puntuacion >= 8 && puntuacion <= 14) {
          return 'Insomnio subclínico';
        } else if (puntuacion >= 15 && puntuacion <= 21) {
          return 'Insomnio moderado';
        } else {
          return 'Insomnio severo';
        }
    }
  }

  Color _getColorInterpretacion(String interpretacion) {
    if (interpretacion.contains('mínima') || 
        interpretacion.contains('leve') ||
        interpretacion.contains('Ausencia')) {
      return Colors.green;
    } else if (interpretacion.contains('moderada') ||
               interpretacion.contains('moderado') ||
               interpretacion.contains('subclínico')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> _guardarResultado() async {
    if (_respuestas.length != _getPreguntas().length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, responde todas las preguntas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final puntuacionTotal = _getPuntuacionTotal();
    final interpretacion = _getInterpretacion(puntuacionTotal);

    final resultado = ResultadoCuestionario(
      id: '', // Se asignará desde el backend
      tipo: widget.tipo,
      puntuacionTotal: puntuacionTotal,
      fechaCompletado: DateTime.now(),
      interpretacion: interpretacion,
      respuestas: Map<String, int>.from(_respuestas),
    );

    final bienestarProvider = Provider.of<BienestarProvider>(context, listen: false);
    final guardado = await bienestarProvider.guardarResultadoCuestionario(resultado);

    if (guardado && mounted) {
      setState(() {
        _isCompletado = true;
      });
      
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resultado guardado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bienestarProvider.error ?? 'Error al guardar el resultado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preguntas = _getPreguntas();
    final opciones = _getOpcionesRespuesta();
    final tipoInfo = widget.tipo;

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
              _buildAppBar(context, tipoInfo),
              Expanded(
                child: _isCompletado
                    ? _buildResultado(context)
                    : _buildCuestionario(context, preguntas, opciones),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, TipoCuestionario tipo) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tipo.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tipo.descripcion,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuestionario(
    BuildContext context,
    List<PreguntaCuestionario> preguntas,
    List<String> opciones,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: preguntas.length + 1,
      itemBuilder: (context, index) {
        if (index == preguntas.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 32),
            child: ElevatedButton(
              onPressed: _guardarResultado,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.tipo.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Completar Cuestionario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        final pregunta = preguntas[index];
        final valorSeleccionado = _respuestas[pregunta.id];

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ${pregunta.texto}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...opciones.asMap().entries.map((entry) {
                final opcionIndex = entry.key;
                final opcion = entry.value;
                final isSelected = valorSeleccionado == opcionIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _respuestas[pregunta.id] = opcionIndex;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.tipo.color.withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? widget.tipo.color
                              : Colors.white.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? widget.tipo.color
                                    : Colors.white70,
                                width: 2,
                              ),
                              color: isSelected
                                  ? widget.tipo.color
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opcion,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
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
        );
      },
    );
  }

  Widget _buildResultado(BuildContext context) {
    final puntuacionTotal = _getPuntuacionTotal();
    final interpretacion = _getInterpretacion(puntuacionTotal);
    final colorInterpretacion = _getColorInterpretacion(interpretacion);
    final maxPuntuacion = widget.tipo == TipoCuestionario.isi ? 28 : 27;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: colorInterpretacion,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cuestionario Completado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorInterpretacion.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Puntuación: $puntuacionTotal/$maxPuntuacion',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorInterpretacion.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      interpretacion,
                      style: TextStyle(
                        color: colorInterpretacion,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Recuerda que este cuestionario es solo una herramienta de autoevaluación y no reemplaza el diagnóstico profesional. Si tienes preocupaciones, consulta con un profesional de la salud.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.tipo.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Volver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

