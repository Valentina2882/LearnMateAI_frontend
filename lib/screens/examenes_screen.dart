import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/examen.dart';
import '../providers/examenes_provider.dart';
import '../services/materias_service.dart';
import 'add_edit_examen_screen.dart';
import 'estadisticas_examenes_screen.dart';
import '../config/app_colors.dart';
import '../utils/profile_helper.dart';
import 'dart:ui';

class ExamenesScreen extends StatefulWidget {
  const ExamenesScreen({super.key});

  @override
  State<ExamenesScreen> createState() => _ExamenesScreenState();
}

class _ExamenesScreenState extends State<ExamenesScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMateriaId;
  EstadoEvaluacion? _selectedEstado;
  TipoEvaluacion? _selectedTipo;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final examenesProvider = Provider.of<ExamenesProvider>(context, listen: false);
    await _applyFilters();
    await examenesProvider.fetchEstadisticasGenerales();
  }

  Future<void> _applyFilters() async {
    final examenesProvider = Provider.of<ExamenesProvider>(context, listen: false);
    await examenesProvider.fetchExamenes(
      materiaId: _selectedMateriaId,
      estadoEval: _selectedEstado?.value,
      tipoEval: _selectedTipo?.value,
    );
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
              _buildSearchBar(),
              if (_showFilters) _buildFilters(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildExamenesList(),
                        _buildExamenesProximos(),
                        _buildExamenesPendientes(),
                        _buildExamenesCalificados(),
                      ],
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
            colors: [AppColors.celeste, AppColors.verdeAzulado],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.celeste.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final canAccess = await ProfileHelper.checkAndShowCompleteProfile(
              context,
              onComplete: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditExamenScreen(),
              ),
            );
              },
            );
            
            if (canAccess) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditExamenScreen(),
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Nuevo Examen',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
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
            child: const Icon(
              Icons.quiz_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Exámenes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EstadisticasExamenesScreen(),
                      ),
                    );
                  },
                ),
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
                  colors: [AppColors.celeste, AppColors.verdeAzulado],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Todos', icon: Icon(Icons.list_rounded, size: 20)),
                Tab(text: 'Próximos', icon: Icon(Icons.schedule_rounded, size: 20)),
                Tab(text: 'Pendientes', icon: Icon(Icons.pending_rounded, size: 20)),
                Tab(text: 'Calificados', icon: Icon(Icons.grade_rounded, size: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
              child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar exámenes...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_rounded, color: Colors.white.withOpacity(0.8)),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          Container(
            decoration: BoxDecoration(
              color: _showFilters 
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: _showFilters ? Colors.white : Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (_selectedMateriaId != null || 
                  _selectedEstado != null || 
                  _selectedTipo != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedMateriaId = null;
                      _selectedEstado = null;
                      _selectedTipo = null;
                    });
                    _applyFilters();
                  },
                  child: Text(
                    'Limpiar',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMateriaFilter(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildEstadoFilter()),
              const SizedBox(width: 12),
              Expanded(child: _buildTipoFilter()),
            ],
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMateriaFilter() {
    return FutureBuilder<List<dynamic>>(
      future: MateriasService().getMaterias(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Materia',
              prefixIcon: const Icon(Icons.book_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: _selectedMateriaId,
            items: const [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Todas las materias'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMateriaId = value;
              });
              _applyFilters();
            },
          );
        }

        final materias = snapshot.data!;
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Materia',
            prefixIcon: const Icon(Icons.book_rounded, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          value: _selectedMateriaId,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Todas las materias'),
            ),
            ...materias.map((materia) => DropdownMenuItem<String>(
              value: materia.id,
              child: Text(materia.nombre),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMateriaId = value;
            });
            _applyFilters();
          },
        );
      },
    );
  }

  Widget _buildEstadoFilter() {
    return DropdownButtonFormField<EstadoEvaluacion>(
      decoration: InputDecoration(
        labelText: 'Estado',
        prefixIcon: const Icon(Icons.info_rounded, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedEstado,
      items: [
        const DropdownMenuItem<EstadoEvaluacion>(
          value: null,
          child: Text('Todos'),
        ),
        ...EstadoEvaluacion.values.map((estado) => DropdownMenuItem<EstadoEvaluacion>(
          value: estado,
          child: Row(
            children: [
              Icon(estado.icon, size: 16, color: estado.color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  estado.value,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedEstado = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildTipoFilter() {
    return DropdownButtonFormField<TipoEvaluacion>(
      decoration: InputDecoration(
        labelText: 'Tipo',
        prefixIcon: const Icon(Icons.category_rounded, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedTipo,
      items: [
        const DropdownMenuItem<TipoEvaluacion>(
          value: null,
          child: Text('Todos'),
        ),
        ...TipoEvaluacion.values.map((tipo) => DropdownMenuItem<TipoEvaluacion>(
          value: tipo,
          child: Text(tipo.value),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedTipo = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildExamenesList() {
    return Consumer<ExamenesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.azulOscuro),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded, 
                    size: 64, color: Colors.red[400]),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulOscuro,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        List<Examen> examenes = provider.examenes;

        // Aplicar búsqueda local (los filtros ya se aplicaron en el backend)
        if (_searchQuery.isNotEmpty) {
          examenes = provider.buscarExamenes(_searchQuery);
        }

        if (examenes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz_rounded, size: 64, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay exámenes disponibles',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: examenes.length,
          itemBuilder: (context, index) {
            final examen = examenes[index];
            return _buildExamenCard(examen);
          },
        );
      },
    );
  }

  Widget _buildExamenesProximos() {
    return Consumer<ExamenesProvider>(
      builder: (context, provider, child) {
        final examenesProximos = provider.getExamenesProximos();
        
        if (examenesProximos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.schedule_rounded, 
                    size: 64, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay exámenes próximos',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: examenesProximos.length,
          itemBuilder: (context, index) {
            final examen = examenesProximos[index];
            return _buildExamenCard(examen);
          },
        );
      },
    );
  }

  Widget _buildExamenesPendientes() {
    return Consumer<ExamenesProvider>(
      builder: (context, provider, child) {
        final examenesPendientes = provider.getExamenesPendientes();
        
        if (examenesPendientes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pending_rounded, 
                    size: 64, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay exámenes pendientes',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: examenesPendientes.length,
          itemBuilder: (context, index) {
            final examen = examenesPendientes[index];
            return _buildExamenCard(examen);
          },
        );
      },
    );
  }

  Widget _buildExamenesCalificados() {
    return Consumer<ExamenesProvider>(
      builder: (context, provider, child) {
        final examenesCalificados = provider.getExamenesCalificados();
        
        if (examenesCalificados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grade_rounded, 
                    size: 64, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay exámenes calificados',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: examenesCalificados.length,
          itemBuilder: (context, index) {
            final examen = examenesCalificados[index];
            return _buildExamenCard(examen);
          },
        );
      },
    );
  }

  Widget _buildExamenCard(Examen examen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  color: examen.colorEstado.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showExamenDetails(examen),
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        examen.colorEstado.withOpacity(0.8),
                        examen.colorEstado,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    examen.iconoEstado,
                    color: Colors.white,
                    size: 28,
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
                              examen.tipoEval?.value ?? 'Sin tipo',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (examen.estaProximo)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Próximo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        examen.materia?.nombre ?? 'Materia no disponible',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      if (examen.fechaEval != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                              size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(examen.fechaEval!),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (examen.notaEval != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.grade_rounded,
                              size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              'Nota: ${examen.notaFormateada}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (examen.ponderacionEval != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${examen.ponderacionFormateada}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    color: const Color(0xFF1A2634),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    elevation: 8,
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditExamenScreen(examen: examen),
                            ),
                          );
                          break;
                        case 'delete':
                          _showDeleteDialog(examen);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: AppColors.celeste, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Editar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.redAccent),
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
            ),
          ),
        ),
      ),
    );
  }

  void _showExamenDetails(Examen examen) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
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
                    color: AppColors.celeste.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
              ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con título centrado
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      examen.tipoEval?.value ?? 'Examen',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
        ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Contenido
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(Icons.book_rounded, 'Materia', 
                examen.materia?.nombre ?? 'No disponible'),
              _buildDetailRow(Icons.numbers_rounded, 'Código', 
                examen.materia?.codigo ?? 'No disponible'),
              if (examen.fechaEval != null)
                _buildDetailRow(Icons.calendar_today_rounded, 'Fecha', 
                  _formatDate(examen.fechaEval!)),
              if (examen.notaEval != null)
                _buildDetailRow(Icons.grade_rounded, 'Nota', 
                  examen.notaFormateada),
              if (examen.ponderacionEval != null)
                _buildDetailRow(Icons.percent_rounded, 'Ponderación', 
                  examen.ponderacionFormateada),
              _buildDetailRow(Icons.info_rounded, 'Estado', 
                examen.estadoFormateado),
            ],
          ),
        ),
                  ),
                  
                  // Botones centrados
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Botón Cerrar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: TextButton(
            onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
              'Cerrar',
              style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botón Editar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.celeste,
                                  AppColors.verdeAzulado,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.celeste.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditExamenScreen(examen: examen),
                ),
              );
            },
                              icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
              ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                    color: AppColors.celeste.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: AppColors.celeste,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                          color: Colors.white,
                    fontWeight: FontWeight.w500,
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

  void _showDeleteDialog(Examen examen) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Examen'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este examen de ${examen.materia?.nombre ?? 'la materia'}?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<ExamenesProvider>(context, listen: false);
              final success = await provider.deleteExamen(examen.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Examen eliminado exitosamente'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}