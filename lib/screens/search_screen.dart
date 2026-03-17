import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../models/mountain.dart';
import '../providers/mountain_provider.dart';
import '../widgets/mountain_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Difficulty? _selectedDifficulty;
  String? _selectedRegion;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: context.appTextSub),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체 난이도',
                  selected: _selectedDifficulty == null,
                  onTap: () => setState(() => _selectedDifficulty = null),
                ),
                const SizedBox(width: 8),
                ...Difficulty.values.map((d) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: d.label,
                    selected: _selectedDifficulty == d,
                    color: d.color,
                    onTap: () => setState(() => _selectedDifficulty = _selectedDifficulty == d ? null : d),
                  ),
                )),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '전체 지역',
                  selected: _selectedRegion == null,
                  onTap: () => setState(() => _selectedRegion = null),
                ),
                const SizedBox(width: 8),
                ...context.read<MountainProvider>().mountains.map((m) => m.location).toSet().map((r) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: r,
                    selected: _selectedRegion == r,
                    onTap: () => setState(() => _selectedRegion = _selectedRegion == r ? null : r),
                  ),
                )),
              ],
            ),
          ),

          // Results
          Expanded(
            child: Consumer<MountainProvider>(
              builder: (context, state, _) {
                final results = state.search(
                  _query,
                  difficulty: _selectedDifficulty,
                  region: _selectedRegion,
                );

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty && _selectedDifficulty == null && _selectedRegion == null
                              ? l.searchPrompt
                              : l.noSearchResults,
                          style: TextStyle(color: context.appTextSub, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mountain = results[index];
                    return GestureDetector(
                      onTap: () => context.push('/mountain/${mountain.id}'),
                      child: _SearchResultTile(mountain: mountain),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? (color ?? AppTheme.primary) : context.appSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? (color ?? AppTheme.primary) : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : context.appTextSub,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Mountain mountain;
  const _SearchResultTile({required this.mountain});

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
                Text('${mountain.location} · ${mountain.height}m · ${mountain.distance}', style: TextStyle(color: context.appTextSub, fontSize: 13)),
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
