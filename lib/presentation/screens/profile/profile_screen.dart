import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_avatar.dart';
import '../../../core/injection/injection.dart';
import '../../../domain/usecases/auth/get_user_stats_usecase.dart';
import '../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import '../../../data/datasources/remote/upload_remote_datasource.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userStats;
  bool isLoadingStats = false;
  String? _userBarberId;
  bool _isBarber = false; // Variable para rastrear si el usuario es barbero
  final GetUserStatsUseCase getUserStatsUseCase = GetUserStatsUseCase(sl());
  bool _isUploadingAvatar = false;
  final UploadRemoteDataSource _uploadDataSource = sl<UploadRemoteDataSource>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUserBarberId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar cuando se regrese a esta pantalla (útil después de convertirse en barbero)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserBarberId();
      }
    });
  }

  Future<void> _loadUserBarberId() async {
    if (!mounted) return;
    
    // Capture context-dependent values before async operations
    final authCubit = mounted ? context.read<AuthCubit>() : null;
    if (authCubit == null || !mounted) return;
    
    final currentState = authCubit.state;
    final userEmail = currentState is AuthAuthenticated ? currentState.user.email : null;
    
    if (currentState is! AuthAuthenticated || userEmail == null) {
      if (mounted) {
        setState(() {
          _userBarberId = null;
          _isBarber = false;
        });
      }
      return;
    }

    try {
      final dio = sl<Dio>();
      // First try to get all barbers and search by email
      final response = await dio.get('${AppConstants.baseUrl}/api/barbers');
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final matchingBarbers = data.where(
          (b) => b['email'] == userEmail,
        ).toList();
        
        if (matchingBarbers.isNotEmpty && mounted) {
          setState(() {
            _userBarberId = matchingBarbers.first['id'] as String;
            _isBarber = true; // Usuario tiene perfil de barbero
          });
          return;
        }
      }
      
      // If not found, try searching endpoint
      if (mounted) {
        try {
          final searchResponse = await dio.get(
            '${AppConstants.baseUrl}/api/barbers/search',
            queryParameters: {'q': userEmail},
          );
          
          if (!mounted) return;
          
          if (searchResponse.statusCode == 200) {
            final searchData = searchResponse.data['data'] as List;
            final matchingBarbers = searchData.where(
              (b) => b['email'] == userEmail,
            ).toList();
            
            if (matchingBarbers.isNotEmpty && mounted) {
              setState(() {
                _userBarberId = matchingBarbers.first['id'] as String;
                _isBarber = true; // Usuario tiene perfil de barbero
              });
              return;
            }
          }
        } catch (e) {
          // Search failed, continue
        }
        
        // If still not found, set to null and mark as not barber
        if (mounted) {
          setState(() {
            _userBarberId = null;
            _isBarber = false; // Usuario no tiene perfil de barbero
          });
        }
      }
    } catch (e) {
      // Error loading barber ID, continue without showing the button
      if (mounted) {
        setState(() {
          _userBarberId = null;
          _isBarber = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() => isLoadingStats = true);
    final result = await getUserStatsUseCase();
    result.fold(
      (failure) {
        setState(() {
          userStats = _isBarber
              ? {
                  'totalAppointments': 0,
                  'uniqueClients': 0,
                  'rating': 0.0,
                  'totalEarnings': 0.0,
                }
              : {
                  'totalAppointments': 0,
                  'completedAppointments': 0,
                  'totalSpent': 0.0,
                  'uniqueBarbers': 0,
                };
          isLoadingStats = false;
        });
      },
      (stats) {
        setState(() {
          userStats = stats;
          isLoadingStats = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
                         // Reload barber ID and stats when auth state changes (e.g., after becoming a barber or updating profile)
          if (state is AuthAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _loadUserBarberId();
                _loadStats();
                // Force rebuild to update UI with new user data
                setState(() {});
              }
            });
          }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0F0F0F),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final user = state is AuthAuthenticated 
                    ? state.user 
                    : (state is AuthProfileUpdateError ? state.user : null);

                              if (user == null) {
                  return const Center(
                    child: Text(
                      'Usuario no autenticado',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

               return CustomScrollView(
                 slivers: [
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.all(24),
                       child: Column(
                         children: [
                                                       Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AppAvatar(
                                  key: ValueKey('profile_avatar_${user.id}_${user.avatarSeed ?? ''}_${user.avatar ?? ''}'), // Force rebuild when avatar or seed changes
                                  imageUrl: user.avatar,
                                  name: user.name,
                                  avatarSeed: user.avatarSeed,
                                  size: 96,
                                  borderColor: AppColors.primaryGold,
                                ),
                               Positioned(
                                 bottom: 0,
                                 right: 0,
                                 child: GestureDetector(
                                   onTap: _isUploadingAvatar ? null : () => _showAvatarOptions(context),
                                   child: Container(
                                     width: 32,
                                     height: 32,
                                     decoration: BoxDecoration(
                                       color: AppColors.primaryGold,
                                       shape: BoxShape.circle,
                                       border: Border.all(
                                         color: AppColors.backgroundCard,
                                         width: 2,
                                       ),
                                     ),
                                     child: _isUploadingAvatar
                                         ? const Padding(
                                             padding: EdgeInsets.all(6),
                                             child: CircularProgressIndicator(
                                               strokeWidth: 2,
                                               valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                                             ),
                                           )
                                         : const Icon(
                                             Icons.camera_alt,
                                             size: 16,
                                             color: AppColors.textDark,
                                           ),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           Text(
                             user.name,
                             style: const TextStyle(
                               color: AppColors.primaryGold,
                               fontSize: 24,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             user.email,
                             style: const TextStyle(
                               color: AppColors.textSecondary,
                               fontSize: 14,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       child: AppCard(
                         padding: const EdgeInsets.all(16),
                         child: _isBarber
                             ? Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                 children: [
                                   _buildStatItem(
                                     (userStats?['totalAppointments'] ?? 0).toString(),
                                     'Citas',
                                   ),
                                   Container(
                                     width: 1,
                                     height: 40,
                                     color: AppColors.borderGold,
                                   ),
                               
                                     _buildStatItem(
                                     (userStats?['rating'] ?? 0.0).toStringAsFixed(1),
                                     'Puntuación',
                                   ),
                                   Container(
                                     width: 1,
                                     height: 40,
                                     color: AppColors.borderGold,
                                   ),

                                      _buildStatItem(
                                     (userStats?['uniqueClients'] ?? 0).toString(),
                                     'Clientes',
                                   ),
                                 
                                 ],
                               )
                             : Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                                 children: [
                                   _buildStatItem(
                                     (userStats?['totalAppointments'] ?? 0).toString(),
                                     'Citas',
                                   ),
                                   Container(
                                     width: 1,
                                     height: 40,
                                     color: AppColors.borderGold,
                                   ),
                                   _buildStatItem(
                                     r'$' + (userStats?['totalSpent'] ?? 0.0).toStringAsFixed(0),
                                     'Gastado',
                                   ),
                                   Container(
                                     width: 1,
                                     height: 40,
                                     color: AppColors.borderGold,
                                   ),
                                   _buildStatItem(
                                     (userStats?['uniqueBarbers'] ?? 0).toString(),
                                     'Barberos',
                                   ),
                                 ],
                               ),
                       ),
                     ),
                   ),
                   const SliverToBoxAdapter(child: SizedBox(height: 24)),
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                                                      const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 12),
                              child: Text(
                                'Información Personal',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                           AppCard(
                             padding: const EdgeInsets.all(16),
                             child: Column(
                               children: [
                                                                 _buildInfoRow(
                                   icon: Icons.person,
                                   label: 'Nombre Completo',
                                   value: user.name,
                                   isEditable: true,
                                   fieldType: 'name',
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildInfoRow(
                                   icon: Icons.email,
                                   label: 'Correo Electrónico',
                                   value: user.email,
                                   isEditable: false,
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildInfoRow(
                                   icon: Icons.phone,
                                   label: 'Teléfono',
                                   value: user.phone ?? 'No configurado',
                                   isEditable: true,
                                   fieldType: 'phone',
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildInfoRow(
                                   icon: Icons.location_on,
                                   label: 'Ubicación',
                                   value: user.location ?? 'No configurado',
                                   isEditable: true,
                                   fieldType: 'location',
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildInfoRow(
                                   icon: Icons.public,
                                   label: 'País',
                                   value: user.country ?? 'No configurado',
                                   isEditable: true,
                                   fieldType: 'country',
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildInfoRow(
                                   icon: Icons.person,
                                   label: 'Género',
                                   value: user.gender ?? 'No configurado',
                                   isEditable: true,
                                   fieldType: 'gender',
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                   if (_isBarber && _userBarberId != null)
                     SliverToBoxAdapter(
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Padding(
                               padding: EdgeInsets.only(left: 4, bottom: 12),
                               child: Text(
                                 'Gestión de Perfil',
                                 style: TextStyle(
                                   color: AppColors.textPrimary,
                                   fontSize: 18,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ),
                             AppCard(
                               padding: const EdgeInsets.all(16),
                               child: Column(
                                 children: [
                                   _buildSettingsRow(
                                     icon: Icons.visibility,
                                     title: 'Ver mi perfil público',
                                     subtitle: 'Cómo ven tu perfil los demás',
                                     onTap: () {
                                       if (_userBarberId != null) {
                                         context.push('/barber/$_userBarberId');
                                       }
                                     },
                                   ),
                                   Divider(color: AppColors.borderGold),
                                   _buildSettingsRow(
                                     icon: Icons.badge,
                                     title: 'Información Profesional',
                                     subtitle: 'Editar especialidad, experiencia y ubicación',
                                     onTap: () {
                                       context.push('/barber-info');
                                     },
                                   ),
                                   Divider(color: AppColors.borderGold),
                                   _buildSettingsRow(
                                     icon: Icons.content_cut,
                                     title: 'Mis Servicios',
                                     subtitle: 'Editar, agregar o eliminar servicios',
                                     onTap: () {
                                       context.push('/barber-services');
                                     },
                                   ),
                                   Divider(color: AppColors.borderGold),
                                   _buildSettingsRow(
                                     icon: Icons.photo_library,
                                     title: 'Mi Multimedia',
                                     subtitle: 'Editar, agregar o eliminar fotos y videos',
                                     onTap: () {
                                       context.push('/barber-media');
                                     },
                                   ),
                                   Divider(color: AppColors.borderGold),
                                   _buildSettingsRow(
                                     icon: Icons.access_time,
                                     title: 'Mi Horario',
                                     subtitle: 'Configura tus días y horas disponibles',
                                     onTap: () {
                                       context.push('/barber-availability');
                                     },
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                   if (_isBarber && _userBarberId != null)
                     const SliverToBoxAdapter(child: SizedBox(height: 24)),
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Padding(
                             padding: EdgeInsets.only(left: 4, bottom: 12),
                             child: Text(
                               'Configuración',
                               style: TextStyle(
                                 color: AppColors.textPrimary,
                                 fontSize: 18,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ),
                           AppCard(
                             padding: const EdgeInsets.all(16),
                             child: Column(
                               children: [
                                                                   if (!_isBarber)
                                    _buildSettingsRow(
                                      icon: Icons.content_cut,
                                      title: 'Convertirse en Barbero',
                                      subtitle: 'Comienza a ofrecer tus servicios',
                                      onTap: () {
                                        context.push('/become-barber');
                                      },
                                    ),
                                                                     if (!_isBarber)
                                     Divider(color: AppColors.borderGold),
                                 _buildSettingsRow(
                                   icon: Icons.settings,
                                   title: 'Preferencias',
                                   subtitle: 'Configura tus preferencias',
                                   onTap: () {},
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildSettingsRow(
                                   icon: Icons.notifications,
                                   title: 'Notificaciones',
                                   subtitle: 'Gestiona tus notificaciones',
                                   onTap: () {},
                                 ),
                                 Divider(color: AppColors.borderGold),
                                 _buildSettingsRow(
                                   icon: Icons.lock,
                                   title: 'Seguridad',
                                   subtitle: 'Autenticación biométrica y seguridad',
                                   onTap: () {
                                     context.push('/security-settings');
                                   },
                                 ),
                                  Divider(color: AppColors.borderGold),
                                  _buildSettingsRow(
                                    icon: Icons.delete_forever,
                                    title: 'Eliminar Cuenta',
                                    subtitle: 'Elimina permanentemente tu cuenta',
                                    onTap: _showDeleteAccountDialog,
                                    iconColor: AppColors.error,
                                    iconBackgroundColor: AppColors.error.withOpacity(0.15),
                                    titleColor: AppColors.error,
                                    subtitleColor: AppColors.error,
                                  ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                   const SliverToBoxAdapter(child: SizedBox(height: 24)),
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                                             child: AppButton(
                         text: 'Cerrar Sesión',
                         onPressed: () async {
                           final confirmed = await showDialog<bool>(
                             context: context,
                             builder: (context) => AlertDialog(
                               backgroundColor: AppColors.backgroundCard,
                               title: const Text(
                                 'Cerrar Sesión',
                                 style: TextStyle(color: AppColors.textPrimary),
                               ),
                               content: const Text(
                                 '¿Estás seguro de que deseas cerrar sesión?',
                                 style: TextStyle(color: AppColors.textSecondary),
                               ),
                               actions: [
                                 TextButton(
                                   onPressed: () => Navigator.of(context).pop(false),
                                   child: const Text(
                                     'Cancelar',
                                     style: TextStyle(color: AppColors.textSecondary),
                                   ),
                                 ),
                                 TextButton(
                                   onPressed: () => Navigator.of(context).pop(true),
                                   child: const Text(
                                     'Cerrar Sesión',
                                     style: TextStyle(color: AppColors.error),
                                   ),
                                 ),
                               ],
                             ),
                           );

                          if (confirmed == true) {
                            context.read<AuthCubit>().logout();
                          }
                        },
                        type: ButtonType.outline,
                        icon: Icons.logout,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundCard,
              title: const Text(
                'Eliminar Cuenta',
                style: TextStyle(color: AppColors.error),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Esta acción eliminará permanentemente tu historial, reseñas y perfil. No podrás recuperar estos datos después.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Confirma tu contraseña',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderGold),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryGold),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          final password = passwordController.text.trim();
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa tu contraseña para continuar'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isDeleting = true;
                          });

                          final success = await context.read<AuthCubit>().deleteAccount(password: password);

                          if (!mounted) return;

                          if (success) {
                            Navigator.of(dialogContext).pop();
                          } else {
                            setState(() {
                              isDeleting = false;
                            });
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.error,
                          ),
                        )
                      : const Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.error),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    String? fieldType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppColors.primaryGold,
                size: 20,
              ),
              onPressed: () => _showEditModal(context, label, value, fieldType!),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    Color? subtitleColor,
    Color? iconBackgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.primaryGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
              icon,
              color: iconColor ?? AppColors.primaryGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                  style: TextStyle(
                    color: titleColor ?? AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                  style: TextStyle(
                    color: subtitleColor ?? AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, String label, String currentValue, String fieldType) {
    final controller = TextEditingController(text: currentValue == 'No configurado' ? '' : currentValue);
    final initialGender = currentValue != 'No configurado' ? currentValue : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EditModalContent(
        label: label,
        fieldType: fieldType,
        controller: controller,
        initialGender: initialGender,
        onSave: (value) => _updateField(fieldType, value),
      ),
    );
  }

  void _updateField(String fieldType, String value) {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;

    if (currentState is! AuthAuthenticated) return;

    switch (fieldType) {
      case 'name':
        authCubit.updateProfile(name: value);
        break;
      case 'phone':
        authCubit.updateProfile(phone: value);
        break;
      case 'location':
        authCubit.updateProfile(location: value);
        break;
      case 'country':
        authCubit.updateProfile(country: value);
        break;
      case 'gender':
        authCubit.updateProfile(gender: value);
        break;
    }
  }

  void _showAvatarOptions(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;
    if (currentState is! AuthAuthenticated) return;
    
    final user = currentState.user;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar Avatar',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildAvatarOption(
              context,
              icon: Icons.camera_alt,
              title: 'Tomar Foto',
              subtitle: 'Usar la cámara para tomar una nueva foto',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _buildAvatarOption(
              context,
              icon: Icons.photo_library,
              title: 'Elegir de Galería',
              subtitle: 'Seleccionar una foto de tu galería',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
            _buildAvatarOption(
              context,
              icon: Icons.palette,
              title: 'Cambiar Avatar',
              subtitle: 'Generar un nuevo avatar aleatorio',
              onTap: () {
                Navigator.pop(context);
                _generateRandomAvatar();
              },
            ),
            const SizedBox(height: 12),
            if (user.avatar != null && user.avatar!.isNotEmpty)
              _buildAvatarOption(
                context,
                icon: Icons.delete,
                title: 'Eliminar Foto',
                subtitle: 'Volver al avatar generado',
                onTap: () {
                  Navigator.pop(context);
                  _removeAvatar();
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border.all(color: AppColors.borderGold),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGold,
                size: 24,
              ),
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
                  const SizedBox(height: 4),
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
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _isUploadingAvatar = true;
        });

        try {
          final imageFile = File(pickedFile.path);
          final imageUrl = await _uploadDataSource.uploadFile(imageFile);

          if (!mounted) return;
          final authCubit = context.read<AuthCubit>();
          await authCubit.updateProfile(avatar: imageUrl);

          if (mounted) {
            // Force rebuild to update avatar
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar actualizado correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al subir imagen: ${e.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUploadingAvatar = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateRandomAvatar() async {
    final random = Random();
    final randomSeed = '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(10000)}';
    final authCubit = context.read<AuthCubit>();
    
    // Clear avatar URL to force using default avatar with new seed
    await authCubit.updateProfile(avatarSeed: randomSeed, avatar: '');
    
    if (mounted) {
      // Force rebuild to update avatar
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar aleatorio generado'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _removeAvatar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Eliminar Foto',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu foto de perfil? Volverás al avatar generado.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Guardar referencias antes de la operación asíncrona
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final authCubit = context.read<AuthCubit>();
              
              Navigator.of(context).pop();
              
              await authCubit.updateProfile(avatar: '');
              
              if (mounted) {
                // Force rebuild to update avatar
                setState(() {});
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Foto eliminada correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditModalContent extends StatefulWidget {
  final String label;
  final String fieldType;
  final TextEditingController controller;
  final String? initialGender;
  final Function(String) onSave;

  const _EditModalContent({
    required this.label,
    required this.fieldType,
    required this.controller,
    this.initialGender,
    required this.onSave,
  });

  @override
  State<_EditModalContent> createState() => _EditModalContentState();
}

class _EditModalContentState extends State<_EditModalContent> {
  late String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                             Text(
                 'Editar ${widget.label}',
                 style: const TextStyle(
                   color: AppColors.textPrimary,
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.fieldType == 'gender') ...[
                         const Text(
               'Seleccionar Género',
               style: TextStyle(
                 color: AppColors.textSecondary,
                 fontSize: 14,
               ),
             ),
            const SizedBox(height: 12),
            Row(
              children: [
                                 Expanded(
                   child: _buildGenderOption(
                     context,
                     'Masculino',
                     'Male',
                     selectedGender,
                     (value) {
                       setState(() {
                         selectedGender = value;
                       });
                     },
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: _buildGenderOption(
                     context,
                     'Femenino',
                     'Female',
                     selectedGender,
                     (value) {
                       setState(() {
                         selectedGender = value;
                       });
                     },
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: _buildGenderOption(
                     context,
                     'Otro',
                     'Other',
                     selectedGender,
                     (value) {
                       setState(() {
                         selectedGender = value;
                       });
                     },
                   ),
                 ),
              ],
            ),
          ] else
            TextField(
              controller: widget.controller,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
                ),
                fillColor: AppColors.backgroundCard,
                filled: true,
              ),
            ),
          const SizedBox(height: 24),
                     AppButton(
             text: 'Guardar',
             onPressed: () {
              final newValue = widget.fieldType == 'gender'
                  ? selectedGender
                  : widget.controller.text.trim();

              if (newValue != null && newValue.isNotEmpty) {
                widget.onSave(newValue);
              }

              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    String label,
    String value,
    String? selected,
    Function(String) onSelect,
  ) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.borderGold,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryGold : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}


