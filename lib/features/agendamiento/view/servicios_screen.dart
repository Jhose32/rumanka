import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_inicio.dart';
import 'fechas_screen.dart';

class ServiciosScreen extends StatefulWidget {
  final String guiaUid;
  final String guiaNombre;
  final String guiaUbicacion;

  const ServiciosScreen({
    super.key,
    required this.guiaUid,
    required this.guiaNombre,
    required this.guiaUbicacion,
  });

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _servicioSeleccionado = 0;

  // Servicios temporales (luego vendrán de Firestore)
  final List<Map<String, dynamic>> _servicios = [
    {'nombre': 'Escalamiento', 'precio': 30.0},
    {'nombre': 'Trekking',     'precio': 15.0},
    {'nombre': 'Combo 1',      'precio': 20.0},
    {'nombre': 'Combo 2',      'precio': 45.0},
    {'nombre': 'Combo 3',      'precio': 20.0},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Foto + nombre + ubicación
                  _buildHeader(),

                  // Tabs
                  _buildTabs(),

                  // Contenido del tab
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildServicios(),
                        _buildInformacion(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón Agendar
          _buildBotonAgendar(),

          const BottomNavInicio(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────
  Widget _buildHeader() {
    return Stack(
      children: [
        // Foto del guía
        Container(
          width: double.infinity,
          height: 220,
          color: AppColors.primaryLight,
          child: const Icon(Icons.person, size: 80, color: Colors.white),
        ),

        // Gradiente para texto legible
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Nombre y ubicación
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.guiaNombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    widget.guiaUbicacion,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Botón volver
        Positioned(
          top: 40,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tabs ────────────────────────────────────────────
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      tabs: const [
        Tab(text: 'Servicios'),
        Tab(text: 'Información'),
      ],
    );
  }

  // ── Lista de Servicios ───────────────────────────────
  Widget _buildServicios() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _servicios.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, index) {
        final servicio = _servicios[index];
        final seleccionado = _servicioSeleccionado == index;
        return InkWell(
          onTap: () => setState(() => _servicioSeleccionado = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    servicio['nombre'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '\$${servicio['precio'].toInt()}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: seleccionado ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: seleccionado ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    color: seleccionado ? AppColors.primary : Colors.transparent,
                  ),
                  child: seleccionado
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Información ─────────────────────────────────────
  Widget _buildInformacion() {
    return const Center(
      child: Text(
        'Información del guía\n(próximamente)',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  // ── Botón Agendar ────────────────────────────────────
  Widget _buildBotonAgendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ElevatedButton(
        onPressed: () {
          final servicio = _servicios[_servicioSeleccionado];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FechasScreen(
                guiaUid: widget.guiaUid,
                guiaNombre: widget.guiaNombre,
                guiaUbicacion: widget.guiaUbicacion,
                servicioNombre: servicio['nombre'],
                servicioPrecio: servicio['precio'],
              ),
            ),
          );
        },
        child: const Text('Agendar'),
      ),
    );
  }
}
