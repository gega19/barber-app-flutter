import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/competition_period_entity.dart';
import '../../../../domain/entities/leaderboard_entry_entity.dart';
import '../../../../domain/entities/leaderboard_result_entity.dart';

abstract class CompetitionRemoteDataSource {
  Future<CompetitionPeriodEntity?> getCurrentPeriod();
  Future<List<CompetitionPeriodEntity>> getPeriods({String? status});
  Future<CompetitionPeriodEntity?> getPeriodById(String periodId);
  Future<LeaderboardResultEntity> getLeaderboard(
    String periodId, {
    int limit,
    int offset,
  });
  Future<Map<String, dynamic>?> getLastWinner();
  Future<Map<String, dynamic>?> getMyResult(String periodId, String barberId);
  Future<Map<String, dynamic>?> getBarberTopPositions(String barberId);
  Future<List<String>> getHelpRules();
}

class CompetitionRemoteDataSourceImpl implements CompetitionRemoteDataSource {
  final Dio dio;

  CompetitionRemoteDataSourceImpl({required this.dio});

  @override
  Future<CompetitionPeriodEntity?> getCurrentPeriod() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/periods/current',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return _periodFromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      appLogger.e('getCurrentPeriod error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<List<CompetitionPeriodEntity>> getPeriods({String? status}) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/periods',
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200) {
        final list = response.data['data'] as List? ?? [];
        return list
            .map((e) => _periodFromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      appLogger.e('getPeriods error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<CompetitionPeriodEntity?> getPeriodById(String periodId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/periods/$periodId',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return _periodFromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      appLogger.e('getPeriodById error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<LeaderboardResultEntity> getLeaderboard(
    String periodId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/periods/$periodId/leaderboard',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(
          headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
        ),
      );
      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> list = [];
        int total = 0;
        if (raw is List) {
          list = raw;
          total = list.length;
        } else if (raw is Map) {
          final data = raw['data'];
          if (data is List) list = data;
          final pagination = raw['pagination'];
          if (pagination is Map && pagination['total'] != null) {
            total = (pagination['total'] as num).toInt();
          } else {
            total = list.length;
          }
        }
        final result = <LeaderboardEntryEntity>[];
        for (final e in list) {
          if (e is! Map) continue;
          try {
            result.add(_entryFromJson(Map<String, dynamic>.from(e)));
          } catch (_) {
            continue;
          }
        }
        return LeaderboardResultEntity(entries: result, total: total);
      }
      return const LeaderboardResultEntity(entries: [], total: 0);
    } on DioException catch (e) {
      appLogger.e('getLeaderboard error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getLastWinner() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/last-winner',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      appLogger.e('getLastWinner error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getMyResult(
    String periodId,
    String barberId,
  ) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/periods/$periodId/me',
        queryParameters: {'barberId': barberId},
        options: Options(
          validateStatus: (status) =>
              status != null && (status < 400 || status == 404),
        ),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      appLogger.e('getMyResult error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getBarberTopPositions(String barberId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/barbers/$barberId/top-positions',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      appLogger.e('getBarberTopPositions error: ${e.message}', error: e);
      rethrow;
    }
  }

  @override
  Future<List<String>> getHelpRules() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/competition/help-rules',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        final list = data?['rules'] as List? ?? [];
        return list
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      appLogger.e('getHelpRules error: ${e.message}', error: e);
      return [];
    }
  }

  CompetitionPeriodEntity _periodFromJson(Map<String, dynamic> json) {
    return CompetitionPeriodEntity(
      id: json['id'] as String,
      name: json['name'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String? ?? 'DRAFT',
      winnerBarberId: json['winnerBarberId'] as String?,
      winnerName: json['winnerName'] as String?,
      prize: json['prize'] as String?,
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'] as String)
          : null,
    );
  }

  LeaderboardEntryEntity _entryFromJson(Map<String, dynamic> json) {
    final position = json['position'];
    final points = json['points'];
    return LeaderboardEntryEntity(
      position: position is num ? position.toInt() : 0,
      barberId: (json['barberId']?.toString() ?? '').isEmpty
          ? 'unknown'
          : json['barberId'].toString(),
      barberName: json['barberName']?.toString() ?? '',
      barberImage: json['barberImage']?.toString() ?? '',
      points: points is num ? points.toInt() : 0,
    );
  }
}
