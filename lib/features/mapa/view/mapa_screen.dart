import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/municipios_cauca.dart';
import '../../../shared/widgets/bottom_nav_inicio.dart';
import '../../perfil/view/perfil_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 1; // 1 = Mapa activo por defecto

  final List<Map<String, dynamic>> _guias = [
    {'nombre': 'Gabriel Moreno',  'municipio': 'Popayán',         'lat': 2.4448,  'lng': -76.6147, 'rating': 4.0},
    {'nombre': 'María Torres',    'municipio': 'Silvia',           'lat': 2.6167,  'lng': -76.3833, 'rating': 4.5},
    {'nombre': 'Carlos Muñoz',    'municipio': 'Timbío',           'lat': 2.3536,  'lng': -76.6814, 'rating': 3.8},
    {'nombre': 'Luz Mestizo',     'municipio': 'Santander de Q.',  'lat': 2.8564,  'lng': -76.4822, 'rating': 4.2},
  ];

  List<Map<String, dynamic>> _guiasFiltrados = [];

  @override
  void initState() {
    super.initState();
    _guiasFiltrados = _guias;
  }

  void _filtrarGuias(String query) {
    setState(() {
      _guiasFiltrados = query.isEmpty
          ? _guias
          : _guias.where((g) {
              return g['nombre'].toLowerCase().contains(query.toLowerCase()) ||
                  g['municipio'].toLowerCase().contains(query.toLowerCase());
            }).toList();
    });
  }

  void _verPerfilGuia(Map<String, dynamic> guia) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _bottomSheetGuia(guia),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────
            _buildTopBar(),

            // ── Mapa ───────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: MunicipiosCauca.centroCauca,
                      initialZoom: 9.0,
                      minZoom: 8.5,
                      maxZoom: 14.0,
                      cameraConstraint: CameraConstraint.containCenter(
                        bounds: LatLngBounds(
                          const LatLng(0.7, -77.9),
                          const LatLng(3.4, -75.9),
                        ),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.rumanka.app_rumanka',
                      ),
                      MarkerLayer(
                        markers: _guiasFiltrados.map((guia) {
                          return Marker(
                            point: LatLng(guia['lat'], guia['lng']),
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () => _verPerfilGuia(guia),
                              child: _marcadorGuia(),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // Botón centrar
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: Colors.white,
                      onPressed: () =>
                          _mapController.move(MunicipiosCauca.centroCauca, 9.0),
                      child: const Icon(Icons.my_location, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Nav ─────────────────────────────
            const BottomNavInicio(),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Barra de búsqueda
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filtrarGuias,
                decoration: InputDecoration(
                  hintText: 'Municipio o guía...',
                  hintStyle: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textHint, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filtrarGuias('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar perfil
          GestureDetector(
            onTap: () {
              // TODO: navegar a perfil
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _marcadorGuia() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 26),
    );
  }

  Widget _bottomSheetGuia(Map<String, dynamic> guia) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guia['nombre'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(guia['municipio'],
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${guia['rating']}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PerfilScreen(uid: guia['uid'] ?? ''),
                ),
              );
            },
            child: const Text('Ver perfil y agendar'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
