import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/barber/barber_cubit.dart';
import '../../cubit/workplace/workplace_cubit.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/appointment/appointment_cubit.dart';
import '../../widgets/barber_queue/barber_queue_widget.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/home_tabs.dart';
import '../../widgets/home/home_filters_row.dart';
import '../../widgets/home/barbers_tab_content.dart';
import '../../widgets/home/workplaces_tab_content.dart';
import '../../widgets/home/filters_modal.dart';
import '../../../domain/entities/workplace_entity.dart';
import '../../../domain/entities/barber_entity.dart';
import '../../../core/constants/home_constants.dart';
import '../../../core/utils/filter_utils.dart';
import '../../../core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  final _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _searchDebounce;
  bool _notificationPermissionRequested = false;

  // Filtros
  String _sortBy = HomeConstants.defaultSortBy;
  String _sortOrder = HomeConstants.defaultSortOrder;
  String _searchQuery = ''; // Query de búsqueda

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    context.read<BarberCubit>().loadBarbers(reset: true);
    context.read<WorkplaceCubit>().loadWorkplaces(reset: true);

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated ||
        authState is AuthProfileUpdateError) {
      context.read<AppointmentCubit>().loadAppointments();
    }
    _requestNotificationPermission();

    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Assuming there is a global route observer or we can inject one.
    // If not, we can use an alternative approach. For now, let's use the standard one if available, 
    // but the easiest robust way is just listening to auth or app lifecycle.
    // However, since we use go_router, let's just make sure AppointmentCubit is reloaded when Auth Changes or we can use the Cubit's stream.
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });

    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      if (_tabController.index == 0) {
        context.read<BarberCubit>().loadBarbers(reset: true);
      } else {
        context.read<WorkplaceCubit>().loadWorkplaces(reset: true);
      }
      return;
    }

    _searchDebounce = Timer(HomeConstants.searchDebounceDuration, () {
      if (!mounted) return;
      if (_tabController.index == 0) {
        context.read<BarberCubit>().searchBarbers(_searchQuery);
      } else {
        context.read<WorkplaceCubit>().searchWorkplaces(_searchQuery);
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (_notificationPermissionRequested) return;
    _notificationPermissionRequested = true;

    try {
      final hasPermission = await NotificationService()
          .hasNotificationPermission();
      if (!hasPermission) {
        await NotificationService().requestPermissions();
      }
    } catch (_) {
      // Ignorar errores de permisos para no bloquear el home
    }
  }

  void _showFilters() {
    final isBarberTab = _tabController.index == 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FiltersModal(
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        isBarberTab: isBarberTab,
        onApply: (sortBy, sortOrder) {
          setState(() {
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  List<BarberEntity> _applyBarberFilters(List<BarberEntity> barbers) {
    if (_searchQuery.isNotEmpty) {
      return FilterUtils.sortBarbers(barbers, _sortBy, _sortOrder);
    }
    return FilterUtils.applyBarberFilters(
      barbers,
      _searchQuery,
      _sortBy,
      _sortOrder,
    );
  }

  List<WorkplaceEntity> _applyWorkplaceFilters(
    List<WorkplaceEntity> workplaces,
  ) {
    // When showing search results, only apply sort (no local filter by text)
    final queryForFilter = _searchQuery.isNotEmpty ? '' : _searchQuery;
    return FilterUtils.applyWorkplaceFilters(
      workplaces,
      queryForFilter,
      _sortBy,
      _sortOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated &&
              authState.user.isBarber &&
              authState.user.barberId != null) {
            return BarberQueueFAB(
              barberId: authState.user.barberId!,
              onTap: () {},
            );
          }
          return const SizedBox.shrink();
        },
      ),
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
              // Header
              HomeHeader(
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
              ),
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    HomeTabs(tabController: _tabController),
                    const SizedBox(height: 12),
                    // Filter Button
                    HomeFiltersRow(
                      tabIndex: _tabController.index,
                      searchQuery: _searchQuery,
                      sortBy: _sortBy,
                      sortOrder: _sortOrder,
                      applyBarberFilters: _applyBarberFilters,
                      applyWorkplaceFilters: _applyWorkplaceFilters,
                      onFiltersPressed: _showFilters,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Barberos Tab
                    BarbersTabContent(applyFilters: _applyBarberFilters),
                    // Barberías Tab
                    WorkplacesTabContent(applyFilters: _applyWorkplaceFilters),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
