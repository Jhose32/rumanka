import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_inicio.dart';

class FechasScreen extends StatefulWidget {
  final String guiaUid;
  final String guiaNombre;
  final String guiaUbicacion;
  final String servicioNombre;
  final double servicioPrecio;

  const FechasScreen({
    super.key,
    required this.guiaUid,
    required this.guiaNombre,
    required this.guiaUbicacion,
    required this.servicioNombre,
    required this.servicioPrecio,
  });

  @override
  State<FechasScreen> createState() => _FechasScreenState();
}

class _FechasScreenState extends State<FechasScreen> {
  int _adultos = 1;
  DateTime _mesActual = DateTime.now();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _bannerActual = 0;
  final PageController _bannerController = PageController();

  // Fotos temporales del banner (luego vendrán de Firestore)
  final List<Color> _coloresBanner = [
    const Color(0xFF4A9B8E),
    const Color(0xFF2D7A6E),
    const Color(0xFF7ABDB5),
  ];

  final List<String> _textosBanner = [
    'Aventura en el Cauca',
    'Naturaleza y cultura',
    'Experiencias únicas',
  ];

  double get _totalPrecio =>
      widget.servicioPrecio * _adultos * (_diasSeleccionados > 0 ? _diasSeleccionados : 1);

  int get _diasSeleccionados {
    if (_fechaInicio == null || _fechaFin == null) return 0;
    return _fechaFin!.difference(_fechaInicio!).inDays + 1;
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  bool _esFechaSeleccionada(DateTime dia) {
    if (_fechaInicio == null) return false;
    if (_fechaFin == null) return dia == _fechaInicio;
    return (dia.isAtSameMomentAs(_fechaInicio!) ||
            dia.isAtSameMomentAs(_fechaFin!) ||
            (dia.isAfter(_fechaInicio!) && dia.isBefore(_fechaFin!)));
  }

  bool _esFechaInicio(DateTime dia) =>
      _fechaInicio != null && dia.isAtSameMomentAs(_fechaInicio!);

  bool _esFechaFin(DateTime dia) =>
      _fechaFin != null && dia.isAtSameMomentAs(_fechaFin!);

  void _seleccionarFecha(DateTime dia) {
    if (dia.isBefore(DateTime.now().subtract(const Duration(days: 1)))) return;
    setState(() {
      if (_fechaInicio == null || (_fechaInicio != null && _fechaFin != null)) {
        _fechaInicio = dia;
        _fechaFin = null;
      } else {
        if (dia.isBefore(_fechaInicio!)) {
          _fechaFin = _fechaInicio;
          _fechaInicio = dia;
        } else {
          _fechaFin = dia;
        }
      }
    });
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
                  // Banner carrusel
                  _buildBanner(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ubicación + botón volver
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.guiaUbicacion,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Selector adultos
                        _buildSelectorAdultos(),

                        const SizedBox(height: 20),

                        // Servicio seleccionado
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.room_service_outlined,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                widget.servicioNombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '\$${widget.servicioPrecio.toInt()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Título calendario
                        const Text(
                          'Selecciona Fechas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Calendario
                        _buildCalendario(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total + Reservar
          _buildBarraReservar(),

          const BottomNavInicio(),
        ],
      ),
    );
  }

  // ── Banner carrusel ──────────────────────────────────
  Widget _buildBanner() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _coloresBanner.length,
            onPageChanged: (i) => setState(() => _bannerActual = i),
            itemBuilder: (context, index) {
              return Container(
                color: _coloresBanner[index],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.landscape, color: Colors.white54, size: 60),
                      const SizedBox(height: 8),
                      Text(
                        _textosBanner[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Indicadores
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _coloresBanner.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _bannerActual == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _bannerActual == i
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Selector adultos ─────────────────────────────────
  Widget _buildSelectorAdultos() {
    return Row(
      children: [
        const Text(
          'Adultos',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            if (_adultos > 1) setState(() => _adultos--);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$_adultos',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _adultos++),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Decoración de cada día del calendario ────────────
  BoxDecoration _decoracionDia({
    required bool seleccionado,
    required bool esInicio,
    required bool esFin,
    required DateTime dia,
  }) {
    if (!seleccionado) {
      return const BoxDecoration(color: Colors.transparent);
    }

    // Solo fecha inicio seleccionada (sin rango) → círculo
    final bool esCirculo = (esInicio || esFin) && _fechaFin == null;
    if (esCirculo) {
      return BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      );
    }

    // Rango seleccionado → rectángulo con esquinas redondeadas solo en extremos
    return BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.horizontal(
        left: esInicio || (seleccionado && !esInicio && !esFin && dia.weekday == 7)
            ? const Radius.circular(20)
            : Radius.zero,
        right: esFin || (seleccionado && !esInicio && !esFin && dia.weekday == 6)
            ? const Radius.circular(20)
            : Radius.zero,
      ),
    );
  }

  // ── Calendario ───────────────────────────────────────
  Widget _buildCalendario() {
    final diasEnMes =
        DateUtils.getDaysInMonth(_mesActual.year, _mesActual.month);
    final primerDia = DateTime(_mesActual.year, _mesActual.month, 1);
    final offsetInicio = primerDia.weekday % 7;

    const diasSemana = ['DOM', 'LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB'];
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Navegación mes
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_mesActual.year}',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _mesActual =
                      DateTime(_mesActual.year, _mesActual.month - 1);
                }),
                child: const Icon(Icons.chevron_left, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                meses[_mesActual.month - 1],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _mesActual =
                      DateTime(_mesActual.year, _mesActual.month + 1);
                }),
                child: const Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Días de la semana
          Row(
            children: diasSemana.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Días del mes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: offsetInicio + diasEnMes,
            itemBuilder: (context, index) {
              if (index < offsetInicio) return const SizedBox();
              final dia = DateTime(
                _mesActual.year,
                _mesActual.month,
                index - offsetInicio + 1,
              );
              final pasado = dia.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)));
              final seleccionado = _esFechaSeleccionada(dia);
              final esInicio = _esFechaInicio(dia);
              final esFin = _esFechaFin(dia);

              return GestureDetector(
                onTap: pasado ? null : () => _seleccionarFecha(dia),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: _decoracionDia(
                    seleccionado: seleccionado,
                    esInicio: esInicio,
                    esFin: esFin,
                    dia: dia,
                  ),
                  child: Center(
                    child: Text(
                      '${dia.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                        color: pasado
                            ? AppColors.textHint
                            : seleccionado
                                ? Colors.white
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Barra Reservar ───────────────────────────────────
  Widget _buildBarraReservar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Precio',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                '\$${_totalPrecio.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Icon(Icons.calendar_today_outlined,
              color: AppColors.primary, size: 22),
          const Spacer(),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: _fechaInicio == null
                  ? null
                  : () {
                      // TODO: confirmar reserva y guardar en Firestore
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Reserva realizada con éxito!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
              child: const Text('Reservar'),
            ),
          ),
        ],
      ),
    );
  }
}
