import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../widgets/character_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, _) {
        final favorites = provider.favorites;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Избранное'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  if (value == 'name') {
                    provider.sortFavoritesByName();
                  } else if (value == 'status') {
                    provider.sortFavoritesByStatus();
                  } else if (value == 'species') {
                    provider.sortFavoritesBySpecies();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'name', child: Text('По имени')),
                  PopupMenuItem(value: 'status', child: Text('По статусу')),
                  PopupMenuItem(value: 'species', child: Text('По виду')),
                ],
              ),
            ],
          ),
          body: favorites.isEmpty
              ? const Center(child: Text('Нет избранных персонажей'))
              : AnimatedList(
            key: _listKey,
            initialItemCount: favorites.length,
            itemBuilder: (context, index, animation) {
              if (index >= favorites.length) {
                // This guards against accessing an out-of-bounds index
                return const SizedBox.shrink();
              }

              final character = favorites[index];

              return SizeTransition(
                sizeFactor: animation,
                child: CharacterCard(
                  character: character,
                  onFavoriteRemoved: () {
                    _listKey.currentState?.removeItem(
                      index,
                          (context, animation) => SizeTransition(
                        sizeFactor: animation,
                        child: CharacterCard(character: character),
                      ),
                      duration: const Duration(milliseconds: 300),
                    );

                    // Defer list mutation to avoid index errors during rebuild
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<CharacterProvider>().removeFavorite(character);
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}