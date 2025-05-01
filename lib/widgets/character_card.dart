import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback? onFavoriteRemoved;

  const CharacterCard({
    super.key,
    required this.character,
    this.onFavoriteRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, _) {
        final isFavorite = provider.isFavorite(character);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(character.image)),
            title: Text(character.name),
            subtitle: Text('${character.status} · ${character.species}\n${character.location}'),
            isThreeLine: true,
            trailing: GestureDetector(
              onTap: () {
                provider.toggleFavorite(character);
                if (!provider.isFavorite(character)) {
                  onFavoriteRemoved?.call();
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite ? Colors.yellow[700] : null,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

