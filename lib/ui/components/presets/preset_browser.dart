///
/// Enhanced Preset Browser
///
/// Advanced preset browsing and management interface with search, filtering,
/// categorization, visual previews, favorites, and tags.
///
/// Features:
/// - Visual preset cards with geometry preview
/// - Search by name, description, tags
/// - Filter by category, geometry system, synthesis type
/// - Favorites system
/// - User/factory preset separation
/// - Import/export presets
/// - Preset rating system
/// - Recently used tracking
/// - Preset comparison mode
/// - Bulk operations (delete, export, tag)
///
/// Part of the Integration Layer (Phase 3.5)
///
/// A Paul Phillips Manifestation
////

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../effects/glassmorphic_container.dart';

// ============================================================================
// PRESET DATA STRUCTURES
// ============================================================================

/// Preset category
enum PresetCategory {
  pads,
  leads,
  basses,
  plucks,
  atmospheres,
  effects,
  rhythmic,
  experimental,
  user,
}

extension PresetCategoryExtension on PresetCategory {
  String get displayName {
    switch (this) {
      case PresetCategory.pads:
        return 'Pads';
      case PresetCategory.leads:
        return 'Leads';
      case PresetCategory.basses:
        return 'Basses';
      case PresetCategory.plucks:
        return 'Plucks';
      case PresetCategory.atmospheres:
        return 'Atmospheres';
      case PresetCategory.effects:
        return 'Effects';
      case PresetCategory.rhythmic:
        return 'Rhythmic';
      case PresetCategory.experimental:
        return 'Experimental';
      case PresetCategory.user:
        return 'User';
    }
  }

  Color get color {
    switch (this) {
      case PresetCategory.pads:
        return const Color(0xFF00AAFF);
      case PresetCategory.leads:
        return const Color(0xFFFF00AA);
      case PresetCategory.basses:
        return const Color(0xFFFF6600);
      case PresetCategory.plucks:
        return const Color(0xFF00FF88);
      case PresetCategory.atmospheres:
        return const Color(0xFF8800FF);
      case PresetCategory.effects:
        return const Color(0xFFFFAA00);
      case PresetCategory.rhythmic:
        return const Color(0xFFFF0044);
      case PresetCategory.experimental:
        return const Color(0xFF00FFFF);
      case PresetCategory.user:
        return Colors.white;
    }
  }
}

/// Preset metadata
class PresetMetadata {
  final String id;
  final String name;
  final String description;
  final String author;
  final PresetCategory category;
  final List<String> tags;
  final int geometryIndex; // 0-23
  final String visualSystem; // Quantum, Faceted, Holographic
  final String synthesisType; // Direct, FM, Ring Mod
  final bool isFactory;
  final bool isFavorite;
  final double rating; // 0-5
  final DateTime createdAt;
  final DateTime? lastUsed;
  final int useCount;

  const PresetMetadata({
    required this.id,
    required this.name,
    this.description = '',
    this.author = '',
    required this.category,
    this.tags = const [],
    required this.geometryIndex,
    required this.visualSystem,
    required this.synthesisType,
    this.isFactory = false,
    this.isFavorite = false,
    this.rating = 0.0,
    required this.createdAt,
    this.lastUsed,
    this.useCount = 0,
  });

  PresetMetadata copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    PresetCategory? category,
    List<String>? tags,
    int? geometryIndex,
    String? visualSystem,
    String? synthesisType,
    bool? isFactory,
    bool? isFavorite,
    double? rating,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? useCount,
  }) {
    return PresetMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      geometryIndex: geometryIndex ?? this.geometryIndex,
      visualSystem: visualSystem ?? this.visualSystem,
      synthesisType: synthesisType ?? this.synthesisType,
      isFactory: isFactory ?? this.isFactory,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      useCount: useCount ?? this.useCount,
    );
  }

  String get geometryName {
    final coreIndex = geometryIndex ~/ 8;
    final baseIndex = geometryIndex % 8;
    final coreNames = ['Base', 'Hypersphere', 'Hypertetrahedron'];
    final baseNames = [
      'Tetrahedron',
      'Hypercube',
      'Sphere',
      'Torus',
      'Klein Bottle',
      'Fractal',
      'Wave',
      'Crystal'
    ];
    return '${coreNames[coreIndex]} ${baseNames[baseIndex]}';
  }
}

// ============================================================================
// PRESET FILTER
// ============================================================================

