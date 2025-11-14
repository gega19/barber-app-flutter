import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/injection/injection.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../../domain/usecases/auth/get_user_stats_usecase.dart';
import '../../../data/datasources/remote/upload_remote_datasource.dart';
import 'package:dio/dio.dart';
import '../../widgets/profile/profile_header_widget.dart';
import '../../widgets/profile/profile_stats_card_widget.dart';
import '../../widgets/profile/profile_info_card_widget.dart';
import '../../widgets/profile/profile_barber_management_card_widget.dart';
import '../../widgets/profile/profile_settings_card_widget.dart';
import '../../widgets/profile/profile_others_card_widget.dart';
import '../../widgets/profile/logout_button_widget.dart';
import '../../widgets/profile/avatar_options_modal.dart';
import '../../widgets/profile/edit_field_modal.dart';
import '../../widgets/profile/delete_account_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userStats;
  bool isLoadingStats = false;
  String? _userBarberId;
  bool _isBarber = false;
  final GetUserStatsUseCase getUserStatsUseCase = GetUserStatsUseCase(sl());
  bool _isUploadingAvatar = false;
  final UploadRemoteDataSource _uploadDataSource = sl<UploadRemoteDataSource>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Actualizar perfil desde el servidor silenciosamente
    final authCubit = context.read<AuthCubit>();
    authCubit.refreshProfile();
    
    // Load data in parallel
    Future.wait([
      _loadStats(),
      _loadUserBarberId(),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizar perfil desde el servidor cuando se regrese a esta pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authCubit = context.read<AuthCubit>();
        authCubit.refreshProfile();
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
    final userEmail =
        currentState is AuthAuthenticated ? currentState.user.email : null;

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
        final matchingBarbers =
            data.where((b) => b['email'] == userEmail).toList();

        if (matchingBarbers.isNotEmpty && mounted) {
          setState(() {
            _userBarberId = matchingBarbers.first['id'] as String;
            _isBarber = true;
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
            final matchingBarbers =
                searchData.where((b) => b['email'] == userEmail).toList();

            if (matchingBarbers.isNotEmpty && mounted) {
              setState(() {
                _userBarberId = matchingBarbers.first['id'] as String;
                _isBarber = true;
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
            _isBarber = false;
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
        if (mounted) {
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
        }
      },
      (stats) {
        if (mounted) {
          setState(() {
            userStats = stats;
            isLoadingStats = false;
          });
        }
      },
    );
  }

  void _showAvatarOptions() {
    final authCubit = context.read<AuthCubit>();
    final currentState = authCubit.state;
    if (currentState is! AuthAuthenticated) return;

    final user = currentState.user;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarOptionsModal(
        hasAvatar: user.avatar != null && user.avatar!.isNotEmpty,
        onTakePhoto: () => _pickImage(ImageSource.camera),
        onChooseFromGallery: () => _pickImage(ImageSource.gallery),
        onGenerateRandom: _generateRandomAvatar,
        onRemove: user.avatar != null && user.avatar!.isNotEmpty
            ? _removeAvatar
            : null,
      ),
    );
  }

  void _showEditModal(String label, String currentValue, String fieldType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EditFieldModal(
        label: label,
        fieldType: fieldType,
        currentValue: currentValue,
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
    final randomSeed =
        '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(10000)}';
    final authCubit = context.read<AuthCubit>();

    // Clear avatar URL to force using default avatar with new seed
    await authCubit.updateProfile(avatarSeed: randomSeed, avatar: '');

    if (mounted) {
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final authCubit = context.read<AuthCubit>();

              Navigator.of(context).pop();

              await authCubit.updateProfile(avatar: '');

              if (mounted) {
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        onDelete: (password) async {
          return await context.read<AuthCubit>().deleteAccount(password: password);
        },
      ),
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
        // Reload barber ID and stats when auth state changes
        if (state is AuthAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadUserBarberId();
              _loadStats();
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
              buildWhen: (previous, current) {
                // Only rebuild when user data actually changes
                if (previous is AuthAuthenticated && current is AuthAuthenticated) {
                  final prevUser = previous.user;
                  final currUser = current.user;
                  return prevUser.id != currUser.id ||
                      prevUser.name != currUser.name ||
                      prevUser.email != currUser.email ||
                      prevUser.avatar != currUser.avatar ||
                      prevUser.avatarSeed != currUser.avatarSeed ||
                      prevUser.phone != currUser.phone ||
                      prevUser.location != currUser.location ||
                      prevUser.country != currUser.country ||
                      prevUser.gender != currUser.gender;
                }
                // Rebuild on state type changes
                return previous.runtimeType != current.runtimeType;
              },
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
                    // Header
                    SliverToBoxAdapter(
                      child: ProfileHeaderWidget(
                        user: user,
                        isUploadingAvatar: _isUploadingAvatar,
                        onAvatarTap: _showAvatarOptions,
                      ),
                    ),
                    // Stats Card
                    SliverToBoxAdapter(
                      child: ProfileStatsCardWidget(
                        stats: userStats,
                        isBarber: _isBarber,
                        loading: isLoadingStats,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Info Card
                    SliverToBoxAdapter(
                      child: ProfileInfoCardWidget(
                        user: user,
                        onEditField: _showEditModal,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Barber Management Card
                    if (_isBarber && _userBarberId != null)
                      SliverToBoxAdapter(
                        child: ProfileBarberManagementCardWidget(
                          userBarberId: _userBarberId,
                        ),
                      ),
                    if (_isBarber && _userBarberId != null)
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Settings Card
                    SliverToBoxAdapter(
                      child: ProfileSettingsCardWidget(
                        isBarber: _isBarber,
                        onDeleteAccount: _showDeleteAccountDialog,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Others Card
                    SliverToBoxAdapter(
                      child: const ProfileOthersCardWidget(),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // Logout Button
                    SliverToBoxAdapter(
                      child: const LogoutButtonWidget(),
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
}
