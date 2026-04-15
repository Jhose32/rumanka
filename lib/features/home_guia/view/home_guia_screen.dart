import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../mapa/view/mapa_screen.dart';
import '../../perfil/view/perfil_screen.dart';

class HomeGuiaScreen extends StatefulWidget {
  const HomeGuiaScreen({super.key});

  @override
  State<HomeGuiaScreen> createState() => _HomeGuiaScreenState();
}

class _HomeGuiaScreenState extends State<HomeGuiaScreen> {
  int _carruselActual = 0;
  final PageController _pageController = PageController();

  // Datos temporales del carrusel
  final List<Map<String, String>> _ofertas = [
    {'titulo': 'Oferta del día', 'subtitulo': 'Temporada 4 Conexión\nAves de Nuestra Tierra'},
    {'titulo': 'Oferta del día', 'subtitulo': 'Ruta cultural\nPopayán histórico'},
    {'titulo': 'Oferta del día', 'subtitulo': 'Aventura natural\nParque Puracé'},
  ];

  // Datos temporales top guías
  final List<Map<String, dynamic>> _topGuias = [
    {
      'nombre': 'Gabriel Moreno',
      'ubicacion': 'Leticia, Colombia',
      'rating': 4.0,
      'reviews': 37,
    },
    {
      'nombre': 'María Torres',
      'ubicacion': 'Popayán, Colombia',
      'rating': 4.5,
      'reviews': 24,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nombre = user?.displayName ?? 'Guía';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(nombre),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Barra de búsqueda
                    _buildBuscador(),

                    const SizedBox(height: 20),

                    // Carrusel ofertas
                    _buildCarrusel(),

                    const SizedBox(height: 24),

                    // Botones Educación y Mapa
                    _buildMenuBotones(),

                    const SizedBox(height: 24),

                    // Top Guías
                    _buildTopGuias(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Barra inferior
            _buildBarraInferior(),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────
  Widget _buildHeader(String nombre) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar → toca para ver/editar tu perfil
          GestureDetector(
            onTap: () {
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilScreen(uid: uid)),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),

          // Bienvenido + nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Campana
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),

          // Cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
            },
          ),
        ],
      ),
    );
  }

  // ── Buscador ────────────────────────────────────────
  Widget _buildBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Buscar',
          prefixIcon: Icon(Icons.search, color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── Carrusel ─────────────────────────────────────────
  Widget _buildCarrusel() {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _ofertas.length,
            onPageChanged: (index) {
              setState(() => _carruselActual = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _ofertas[index]['titulo']!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ofertas[index]['subtitulo']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Indicadores del carrusel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _ofertas.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _carruselActual == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _carruselActual == index
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Botones Menú ─────────────────────────────────────
  Widget _buildMenuBotones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _botonMenu(
          icono: Icons.school_outlined,
          etiqueta: 'Educación',
          onTap: () {
            // TODO: navegar a Educación
          },
        ),
        const SizedBox(width: 40),
        _botonMenu(
          icono: Icons.map_outlined,
          etiqueta: 'Mapa',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapaScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _botonMenu({
    required IconData icono,
    required String etiqueta,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icono, size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Guías ────────────────────────────────────────
  Widget _buildTopGuias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top guía',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._topGuias.map((guia) => _tarjetaGuia(guia)),
      ],
    );
  }

  Widget _tarjetaGuia(Map<String, dynamic> guia) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PerfilScreen(uid: guia['uid'] ?? ''),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.primaryLight,
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guia['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guia['ubicacion'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${guia['rating']} (${guia['reviews']} Reseñas)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ── Barra inferior ───────────────────────────────────
  Widget _buildBarraInferior() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.primary, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
