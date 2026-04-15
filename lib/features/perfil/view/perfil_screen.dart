import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_inicio.dart';
import '../../agendamiento/view/servicios_screen.dart';

class PerfilScreen extends StatefulWidget {
  final String uid; // uid del perfil a mostrar

  const PerfilScreen({super.key, required this.uid});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _descripcionController = TextEditingController();
  final _educacionController = TextEditingController();

  bool _educacionExpandida = false;
  bool _hayCambios = false;
  bool _esPropioPerfil = false;

  // Datos temporales (luego vendrán de Firestore)
  String _nombre = 'Julio Gomez';
  double _rating = 4.5;
  int _seguidores = 4400;

  @override
  void initState() {
    super.initState();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    _esPropioPerfil = currentUid == widget.uid;

    _descripcionController.text =
        'Guía Local con habilidades de escalamiento, 2 idiomas y lengua nativa.';
    _educacionController.text = '';

    _descripcionController.addListener(_onCampoEditado);
    _educacionController.addListener(_onCampoEditado);
  }

  void _onCampoEditado() {
    if (_esPropioPerfil) {
      setState(() => _hayCambios = true);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _educacionController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    // TODO: guardar en Firestore
    setState(() => _hayCambios = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado'),
        backgroundColor: AppColors.primary,
      ),
    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto de perfil
                  _buildFotoPerfil(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre + corazón + seguidores
                        _buildEncabezado(),

                        const SizedBox(height: 12),

                        // Estrellas
                        _buildEstrellas(),

                        const SizedBox(height: 16),

                        // Descripción
                        _buildDescripcion(),

                        const SizedBox(height: 16),

                        // Educación colapsable
                        _buildEducacion(),

                        const SizedBox(height: 24),

                        // Botones de acción
                        _buildBotones(),

                        // Botón guardar (solo si hay cambios)
                        if (_hayCambios) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _guardarCambios,
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Guardar cambios'),
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const BottomNavInicio(),
        ],
      ),
    );
  }

  // ── Foto de perfil ──────────────────────────────────
  Widget _buildFotoPerfil() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 260,
          color: AppColors.primaryLight,
          child: const Icon(Icons.person, size: 100, color: Colors.white),
        ),
        // Botón editar foto (solo guía en su propio perfil)
        if (_esPropioPerfil)
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                // TODO: seleccionar foto de galería
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  // ── Encabezado ──────────────────────────────────────
  Widget _buildEncabezado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            _nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const Icon(Icons.favorite, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          _seguidores >= 1000
              ? '${(_seguidores / 1000).toStringAsFixed(1)}k'
              : '$_seguidores',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Estrellas ───────────────────────────────────────
  Widget _buildEstrellas() {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < _rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        );
      }),
    );
  }

  // ── Descripción ─────────────────────────────────────
  Widget _buildDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _descripcionController,
          enabled: _esPropioPerfil,
          maxLines: 3,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Escribe una descripción de tu perfil...',
            filled: _esPropioPerfil,
            fillColor: _esPropioPerfil ? AppColors.surface : Colors.transparent,
            border: _esPropioPerfil
                ? OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                : InputBorder.none,
            enabledBorder: _esPropioPerfil
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  )
                : InputBorder.none,
            contentPadding: _esPropioPerfil
                ? const EdgeInsets.all(12)
                : EdgeInsets.zero,
            suffixIcon: _esPropioPerfil
                ? const Icon(Icons.edit, size: 16, color: AppColors.textHint)
                : null,
          ),
        ),
      ],
    );
  }

  // ── Educación colapsable ─────────────────────────────
  Widget _buildEducacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _educacionExpandida = !_educacionExpandida);
          },
          child: Row(
            children: [
              const Text(
                'Educación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Expanded(child: Divider(indent: 12, color: AppColors.border)),
              Icon(
                _educacionExpandida
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (_educacionExpandida) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _educacionController,
            enabled: _esPropioPerfil,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ej: Técnico en turismo - SENA, Guía certificado...',
              filled: _esPropioPerfil,
              fillColor: _esPropioPerfil ? AppColors.surface : Colors.transparent,
              border: _esPropioPerfil
                  ? OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                  : InputBorder.none,
              enabledBorder: _esPropioPerfil
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    )
                  : InputBorder.none,
              contentPadding: _esPropioPerfil
                  ? const EdgeInsets.all(12)
                  : EdgeInsets.zero,
              suffixIcon: _esPropioPerfil
                  ? const Icon(Icons.edit, size: 16, color: AppColors.textHint)
                  : null,
            ),
          ),
        ],
      ],
    );
  }

  // ── Botones de acción ────────────────────────────────
  Widget _buildBotones() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        _botonAccion(
          icono: Icons.room_service_outlined,
          etiqueta: 'Servicios',
          activo: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiciosScreen(
                  guiaUid: widget.uid,
                  guiaNombre: _nombre,
                  guiaUbicacion: 'Cauca, Colombia',
                ),
              ),
            );
          },
        ),
        _botonAccion(
          icono: Icons.star_outline,
          etiqueta: 'Calificar',
          activo: false,
          onTap: null,
        ),
        _botonAccion(
          icono: Icons.chat_bubble_outline,
          etiqueta: 'Chatear',
          activo: false,
          onTap: null,
        ),
        _botonAccion(
          icono: Icons.flag_outlined,
          etiqueta: 'Reportar',
          activo: false,
          onTap: null,
        ),
      ],
    );
  }

  Widget _botonAccion({
    required IconData icono,
    required String etiqueta,
    required bool activo,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: activo ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 18,
              color: activo ? Colors.white : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: activo ? Colors.white : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
