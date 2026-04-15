import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/auth_viewmodel.dart';

class CompletarRegistroScreen extends StatefulWidget {
  final String nombre;
  final String correo;
  // Si viene del formulario manual, trae contraseña. Si es Google, es null.
  final String? password;

  const CompletarRegistroScreen({
    super.key,
    required this.nombre,
    required this.correo,
    this.password,
  });

  @override
  State<CompletarRegistroScreen> createState() =>
      _CompletarRegistroScreenState();
}

class _CompletarRegistroScreenState extends State<CompletarRegistroScreen> {
  bool _isGuide = false;
  bool _aceptaTerminos = false;
  String? _error;

  bool get _esRegistroManual => widget.password != null;

  Future<void> _completar() async {
    setState(() => _error = null);

    if (!_aceptaTerminos) {
      setState(() => _error = 'Debes aceptar los términos y condiciones');
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    bool success;

    if (_esRegistroManual) {
      // Flujo manual: crea cuenta en Firebase Auth + guarda en Firestore
      success = await viewModel.register(
        widget.nombre,
        widget.correo,
        widget.password!,
        _isGuide,
      );
    } else {
      // Flujo Google: ya tiene la cuenta de Google lista, solo guarda en Firestore
      success = await viewModel.completarRegistroGoogle(_isGuide);
    }

    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (!success && mounted) {
      setState(() => _error = viewModel.errorMessage);
    }
  }

  void _mostrarTerminos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Términos, Condiciones y Política de Tratamiento de Datos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Habeas Data — Ley 1581 de 2012',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Al registrarte en RUMANKA, autorizas el tratamiento de tus datos personales '
                '(nombre, correo electrónico, ubicación y foto de perfil) para los fines del '
                'servicio: conectar turistas con guías locales del departamento del Cauca, Colombia.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 12),
              const Text(
                'Uso de la información',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Tus datos se usan exclusivamente para la operación de la plataforma.\n'
                '• No se comparten con terceros con fines comerciales.\n'
                '• Puedes solicitar la eliminación de tu cuenta en cualquier momento.\n'
                '• La información se almacena en servidores seguros de Google Firebase.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.7),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _aceptaTerminos = true);
                  Navigator.pop(context);
                },
                child: const Text('Entendido, acepto'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<AuthViewModel>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Ícono
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.primary, size: 48),
              ),

              const SizedBox(height: 24),

              const Text(
                '¡Casi listo!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Hola, ${widget.nombre}',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
              ),
              Text(
                widget.correo,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textHint),
              ),

              const SizedBox(height: 40),

              // Selector de rol
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Cómo quieres usar RUMANKA?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildOpcionRol(
                      icono: Icons.explore_outlined,
                      titulo: 'Soy Turista',
                      subtitulo: 'Quiero descubrir el Cauca',
                      seleccionado: !_isGuide,
                      onTap: () => setState(() => _isGuide = false),
                    ),

                    const SizedBox(height: 10),

                    _buildOpcionRol(
                      icono: Icons.hiking_outlined,
                      titulo: 'Soy Guía Turístico',
                      subtitulo: 'Quiero ofrecer mis servicios',
                      seleccionado: _isGuide,
                      onTap: () => setState(() => _isGuide = true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Términos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _aceptaTerminos,
                    onChanged: (v) =>
                        setState(() => _aceptaTerminos = v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5),
                        children: [
                          const TextSpan(text: 'Acepto los '),
                          TextSpan(
                            text: 'términos y condiciones',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _mostrarTerminos,
                          ),
                          const TextSpan(
                            text:
                                ' y el tratamiento de mis datos personales (Habeas Data)',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4EF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: isLoading ? null : _completar,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Completar registro'),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionRol({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? AppColors.primary : AppColors.border,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icono,
                color: seleccionado
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: seleccionado
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (seleccionado)
              Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
