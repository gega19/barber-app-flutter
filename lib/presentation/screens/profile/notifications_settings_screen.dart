import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/common/app_card.dart';

/// Pantalla de configuración de notificaciones
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _notificationsEnabled = false;
  bool _appointmentNotifications = true;
  bool _promotionNotifications = true;
  bool _competitionNotifications = true;
  bool _generalNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = NotificationService();
      final hasPermission = await notificationService
          .hasNotificationPermission();

      // Cargar preferencias guardadas (si las hay)
      // Por ahora, usamos valores por defecto

      setState(() {
        _notificationsEnabled = hasPermission;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Solicitar permisos
      final notificationService = NotificationService();
      final hasPermission = await notificationService
          .hasNotificationPermission();

      if (!hasPermission) {
        // Solicitar permisos
        await notificationService.initialize();
        final newPermission = await notificationService
            .hasNotificationPermission();

        if (!newPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Se necesitan permisos de notificaciones para activar esta función',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      }
    }

    setState(() {
      _notificationsEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Notificaciones activadas' : 'Notificaciones desactivadas',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundCard,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toggle principal de notificaciones
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    color: AppColors.primaryGold,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Notificaciones',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _notificationsEnabled
                                            ? 'Recibir notificaciones de la app'
                                            : 'Las notificaciones están desactivadas',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _notificationsEnabled,
                                  onChanged: _toggleNotifications,
                                  activeColor: AppColors.primaryGold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tipos de notificaciones (solo si están habilitadas)
                      if (_notificationsEnabled) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Tipos de Notificaciones',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              _buildNotificationTypeRow(
                                icon: Icons.calendar_today,
                                title: 'Citas',
                                subtitle:
                                    'Recordatorios y actualizaciones de citas',
                                value: _appointmentNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _appointmentNotifications = value;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                              ),
                              Divider(color: AppColors.borderGold, height: 24),
                              _buildNotificationTypeRow(
                                icon: Icons.local_offer,
                                title: 'Promociones',
                                subtitle: 'Ofertas especiales y descuentos',
                                value: _promotionNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _promotionNotifications = value;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                              ),
                              Divider(color: AppColors.borderGold, height: 24),
                              _buildNotificationTypeRow(
                                icon: Icons.emoji_events,
                                title: 'Competencias',
                                subtitle:
                                    'Actualizaciones del ranking y competencias',
                                value: _competitionNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _competitionNotifications = value;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                              ),
                              Divider(color: AppColors.borderGold, height: 24),
                              _buildNotificationTypeRow(
                                icon: Icons.info_outline,
                                title: 'Generales',
                                subtitle:
                                    'Noticias y actualizaciones de la app',
                                value: _generalNotifications,
                                onChanged: (value) {
                                  setState(() {
                                    _generalNotifications = value;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Información
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Información',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primaryGold,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _notificationsEnabled
                                    ? 'Recibirás notificaciones según tus preferencias. Puedes cambiar estos ajustes en cualquier momento.'
                                    : 'Activa las notificaciones para recibir recordatorios de citas, promociones especiales y actualizaciones importantes.',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypeRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryGold,
            ),
          ],
        ),
      ),
    );
  }
}
