import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/barber_dashboard/barber_dashboard_cubit.dart';
import '../../cubit/barber_dashboard/barber_dashboard_state.dart';

class BarberDashboardScreen extends StatefulWidget {
  final String barberId;

  const BarberDashboardScreen({super.key, required this.barberId});

  @override
  State<BarberDashboardScreen> createState() => _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends State<BarberDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BarberDashboardCubit>().loadDashboard(widget.barberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text(
          'Mi Analítica',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => context.read<BarberDashboardCubit>().loadDashboard(
              widget.barberId,
            ),
          ),
        ],
      ),
      body: BlocBuilder<BarberDashboardCubit, BarberDashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: const Color(0xFFD4AF37),
            backgroundColor: const Color(0xFF1A1A1A),
            onRefresh: () => context.read<BarberDashboardCubit>().loadDashboard(
              widget.barberId,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                const SizedBox(height: 12),
                // ── Period selector ──────────────────────────────────
                _PeriodSelector(barberId: widget.barberId, state: state),
                const SizedBox(height: 20),

                // ── Today section (only when TODAY period) ──────────
                if (state.period == DashboardPeriod.today) ...[
                  _SectionHeader(icon: Icons.today_rounded, label: 'Hoy'),
                  const SizedBox(height: 12),
                  _DailySummaryCard(state: state, barberId: widget.barberId),
                  const SizedBox(height: 24),
                ],

                // ── Monthly summary ──────────────────────────────────
                _SectionHeader(
                  icon: Icons.bar_chart_rounded,
                  label: 'Resumen mensual',
                ),
                const SizedBox(height: 12),
                _MonthlySummaryCard(state: state),
                const SizedBox(height: 24),

                // ── Revenue chart ────────────────────────────────────
                _SectionHeader(
                  icon: Icons.show_chart_rounded,
                  label: 'Evolución de ingresos',
                ),
                const SizedBox(height: 12),
                _RevenueChartCard(state: state),
                const SizedBox(height: 24),

                // ── Revenue by weekday ────────────────────────────────
                _SectionHeader(
                  icon: Icons.calendar_view_week_rounded,
                  label: 'Ingresos por día de semana',
                ),
                const SizedBox(height: 12),
                _WeekdayRevenueCard(state: state),
                const SizedBox(height: 24),

                // ── Top services ─────────────────────────────────────
                _SectionHeader(
                  icon: Icons.content_cut_rounded,
                  label: 'Servicios más vendidos',
                ),
                const SizedBox(height: 12),
                _TopServicesCard(state: state),
                const SizedBox(height: 24),

                // ── Clients ──────────────────────────────────────────
                _SectionHeader(icon: Icons.people_rounded, label: 'Clientes'),
                const SizedBox(height: 12),
                _ClientStatsCard(state: state),
                const SizedBox(height: 24),

                // ── At-risk clients ──────────────────────────────────
                if (state.clientStats != null &&
                    state.clientStats!.atRiskClients.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.warning_amber_rounded,
                    label: 'Clientes en riesgo de fuga',
                  ),
                  const SizedBox(height: 12),
                  _AtRiskClientsCard(state: state),
                  const SizedBox(height: 24),
                ],

                // ── Top clients ──────────────────────────────────────
                _SectionHeader(icon: Icons.star_rounded, label: 'Top clientes'),
                const SizedBox(height: 12),
                _TopClientsCard(state: state),
                const SizedBox(height: 24),

                // ── Payment methods ──────────────────────────────────
                _SectionHeader(
                  icon: Icons.payment_rounded,
                  label: 'Métodos de pago',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.push('/barber-dashboard/${widget.barberId}/payment-methods'),
                    icon: const Icon(Icons.manage_accounts_rounded, color: Color(0xFFD4AF37)),
                    label: const Text(
                      'Gestionar métodos',
                      style: TextStyle(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
                _PaymentMethodsCard(state: state),
                const SizedBox(height: 24),

                // ── Promotions ───────────────────────────────────────
                _SectionHeader(
                  icon: Icons.local_offer_rounded,
                  label: 'Promociones',
                ),
                const SizedBox(height: 12),
                _PromotionsCard(state: state),
                const SizedBox(height: 24),

                // ── Profile views ────────────────────────────────────
                _SectionHeader(
                  icon: Icons.remove_red_eye_rounded,
                  label: 'Vistas de perfil (últimos 30 días)',
                ),
                const SizedBox(height: 12),
                _ProfileViewsCard(state: state),
                const SizedBox(height: 24),

                // ── Peak hours ───────────────────────────────────────
                _SectionHeader(
                  icon: Icons.schedule_rounded,
                  label: 'Horarios pico',
                ),
                const SizedBox(height: 12),
                _PeakHoursCard(state: state),
                const SizedBox(height: 24),

                // ── Rating trend ─────────────────────────────────────
                _SectionHeader(
                  icon: Icons.trending_up_rounded,
                  label: 'Evolución del rating',
                ),
                const SizedBox(height: 12),
                _RatingTrendCard(state: state),
                const SizedBox(height: 24),

                // ── Review distribution ──────────────────────────────
                _SectionHeader(
                  icon: Icons.star_half_rounded,
                  label: 'Distribución de reseñas',
                ),
                const SizedBox(height: 12),
                _ReviewDistributionCard(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Period + Date Selector ───────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final String barberId;
  final BarberDashboardState state;

  const _PeriodSelector({required this.barberId, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BarberDashboardCubit>();
    return Column(
      children: [
        // ── Tab row ──────────────────────────────────────────────────
        Row(
          children: [
            _PeriodTab(
              label: 'Hoy',
              icon: Icons.today_rounded,
              isSelected: state.period == DashboardPeriod.today,
              onTap: () => cubit.setPeriod(barberId, DashboardPeriod.today),
            ),
            const SizedBox(width: 8),
            _PeriodTab(
              label: 'Mensual',
              icon: Icons.calendar_month_rounded,
              isSelected: state.period == DashboardPeriod.month,
              onTap: () => cubit.setPeriod(barberId, DashboardPeriod.month),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Date navigation row ─────────────────────────────────────
        if (state.period == DashboardPeriod.today)
          _DayNavigator(barberId: barberId, state: state)
        else
          _MonthNavigator(barberId: barberId, state: state),
      ],
    );
  }
}

/// Navegación por días: ← DD/MM/YYYY →
class _DayNavigator extends StatelessWidget {
  final String barberId;
  final BarberDashboardState state;
  const _DayNavigator({required this.barberId, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BarberDashboardCubit>();
    final d = state.selectedDate;
    final isToday = state.isToday;
    final label = isToday ? 'Hoy, ${_fmt(d)}' : _fmtFull(d);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => cubit.previousDay(barberId),
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: d,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFD4AF37),
                      onPrimary: Colors.black,
                      surface: Color(0xFF1A1A1A),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) cubit.setDay(barberId, picked);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFD4AF37),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isToday ? null : () => cubit.nextDay(barberId),
            icon: Icon(
              Icons.chevron_right,
              color: isToday ? Colors.white24 : Colors.white70,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  static const _months = [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];
  static const _days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  String _fmt(DateTime d) => '${d.day} ${_months[d.month]}';

  String _fmtFull(DateTime d) =>
      '${_days[d.weekday]}, ${d.day} ${_months[d.month]} ${d.year}';
}

/// Navegación por meses: ← Marzo 2025 →
class _MonthNavigator extends StatelessWidget {
  final String barberId;
  final BarberDashboardState state;
  const _MonthNavigator({required this.barberId, required this.state});

  static const _months = [
    '',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BarberDashboardCubit>();
    final now = DateTime.now();
    final isCurrentMonth =
        state.selectedMonth == now.month && state.selectedYear == now.year;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => cubit.previousMonth(barberId),
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month,
                color: Color(0xFFD4AF37),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${_months[state.selectedMonth]} ${state.selectedYear}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : () => cubit.nextMonth(barberId),
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth ? Colors.white24 : Colors.white70,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF2C2C2C),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : Colors.white60,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _DashCard extends StatelessWidget {
  final Widget child;

  const _DashCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2C)),
      ),
      child: child,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

Widget _statBox(String label, String value, {Color valueColor = Colors.white}) {
  return Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _divider() =>
    Container(width: 1, height: 40, color: const Color(0xFF2C2C2C));

// ─── Daily Summary ────────────────────────────────────────────────────────────

class _DailySummaryCard extends StatelessWidget {
  final BarberDashboardState state;
  final String barberId;
  const _DailySummaryCard({required this.state, required this.barberId});

  @override
  Widget build(BuildContext context) {
    if (state.isDailyLoading) return const _LoadingCard();
    final d = state.dailySummary;
    if (d == null)
      return const _DashCard(
        child: Text(
          'Sin datos del día',
          style: TextStyle(color: Colors.white54),
        ),
      );

    return _DashCard(
      child: Column(
        children: [
          Row(
            children: [
              _statBox('Total citas', '${d.totalAppointments}'),
              _divider(),
              _statBox(
                'Completadas',
                '${d.completed}',
                valueColor: const Color(0xFF4CAF50),
              ),
              _divider(),
              _statBox(
                'Canceladas',
                '${d.cancelled}',
                valueColor: const Color(0xFFE53935),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 24),
          Row(
            children: [
              _statBox(
                'Ingresos',
                '\$${d.revenue.toStringAsFixed(2)}',
                valueColor: const Color(0xFFD4AF37),
              ),
              _divider(),
              _statBox('Ticket prom.', '\$${d.avgTicket.toStringAsFixed(2)}'),
            ],
          ),
          // ── "Ver citas" button ────────────────────────────────
          if (d.appointments.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAppointmentsSheet(context, d),
                icon: const Icon(
                  Icons.format_list_bulleted_rounded,
                  size: 16,
                  color: Color(0xFFD4AF37),
                ),
                label: Text(
                  'Ver ${d.appointments.length} citas del día',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAppointmentsSheet(BuildContext context, dynamic d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentsBottomSheet(dailySummary: d),
    );
  }
}

// ─── Appointments Bottom Sheet ────────────────────────────────────────────────

class _AppointmentsBottomSheet extends StatelessWidget {
  final dynamic dailySummary; // DailySummaryEntity
  const _AppointmentsBottomSheet({required this.dailySummary});

  @override
  Widget build(BuildContext context) {
    final appointments = dailySummary.appointments as List;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3C3C3C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Citas del día',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          dailySummary.date,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Summary chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${dailySummary.revenue.toStringAsFixed(0)} total',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2C2C2C), height: 1),
            // List
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: appointments.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFF2C2C2C), height: 16),
                itemBuilder: (_, i) {
                  final a = appointments[i];
                  final status = (a.status as String).toUpperCase();
                  final statusColor = _statusColor(status);
                  final statusLabel = _statusLabel(status);
                  final price = a.servicePrice as double?;
                  final discount = _extractDiscount(a);
                  final appointmentId = a.id as String;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(); // cierra el sheet
                        context.push('/appointment/$appointmentId');
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: const Color(
                        0xFFD4AF37,
                      ).withValues(alpha: 0.08),
                      highlightColor: const Color(
                        0xFFD4AF37,
                      ).withValues(alpha: 0.04),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(color: statusColor, width: 3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: time + status badge
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white54,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  a.time,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white24,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Row 2: client
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.white38,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    a.clientName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (a.serviceName != null) ...[
                              const SizedBox(height: 6),
                              // Row 3: service + price
                              Row(
                                children: [
                                  const Icon(
                                    Icons.content_cut,
                                    color: Colors.white38,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      a.serviceName!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (price != null)
                                    Text(
                                      '\$${price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            if (discount != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_offer,
                                    color: Color(0xFF4CAF50),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${discount.label}: -\$${discount.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'COMPLETED':
        return const Color(0xFF4CAF50);
      case 'CANCELLED':
        return const Color(0xFFE53935);
      case 'CONFIRMED':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'COMPLETED':
        return 'Completada';
      case 'CANCELLED':
        return 'Cancelada';
      case 'CONFIRMED':
        return 'Confirmada';
      case 'PENDING':
        return 'Pendiente';
      default:
        return s;
    }
  }

  _DiscountInfo? _extractDiscount(dynamic a) {
    return null;
  }
}

class _DiscountInfo {
  final String label;
  final double amount;
  const _DiscountInfo({required this.label, required this.amount});
}

class _MonthlySummaryCard extends StatelessWidget {
  final BarberDashboardState state;
  const _MonthlySummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isMonthlyLoading) return const _LoadingCard(height: 120);
    final m = state.monthlySummary;
    if (m == null)
      return const _DashCard(
        child: Text(
          'Sin datos mensuales',
          style: TextStyle(color: Colors.white54),
        ),
      );

    final grow = m.revenueVsPrevMonth;
    final growColor = (grow ?? 0) >= 0
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);
    final growIcon = (grow ?? 0) >= 0 ? '▲' : '▼';

    return _DashCard(
      child: Column(
        children: [
          Row(
            children: [
              _statBox('Citas', '${m.totalAppointments}'),
              _divider(),
              _statBox(
                'Completadas',
                '${m.completed}',
                valueColor: const Color(0xFF4CAF50),
              ),
              _divider(),
              _statBox(
                '% Canc.',
                '${m.cancellationRate}%',
                valueColor: const Color(0xFFE53935),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 24),
          Row(
            children: [
              _statBox(
                'Ingresos',
                '\$${m.revenue.toStringAsFixed(2)}',
                valueColor: const Color(0xFFD4AF37),
              ),
              _divider(),
              _statBox('Ticket prom.', '\$${m.avgTicket.toStringAsFixed(2)}'),
              _divider(),
              _statBox('Ocupación', '${m.occupancyRate}%'),
            ],
          ),
          if (grow != null || m.projectedRevenue != null) ...[
            const Divider(color: Color(0xFF2C2C2C), height: 24),
            Row(
              children: [
                if (grow != null)
                  Expanded(
                    child: _InsightChip(
                      label: 'vs mes anterior',
                      value: '$growIcon ${grow.abs()}%',
                      color: growColor,
                    ),
                  ),
                if (m.projectedRevenue != null)
                  Expanded(
                    child: _InsightChip(
                      label: 'Proyección mes',
                      value: '\$${m.projectedRevenue!.toStringAsFixed(0)}',
                      color: const Color(0xFF9C27B0),
                    ),
                  ),
                if (m.soldOutDays > 0)
                  Expanded(
                    child: _InsightChip(
                      label: 'Días full',
                      value: '${m.soldOutDays}',
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InsightChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Revenue Chart (simple bar chart without external lib) ─────────────────────

class _RevenueChartCard extends StatelessWidget {
  final BarberDashboardState state;
  const _RevenueChartCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isRevenueChartLoading) return const _LoadingCard(height: 160);
    if (state.revenueChart.isEmpty) {
      return const _DashCard(
        child: Text(
          'Sin datos de ingresos',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final points = state.revenueChart;
    final maxRevenue = points
        .map((p) => p.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    if (maxRevenue == 0) {
      return const _DashCard(
        child: Text(
          'Sin ingresos registrados',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Show only last 6 points for monthly view
    final display = points.length > 6
        ? points.sublist(points.length - 6)
        : points;

    return _DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: display.map((p) {
                final ratio = maxRevenue > 0 ? p.revenue / maxRevenue : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (p.revenue > 0)
                          Text(
                            p.revenue >= 1000
                                ? '\$${(p.revenue / 1000).toStringAsFixed(1)}k'
                                : '\$${p.revenue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          height: 100 * ratio,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: display.map((p) {
              return Expanded(
                child: Text(
                  p.label.split(' ').first, // Show only day/month name
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Weekday Revenue ──────────────────────────────────────────────────────────

class _WeekdayRevenueCard extends StatelessWidget {
  final BarberDashboardState state;
  const _WeekdayRevenueCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isWeekdayRevenueLoading) return const _LoadingCard(height: 100);
    if (state.weekdayRevenue.isEmpty) {
      return const _DashCard(
        child: Text('Sin datos', style: TextStyle(color: Colors.white54)),
      );
    }

    final maxRev = state.weekdayRevenue
        .map((e) => e.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return _DashCard(
      child: Column(
        children: state.weekdayRevenue.map((d) {
          final ratio = maxRev > 0 ? d.revenue / maxRev : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    d.dayName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    '\$${d.revenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Top Services ─────────────────────────────────────────────────────────────

class _TopServicesCard extends StatelessWidget {
  final BarberDashboardState state;
  const _TopServicesCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isTopServicesLoading) return const _LoadingCard(height: 120);
    if (state.topServices.isEmpty) {
      return const _DashCard(
        child: Text(
          'Sin servicios registrados',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return _DashCard(
      child: Column(
        children: state.topServices.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          const gold = Color(0xFFD4AF37);
          const rankColors = [gold, Colors.white70, Color(0xFFCD7F32)];
          final rankColor = i < 3 ? rankColors[i] : Colors.white38;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rankColor.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.serviceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: s.percentage / 100,
                        backgroundColor: const Color(0xFF2C2C2C),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rankColor.withOpacity(0.7),
                        ),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${s.count}x',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${s.revenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Client Stats (donut-like summary) ────────────────────────────────────────

class _ClientStatsCard extends StatelessWidget {
  final BarberDashboardState state;
  const _ClientStatsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isClientsLoading) return const _LoadingCard(height: 120);
    final c = state.clientStats;
    if (c == null)
      return const _DashCard(
        child: Text(
          'Sin datos de clientes',
          style: TextStyle(color: Colors.white54),
        ),
      );

    return _DashCard(
      child: Column(
        children: [
          Row(
            children: [
              _ClientChip(
                icon: Icons.person_add_rounded,
                label: 'Nuevos',
                value: '${c.newClients}',
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(width: 8),
              _ClientChip(
                icon: Icons.favorite_rounded,
                label: 'Fieles',
                value: '${c.loyalClients}',
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              _ClientChip(
                icon: Icons.people_rounded,
                label: 'Total únicos',
                value: '${c.totalUniqueClients}',
                color: const Color(0xFFD4AF37),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 20),
          Row(
            children: [
              if (c.conversionRate != null)
                Expanded(
                  child: _InsightChip(
                    label: 'Tasa retención',
                    value: '${c.conversionRate}%',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              if (c.avgRevisitDays != null)
                Expanded(
                  child: _InsightChip(
                    label: 'Revisita cada',
                    value: '${c.avgRevisitDays?.toStringAsFixed(0)} días',
                    color: const Color(0xFF9C27B0),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ClientChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── At-risk clients ──────────────────────────────────────────────────────────

class _AtRiskClientsCard extends StatelessWidget {
  final BarberDashboardState state;
  const _AtRiskClientsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final clients = state.clientStats?.atRiskClients ?? [];
    return _DashCard(
      child: Column(
        children: clients
            .take(5)
            .map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE53935).withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.person_off_rounded,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.clientName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${c.totalVisits} visitas · última: ${c.lastVisit}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${c.daysSinceLastVisit}d',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Top Clients ──────────────────────────────────────────────────────────────

class _TopClientsCard extends StatelessWidget {
  final BarberDashboardState state;
  const _TopClientsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isClientsLoading) return const _LoadingCard(height: 100);
    final clients = state.clientStats?.topClients ?? [];
    if (clients.isEmpty) {
      return const _DashCard(
        child: Text(
          'Sin clientes frecuentes aún',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return _DashCard(
      child: Column(
        children: clients.asMap().entries.map((e) {
          final i = e.key;
          final c = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(
                  '#${i + 1}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.clientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Última visita: ${c.lastVisit}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${c.totalVisits} citas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${c.totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Payment Methods ──────────────────────────────────────────────────────────

class _PaymentMethodsCard extends StatelessWidget {
  final BarberDashboardState state;
  const _PaymentMethodsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isPaymentMethodsLoading) return const _LoadingCard(height: 80);
    if (state.paymentMethods.isEmpty) {
      return const _DashCard(
        child: Text(
          'Sin datos de pagos',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return _DashCard(
      child: Column(
        children: state.paymentMethods
            .map(
              (pm) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pm.paymentMethod,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: pm.percentage / 100,
                            backgroundColor: const Color(0xFF2C2C2C),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD4AF37),
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${pm.count}x',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '\$${pm.revenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Promotions ───────────────────────────────────────────────────────────────

class _PromotionsCard extends StatelessWidget {
  final BarberDashboardState state;
  const _PromotionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isPromotionsLoading) return const _LoadingCard(height: 80);
    if (state.promotionStats.isEmpty) {
      return const _DashCard(
        child: Text(
          'Sin promociones creadas',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return _DashCard(
      child: Column(
        children: state.promotionStats
            .map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.isActive
                            ? const Color(0xFF4CAF50).withOpacity(0.15)
                            : const Color(0xFF2C2C2C),
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: p.isActive
                            ? const Color(0xFF4CAF50)
                            : Colors.white38,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Código: ${p.code}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${p.validFrom} → ${p.validUntil}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${p.usageCount}',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Text(
                          'usos',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Profile Views ────────────────────────────────────────────────────────────

class _ProfileViewsCard extends StatelessWidget {
  final BarberDashboardState state;
  const _ProfileViewsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isProfileViewsLoading) return const _LoadingCard(height: 80);
    final pv = state.profileViews;
    if (pv == null)
      return const _DashCard(
        child: Text(
          'Sin datos de vistas',
          style: TextStyle(color: Colors.white54),
        ),
      );

    // Sparkline (last 14 days)
    final days = pv.dailyViews.length > 14
        ? pv.dailyViews.sublist(pv.dailyViews.length - 14)
        : pv.dailyViews;
    final maxViews = days
        .map((d) => d.count)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return _DashCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.remove_red_eye_rounded,
                color: Color(0xFFD4AF37),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '${pv.totalViews}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'vistas',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
          if (days.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((d) {
                  final ratio = maxViews > 0 ? d.count / maxViews : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 30 * ratio + (d.count > 0 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Peak Hours ───────────────────────────────────────────────────────────────

class _PeakHoursCard extends StatelessWidget {
  final BarberDashboardState state;
  const _PeakHoursCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isPeakHoursLoading) return const _LoadingCard(height: 80);
    if (state.peakHours.isEmpty) {
      return const _DashCard(
        child: Text(
          'Sin citas registradas',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final sorted = [...state.peakHours]
      ..sort((a, b) => b.count.compareTo(a.count));
    final max = sorted.first.count;

    return _DashCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: state.peakHours.map((h) {
          final intensity = max > 0 ? h.count / max : 0.0;
          final bg = Color.lerp(
            const Color(0xFF1A1A1A),
            const Color(0xFFD4AF37),
            intensity,
          )!;
          return Container(
            width: 60,
            height: 52,
            decoration: BoxDecoration(
              color: bg.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2C2C2C)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  h.displayHour,
                  style: TextStyle(
                    color: intensity > 0.5 ? Colors.black : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${h.count}',
                  style: TextStyle(
                    color: intensity > 0.5 ? Colors.black87 : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Rating Trend ─────────────────────────────────────────────────────────────

class _RatingTrendCard extends StatelessWidget {
  final BarberDashboardState state;
  const _RatingTrendCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isRatingTrendLoading) return const _LoadingCard(height: 80);
    if (state.ratingTrend.isEmpty) {
      return const _DashCard(
        child: Text('Sin reseñas', style: TextStyle(color: Colors.white54)),
      );
    }

    return _DashCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: state.ratingTrend.map((p) {
          final ratio = p.avgRating / 5.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Text(
                    p.avgRating > 0 ? p.avgRating.toStringAsFixed(1) : '-',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 60 * ratio + 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.month.split(' ').first,
                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                  if (p.reviewCount > 0)
                    Text(
                      '${p.reviewCount}★',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Review Distribution ──────────────────────────────────────────────────────

class _ReviewDistributionCard extends StatelessWidget {
  final BarberDashboardState state;
  const _ReviewDistributionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isReviewDistributionLoading)
      return const _LoadingCard(height: 80);
    if (state.reviewDistribution.isEmpty) {
      return const _DashCard(
        child: Text('Sin reseñas', style: TextStyle(color: Colors.white54)),
      );
    }

    return _DashCard(
      child: Column(
        children: state.reviewDistribution
            .map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(
                        r.stars,
                        (_) => const Icon(
                          Icons.star,
                          color: Color(0xFFD4AF37),
                          size: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: r.percentage / 100,
                        backgroundColor: const Color(0xFF2C2C2C),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD4AF37),
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${r.count}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
