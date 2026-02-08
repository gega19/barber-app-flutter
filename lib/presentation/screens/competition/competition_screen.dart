import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../data/datasources/remote/barber_remote_datasource.dart';
import '../../../domain/entities/competition_period_entity.dart';
import '../../../domain/entities/leaderboard_entry_entity.dart';
import '../../../domain/usecases/competition/get_current_period_usecase.dart';
import '../../../domain/usecases/competition/get_leaderboard_usecase.dart';
import '../../../domain/usecases/competition/get_help_rules_usecase.dart';
import '../../../domain/usecases/competition/get_my_competition_result_usecase.dart';
import '../../../domain/usecases/competition/get_periods_usecase.dart';
import '../../widgets/common/app_card.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

const int _leaderboardPageSize = 20;

class _CompetitionScreenState extends State<CompetitionScreen>
    with TickerProviderStateMixin {
  CompetitionPeriodEntity? _period;
  List<LeaderboardEntryEntity> _entries = [];
  int _totalEntries = 0;
  bool _loadingMore = false;
  Map<String, dynamic>? _myResult;
  String? _myBarberId;
  bool _loading = true;
  String? _error;
  late AnimationController _medalAnimationController;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final current = await sl<GetCurrentPeriodUseCase>().call();
      CompetitionPeriodEntity? period;
      current.fold(
        (f) => setState(() => _error = f.message),
        (p) => period = p,
      );
      if (period == null) {
        final closed = await sl<GetPeriodsUseCase>().call(status: 'CLOSED');
        closed.fold((f) => setState(() => _error = _error ?? f.message), (
          list,
        ) {
          if (list.isNotEmpty) period = list.first;
        });
      }
      if (period == null && _error == null) {
        setState(() {
          _period = null;
          _entries = [];
          _myResult = null;
          _loading = false;
        });
        return;
      }
      if (period != null) {
        _period = period;
        setState(() {
          _entries = [];
          _totalEntries = 0;
        });
        final lb = await sl<GetLeaderboardUseCase>().call(
          period!.id,
          limit: _leaderboardPageSize,
          offset: 0,
        );
        lb.fold(
          (f) => setState(() {
            _error = _error ?? f.message;
            _entries = [];
            _totalEntries = 0;
          }),
          (result) => setState(() {
            _entries = result.entries;
            _totalEntries = result.total;
          }),
        );
        try {
          final myBarber = await sl<BarberRemoteDataSource>()
              .getMyBarberProfile();
          if (myBarber != null) {
            final my = await sl<GetMyCompetitionResultUseCase>().call(
              period!.id,
              myBarber.id,
            );
            Map<String, dynamic>? result;
            my.fold((_) => result = null, (r) => result = r);
            if (mounted) {
              setState(() {
                _myBarberId = myBarber.id;
                _myResult = result;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _myBarberId = null;
                _myResult = null;
              });
            }
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _myBarberId = null;
              _myResult = null;
            });
          }
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_period == null || _loadingMore || _entries.length >= _totalEntries) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final lb = await sl<GetLeaderboardUseCase>().call(
        _period!.id,
        limit: _leaderboardPageSize,
        offset: _entries.length,
      );
      lb.fold((_) => setState(() => _loadingMore = false), (result) {
        if (mounted) {
          setState(() {
            _entries = [..._entries, ...result.entries];
            _loadingMore = false;
          });
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _medalAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _medalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Ranking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppColors.textSecondary),
            onPressed: _showRulesModal,
            tooltip: 'Ver reglas',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _load,
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(color: AppColors.primaryGold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _period == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay periodo activo',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando haya una competencia en curso o cerrada, verás el ranking aquí.',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primaryGold,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _periodHeader(_period!),
                    if (_myResult != null) ...[
                      const SizedBox(height: 20),
                      _myResultCard(),
                    ],
                    const SizedBox(height: 24),
                    _sectionTitle('Top barberos'),
                    if (_entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 64,
                                color: AppColors.primaryGold.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'El ranking aún no comienza',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  'Las puntuaciones se actualizarán pronto.\n¡Realiza citas para aparecer aquí!',
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ..._entries.map((e) => _leaderboardTile(e)),
                      if (_entries.length < _totalEntries) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: _loadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryGold,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: _loadMore,
                                  child: Text(
                                    'Cargar más (${_entries.length} de $_totalEntries)',
                                    style: const TextStyle(
                                      color: AppColors.primaryGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _periodHeader(CompetitionPeriodEntity period) {
    final dateFormat = DateFormat('d MMM y', 'es');
    final name = period.name ?? 'Competencia';
    final dates =
        '${dateFormat.format(period.startDate)} – ${dateFormat.format(period.endDate)}';
    final hasPrize = period.prize != null && period.prize!.isNotEmpty;
    final isClosed = period.status == 'CLOSED';
    final winnerName = period.winnerName;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.primaryGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isClosed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Finalizada',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.95,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isClosed &&
                    winnerName != null &&
                    winnerName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ganador: $winnerName',
                        style: TextStyle(
                          color: AppColors.primaryGold.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dates,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    if (hasPrize) ...[
                      Text(
                        ' · ',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.card_giftcard,
                        size: 12,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        period.prize!,
                        style: TextStyle(
                          color: AppColors.primaryGold.withValues(alpha: 0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _myResultCard() {
    final position = _myResult!['position'] as int? ?? 0;
    final points = _myResult!['points'] as int? ?? 0;
    final total = _myResult!['totalParticipants'] as int? ?? 0;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              '#$position',
              style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estás en el puesto #$position',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$points puntos · $total participantes',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _defaultRules = [
    'Solo suman puntos las citas completadas.',
    'El cliente debe tener teléfono verificado para que la cita cuente.',
    'Cada cita cuenta solo para un barbero y en el periodo en que se realizó.',
    'Al cerrar el periodo, el barbero con más puntos es el ganador.',
  ];

  Future<void> _showRulesModal() async {
    List<String> rules = List.from(_defaultRules);
    final result = await sl<GetHelpRulesUseCase>().call();
    result.fold((_) {}, (r) {
      if (r.isNotEmpty) rules = r;
    });
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppColors.primaryGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Reglas y cómo funciona',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...rules.map((r) => _ruleItem(r)),
              if (rules.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No hay reglas configuradas.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ...[],
              const SizedBox(height: 8),
              Text(
                'Las reglas pueden actualizarse. En caso de duda, contacta al administrador.',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppColors.primaryGold.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _leaderboardTile(LeaderboardEntryEntity entry) {
    final isTopThree = entry.position <= 3;
    final isMe = _myBarberId != null && entry.barberId == _myBarberId;
    final isWinner =
        _period != null &&
        _period!.status == 'CLOSED' &&
        (_period!.winnerBarberId == entry.barberId || entry.position == 1);
    final medalColor = entry.position == 1
        ? const Color(0xFFFFD700)
        : entry.position == 2
        ? const Color(0xFFC0C0C0)
        : const Color(0xFFCD7F32);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTopThree ? 16 : 14,
        ),
        backgroundColor: isMe
            ? AppColors.primaryGold.withValues(alpha: 0.08)
            : null,
        onTap: () => context.push('/barber/${entry.barberId}'),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: isTopThree
                  ? AnimatedBuilder(
                      animation: _medalAnimationController,
                      builder: (context, child) {
                        final t = _medalAnimationController.value;
                        final curve = Curves.easeInOut.transform(t);
                        final scale = 1.0 + 0.12 * curve;
                        final opacity = 0.88 + 0.12 * curve;
                        return Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: scale,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.emoji_events,
                              size: 30,
                              color: medalColor,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        '${entry.position}',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            entry.barberImage.isNotEmpty
                ? CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(entry.barberImage),
                  )
                : CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryGold.withValues(
                      alpha: 0.25,
                    ),
                    child: Text(
                      entry.barberName.isNotEmpty
                          ? entry.barberName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.barberName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isTopThree ? 17 : 16,
                        fontWeight: isTopThree
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isWinner) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Ganador',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (isMe && !isWinner) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tú',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.points} pts',
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