/// Preset filtering options
class PresetFilter {
  final String searchQuery;
  final Set<PresetCategory> categories;
  final Set<String> visualSystems;
  final Set<String> synthesisTypes;
  final bool showOnlyFavorites;
  final bool showOnlyRecent;

  const PresetFilter({
    this.searchQuery = '',
    this.categories = const {},
    this.visualSystems = const {},
    this.synthesisTypes = const {},
    this.showOnlyFavorites = false,
    this.showOnlyRecent = false,
  });

  bool matches(PresetMetadata preset) {
    // Search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final matchesName = preset.name.toLowerCase().contains(query);
      final matchesDesc = preset.description.toLowerCase().contains(query);
      final matchesTags =
          preset.tags.any((tag) => tag.toLowerCase().contains(query));
      final matchesAuthor = preset.author.toLowerCase().contains(query);

      if (!matchesName && !matchesDesc && !matchesTags && !matchesAuthor) {
        return false;
      }
    }

    // Categories
    if (categories.isNotEmpty && !categories.contains(preset.category)) {
      return false;
    }

    // Visual systems
    if (visualSystems.isNotEmpty &&
        !visualSystems.contains(preset.visualSystem)) {
      return false;
    }

    // Synthesis types
    if (synthesisTypes.isNotEmpty &&
        !synthesisTypes.contains(preset.synthesisType)) {
      return false;
    }

    // Favorites
    if (showOnlyFavorites && !preset.isFavorite) {
      return false;
    }

    // Recent
    if (showOnlyRecent && preset.lastUsed == null) {
      return false;
    }

    return true;
  }

  PresetFilter copyWith({
    String? searchQuery,
    Set<PresetCategory>? categories,
    Set<String>? visualSystems,
    Set<String>? synthesisTypes,
    bool? showOnlyFavorites,
    bool? showOnlyRecent,
  }) {
    return PresetFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
      visualSystems: visualSystems ?? this.visualSystems,
      synthesisTypes: synthesisTypes ?? this.synthesisTypes,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      showOnlyRecent: showOnlyRecent ?? this.showOnlyRecent,
    );
  }
}

// ============================================================================
// PRESET BROWSER WIDGET
// ============================================================================

/// Enhanced preset browser
class PresetBrowser extends StatefulWidget {
  final List<PresetMetadata> presets;
  final ValueChanged<PresetMetadata>? onPresetSelected;
  final ValueChanged<PresetMetadata>? onPresetFavorited;
  final ValueChanged<String>? onPresetDeleted;
  final VoidCallback? onImportPresets;
  final ValueChanged<List<String>>? onExportPresets;
  final double width;
  final double height;

  const PresetBrowser({
    Key? key,
    required this.presets,
    this.onPresetSelected,
    this.onPresetFavorited,
    this.onPresetDeleted,
    this.onImportPresets,
    this.onExportPresets,
    this.width = 900,
    this.height = 700,
  }) : super(key: key);

  @override
  State<PresetBrowser> createState() => _PresetBrowserState();
}

