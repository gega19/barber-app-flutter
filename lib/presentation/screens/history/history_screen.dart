import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/appointment_utils.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/appointment/appointment_card.dart';
import '../../widgets/appointment/appointment_card_skeleton.dart';
import '../../widgets/appointment/appointment_header_widget.dart';
import '../../widgets/appointment/appointment_tabs_widget.dart';
import '../../widgets/appointment/appointment_empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppointmentEntity>? _cachedFiltered;
  int? _cachedTabIndex;
  int? _cachedAppointmentsLength;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AppointmentCubit>().loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentEntity> _filterAppointments(
    List<AppointmentEntity> appointments,
    int tabIndex,
  ) {
    if (_cachedFiltered != null &&
        _cachedTabIndex == tabIndex &&
        _cachedAppointmentsLength == appointments.length) {
      return _cachedFiltered!;
    }

    List<AppointmentEntity> filtered;

    if (tabIndex == 0) {
      filtered = List.from(appointments);
    } else if (tabIndex == 1) {
      filtered = appointments
          .where((a) => AppointmentUtils.isUpcoming(a))
          .toList();
    } else {
      filtered = appointments
          .where((a) => a.status == AppointmentStatus.completed)
          .toList();
    }

    // Ordenar por fecha y hora (más próximas primero)
    filtered.sort((a, b) {
      final dateTimeA = AppointmentUtils.parseAppointmentDateTime(a);
      final dateTimeB = AppointmentUtils.parseAppointmentDateTime(b);
      return dateTimeA.compareTo(dateTimeB);
    });

    // Guardar en caché
    _cachedFiltered = filtered;
    _cachedTabIndex = tabIndex;
    _cachedAppointmentsLength = appointments.length;

    return filtered;
  }

  UserEntity? _getCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.user;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _getCurrentUser();
    final isBarber = user?.role == 'BARBER';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppointmentHeaderWidget(isBarber: isBarber),
              AppointmentTabsWidget(
                tabController: _tabController,
                onTabChanged: () {
                  // Limpiar caché al cambiar de tab
                  _cachedFiltered = null;
                  _cachedTabIndex = null;
                  _cachedAppointmentsLength = null;
                  setState(() {});
                },
              ),
              Expanded(
                child: BlocBuilder<AppointmentCubit, AppointmentState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    if (state is AppointmentLoading) {
                      return _buildSkeletonList();
                    }

                    if (state is AppointmentError) {
                      return AppErrorWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<AppointmentCubit>().loadAppointments();
                        },
                      );
                    }

                    if (state is AppointmentLoaded) {
                      // Limpiar caché cuando se cargan nuevas citas
                      if (_cachedAppointmentsLength !=
                          state.appointments.length) {
                        _cachedFiltered = null;
                        _cachedTabIndex = null;
                        _cachedAppointmentsLength = null;
                      }
                      final filtered = _filterAppointments(
                        state.appointments,
                        _tabController.index,
                      );
                      return _buildAppointmentsList(filtered, isBarber, user);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<AppointmentEntity> appointments,
    bool isBarber,
    UserEntity? user,
  ) {
    if (appointments.isEmpty) {
      return AppointmentEmptyStateWidget(
        icon: _getEmptyIcon(),
        message: _getEmptyMessage(),
        submessage: _getEmptySubmessage(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppointmentCubit>().loadAppointments();
      },
      color: AppColors.primaryGold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(
                appointment: appointments[index],
                isBarber: isBarber,
                currentUser: user,
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: index * 50),
              )
              .slideY(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: index * 50),
              );
        },
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: false,
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const AppointmentCardSkeleton();
      },
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }

  IconData _getEmptyIcon() {
    if (_tabController.index == 0) return Icons.event_note;
    if (_tabController.index == 1) return Icons.access_time;
    return Icons.check_circle;
  }

  String _getEmptyMessage() {
    if (_tabController.index == 0) return 'No tienes citas registradas';
    if (_tabController.index == 1) return 'No tienes citas próximas';
    return 'No tienes citas completadas';
  }

  String _getEmptySubmessage() {
    if (_tabController.index == 0) {
      return 'Cuando reserves una cita, aparecerá aquí';
    }
    if (_tabController.index == 1) {
      return 'Tus próximas citas aparecerán aquí cuando las reserves';
    }
    return 'Las citas que completes aparecerán aquí';
  }
}
