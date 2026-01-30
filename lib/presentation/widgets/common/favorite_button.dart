import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/barber/favorites/favorites_cubit.dart';
import '../../cubit/barber/favorites/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  final String barberId;
  final Color? color;
  final double size;

  const FavoriteButton({
    super.key,
    required this.barberId,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) {
        // Rebuild only if favorites loaded/changed
        // Or if we transition from loading/error
        return current is FavoritesLoaded;
      },
      builder: (context, state) {
        bool isFavorite = false;

        if (state is FavoritesLoaded) {
          isFavorite = state.favorites.any((barber) => barber.id == barberId);
        }

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : (color ?? Colors.grey),
            size: size,
          ),
          onPressed: () {
            context.read<FavoritesCubit>().toggleFavorite(barberId);
          },
        );
      },
    );
  }
}