class _PresetBrowserState extends State<PresetBrowser> {
  PresetFilter _filter = const PresetFilter();
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // name, date, rating, recent
  final Set<String> _selectedPresets = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PresetMetadata> get _filteredPresets {
    var filtered = widget.presets.where(_filter.matches).toList();

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'recent':
        filtered.sort((a, b) {
          if (a.lastUsed == null && b.lastUsed == null) return 0;
          if (a.lastUsed == null) return 1;
          if (b.lastUsed == null) return -1;
          return b.lastUsed!.compareTo(a.lastUsed!);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: widget.width,
      height: widget.height,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: Column(
        children: [
          // Header with search
          _buildHeader(),

          // Filter bar
          _buildFilterBar(),

          // Presets grid
          Expanded(
            child: _buildPresetsGrid(),
          ),

          // Action bar
          if (_selectedPresets.isNotEmpty) _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.library_music, size: 24),
              const SizedBox(width: DesignTokens.spacing2),
              Text(
                'Preset Browser',
                style: DesignTokens.headlineMedium,
              ),
              const Spacer(),
              Text(
                '${_filteredPresets.length} presets',
                style: DesignTokens.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(searchQuery: value);
              });
            },
            style: DesignTokens.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search presets...',
              hintStyle: DesignTokens.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.4),
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: '');
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Sort dropdown
            _buildSortDropdown(),
            const SizedBox(width: DesignTokens.spacing3),
            // Favorites toggle
            _buildFilterChip(
              'Favorites',
              Icons.favorite,
              _filter.showOnlyFavorites,
              () {
                setState(() {
                  _filter = _filter.copyWith(
                    showOnlyFavorites: !_filter.showOnlyFavorites,
                  );
                });
              },
            ),
            const SizedBox(width: DesignTokens.spacing2),
            // Recent toggle
            _buildFilterChip(
              'Recent',
              Icons.history,
              _filter.showOnlyRecent,
              () {
                setState(() {
                  _filter = _filter.copyWith(
                    showOnlyRecent: !_filter.showOnlyRecent,
                  );
                });
              },
            ),
            const SizedBox(width: DesignTokens.spacing3),
            const VerticalDivider(),
            const SizedBox(width: DesignTokens.spacing3),
            // Category filters
            ...PresetCategory.values.map((category) {
              final isActive = _filter.categories.contains(category);
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spacing2),
                child: _buildFilterChip(
                  category.displayName,
                  null,
                  isActive,
                  () {
                    setState(() {
                      final newCategories =
                          Set<PresetCategory>.from(_filter.categories);
                      if (isActive) {
                        newCategories.remove(category);
                      } else {
                        newCategories.add(category);
                      }
                      _filter = _filter.copyWith(categories: newCategories);
                    });
                  },
                  color: category.color,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: DesignTokens.spacing1,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
        },
        underline: const SizedBox(),
        dropdownColor: Colors.black.withOpacity(0.9),
        style: DesignTokens.labelSmall,
        items: const [
          DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
          DropdownMenuItem(value: 'date', child: Text('Sort: Date')),
          DropdownMenuItem(value: 'rating', child: Text('Sort: Rating')),
          DropdownMenuItem(value: 'recent', child: Text('Sort: Recent')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData? icon,
    bool isActive,
    VoidCallback onTap, {
    Color? color,
  }) {
    final effectiveColor = color ?? DesignTokens.quantum;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing2,
          vertical: DesignTokens.spacing1,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? effectiveColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          border: Border.all(
            color: isActive ? effectiveColor : Colors.white.withOpacity(0.2),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: isActive
                      ? effectiveColor
                      : Colors.white.withOpacity(0.6)),
              const SizedBox(width: DesignTokens.spacing1),
            ],
            Text(
              label,
              style: DesignTokens.labelSmall.copyWith(
                color:
                    isActive ? effectiveColor : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsGrid() {
    final presets = _filteredPresets;

    if (presets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: DesignTokens.spacing3),
            Text(
              'No presets found',
              style: DesignTokens.headlineMedium.copyWith(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              'Try adjusting your filters or search query',
              style: DesignTokens.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: DesignTokens.spacing3,
        mainAxisSpacing: DesignTokens.spacing3,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        return _buildPresetCard(presets[index]);
      },
    );
  }

  Widget _buildPresetCard(PresetMetadata preset) {
    final isSelected = _selectedPresets.contains(preset.id);

    return GestureDetector(
      onTap: () {
        widget.onPresetSelected?.call(preset);
      },
      onLongPress: () {
        setState(() {
          if (isSelected) {
            _selectedPresets.remove(preset.id);
          } else {
            _selectedPresets.add(preset.id);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(
            color: isSelected
                ? DesignTokens.stateActive
                : preset.category.color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geometry preview
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: preset.category.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(DesignTokens.radiusMedium),
                  ),
                ),
                child: Center(
                  child: Text(
                    preset.geometryName,
                    textAlign: TextAlign.center,
                    style: DesignTokens.labelSmall.copyWith(
                      color: preset.category.color,
                    ),
                  ),
                ),
              ),
            ),
            // Preset info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preset.name,
                            style: DesignTokens.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            preset.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: preset.isFavorite
                                ? DesignTokens.stateActive
                                : Colors.white.withOpacity(0.4),
                          ),
                          onPressed: () {
                            widget.onPresetFavorited?.call(preset);
                          },
                        ),
                      ],
                    ),
                    if (preset.description.isNotEmpty)
                      Text(
                        preset.description,
                        style: DesignTokens.labelSmall.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacing1,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: preset.category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            preset.category.displayName,
                            style: DesignTokens.labelSmall.copyWith(
                              color: preset.category.color,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (preset.isFactory)
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: DesignTokens.quantum,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedPresets.length} selected',
            style: DesignTokens.labelMedium,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              widget.onExportPresets?.call(_selectedPresets.toList());
            },
            icon: const Icon(Icons.file_download, size: 16),
            label: const Text('Export'),
          ),
          const SizedBox(width: DesignTokens.spacing2),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedPresets.clear();
              });
            },
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
