import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/examenes_provider.dart';
import '../config/app_colors.dart';
import 'dart:ui';

class EstadisticasExamenesScreen extends StatefulWidget {
  const EstadisticasExamenesScreen({super.key});

  @override
  State<EstadisticasExamenesScreen> createState() => _EstadisticasExamenesScreenState();
}

class _EstadisticasExamenesScreenState extends State<EstadisticasExamenesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExamenesProvider>(context, listen: false);
      provider.fetchEstadisticasGenerales();
    });
  }

  @override
  void dispose() {
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
              Expanded(
                child: Consumer<ExamenesProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.examenesPrimary,
                          strokeWidth: 3,
                        ),
                      );
                    }

                    if (provider.error != null) {
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
                                      Icons.error_outline_rounded,
                                      size: 64,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                provider.error!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          provider.fetchEstadisticasGenerales();
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        splashColor: Colors.white.withOpacity(0.1),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 16),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      AppColors.examenesPrimary,
                                                      AppColors.examenesSecondary,
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Reintentar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
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
                      );
                    }

                    final estadisticasRendimiento = provider.getEstadisticasRendimiento();

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gráfica de rendimiento
                              _buildRendimientoChart(provider),
                              const SizedBox(height: 16),

                              // Resumen general
                              _buildResumenCard(estadisticasRendimiento),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Estadísticas',
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

  Widget _buildResumenCard(Map<String, dynamic> estadisticas) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.examenesPrimary.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                child: const Icon(
                  Icons.assessment_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                'Resumen General',
                style: TextStyle(
                    fontSize: 14,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Exámenes',
                  estadisticas['totalExamenes'].toString(),
                  Icons.quiz_rounded,
                  const Color(0xFFFF9800), // Naranja
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  'Calificados',
                  estadisticas['examenesCalificados'].toString(),
                  Icons.grade_rounded,
                  const Color(0xFF4CAF50), // Verde
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Promedio',
                  estadisticas['promedioGeneral'].toStringAsFixed(2),
                  Icons.trending_up_rounded,
                  AppColors.examenesPrimary, // Celeste
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  'Aprobación',
                  '${estadisticas['porcentajeAprobacion'].toStringAsFixed(1)}%',
                  Icons.check_circle_rounded,
                  const Color(0xFF9C27B0), // Púrpura
                ),
              ),
            ],
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
      ),
      child: Column(
        children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withOpacity(0.3),
                      iconColor.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
            icon,
                  color: iconColor,
                  size: 16,
          ),
              ),
              const SizedBox(height: 6),
          Text(
            value,
                style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
                  color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
          ),
        ),
      ),
    );
  }


  Widget _buildRendimientoChart(ExamenesProvider provider) {
    // Obtener exámenes calificados ordenados por fecha
    final examenesCalificados = provider.examenes
        .where((e) => e.notaEval != null && e.fechaEval != null)
        .toList();
    
    examenesCalificados.sort((a, b) => a.fechaEval!.compareTo(b.fechaEval!));

    if (examenesCalificados.isEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.examenesPrimary.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE91E63), // Rosa/Magenta
                            Color(0xFF9C27B0), // Púrpura
                          ],
                        ),
                  borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: const Icon(
                        Icons.show_chart_rounded,
                        color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                      'Gráfica de Rendimiento',
                style: TextStyle(
                    fontSize: 14,
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
                const SizedBox(height: 20),
          Container(
                  padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                    gradient: const LinearGradient(
                colors: [
                        Color(0xFFE91E63), // Rosa/Magenta
                        Color(0xFF9C27B0), // Púrpura
                      ],
                    ),
                    shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
              ),
            ],
                ),
                child: const Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20),
                Text(
                  'No hay datos suficientes',
              style: TextStyle(
                    fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa algunos exámenes para ver tu rendimiento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
              ),
              ],
          ),
          ),
      ),
    );
  }

    // Preparar datos para la gráfica
    // Tomar máximo 10 puntos para no saturar la gráfica
    final puntosGrafica = examenesCalificados.length > 10
        ? examenesCalificados.sublist(examenesCalificados.length - 10)
        : examenesCalificados;

    // Calcular valores para la gráfica
    final spots = puntosGrafica.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final examen = entry.value;
      return FlSpot(index, examen.notaEval!);
    }).toList();

    // Calcular min y max para el eje Y
    final notas = examenesCalificados.map((e) => e.notaEval!).toList();
    final minNota = notas.reduce((a, b) => a < b ? a : b);
    final maxNota = notas.reduce((a, b) => a > b ? a : b);
    final minY = (minNota - 0.5).clamp(0.0, 5.0);
    final maxY = (maxNota + 0.5).clamp(0.0, 5.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
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
                color: AppColors.examenesPrimary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE91E63), // Rosa/Magenta
                          Color(0xFF9C27B0), // Púrpura
                        ],
                      ),
                  borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                ),
                child: const Icon(
                      Icons.show_chart_rounded,
                      color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                    'Gráfica de Rendimiento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
              ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < puntosGrafica.length) {
                              final examen = puntosGrafica[value.toInt()];
                              if (examen.fechaEval != null) {
                                return Text(
                                  '${examen.fechaEval!.day}/${examen.fechaEval!.month}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
      ),
    );
  }
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 0.5,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
                            );
                          },
      ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
                        width: 1,
            ),
                    ),
                    minX: 0,
                    maxX: (puntosGrafica.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.examenesPrimary,
                            AppColors.examenesSecondary,
                          ],
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: AppColors.examenesPrimary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
              ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.examenesSecondary.withOpacity(0.3),
                              AppColors.examenesSecondary.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                ),
              ),
            ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.black87,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final examen = puntosGrafica[barSpot.x.toInt()];
                            return LineTooltipItem(
                              'Nota: ${barSpot.y.toStringAsFixed(1)}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: examen.materia != null
                                  ? [
                                      TextSpan(
                                        text: examen.materia!.nombre,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
          ),
                                    ]
                                  : [],
                            );
                          }).toList();
                        },
                      ),
          ),
        ),
      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
        border: Border.all(
                            color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
                          mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                              width: 10,
                              height: 10,
            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.examenesPrimary,
                                    AppColors.examenesSecondary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
          ),
                            const SizedBox(width: 8),
                            Text(
                              'Evolución de notas',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
    );
  }
}