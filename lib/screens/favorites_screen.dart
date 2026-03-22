import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../providers/favorite_provider.dart';
import '../providers/mountain_provider.dart';
import '../widgets/mountain_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.favorites),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer2<FavoriteProvider, MountainProvider>(
        builder: (context, favState, mState, _) {
          final favoriteMountains = mState.mountains
              .where((m) => favState.isFavorite(m.id))
              .toList();

          if (favoriteMountains.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: context.appTextSub,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.noFavoritesYet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.appTextSub,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: favoriteMountains.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mountain = favoriteMountains[index];
              return GestureDetector(
                onTap: () => context.push('/mountain/${mountain.id}'),
                child: _FavoriteMountainTile(mountain: mountain),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteMountainTile extends StatelessWidget {
  final Mountain mountain;
  const _FavoriteMountainTile({required this.mountain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: mountain.colors),
            ),
            child: Center(child: Text(mountain.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mountain.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: context.appText)),
                const SizedBox(height: 4),
                Text('${mountain.location} · ${mountain.height}m', style: TextStyle(color: context.appTextSub, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DifficultyTag(difficulty: mountain.difficulty),
              const SizedBox(height: 4),
              Text(mountain.time, style: TextStyle(color: context.appTextSub, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
