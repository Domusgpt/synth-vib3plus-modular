/**
 * Comprehensive Preset Management System
 *
 * Features:
 * - Complete synthesizer state serialization
 * - Preset categories and tags
 * - Search and filter
 * - Factory presets + user presets
 * - Cloud sync ready (Firebase integration)
 * - Import/export
 *
 * A Paul Phillips Manifestation
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Complete synthesizer preset
class SynthPreset {
  // Metadata
  final String id;
  final String name;
  final String description;
  final String category; // Lead, Pad, Bass, FX, etc.
  final List<String> tags;
  final String author;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isFactory; // Factory vs user preset
  final int rating; // 0-5 stars

  // Visual system
  final String visualSystem; // Quantum, Faceted, Holographic
  final int geometry; // 0-23

  // Audio parameters
  final AudioPresetData audio;

  // Visual parameters
  final VisualPresetData visual;

  // Mapping configuration
  final MappingPresetData mapping;

  SynthPreset({
    required this.id,
    required this.name,
    this.description = '',
    this.category = 'Uncategorized',
    this.tags = const [],
    this.author = 'User',
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.isFactory = false,
    this.rating = 0,
    required this.visualSystem,
    required this.geometry,
    required this.audio,
    required this.visual,
    required this.mapping,
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'tags': tags,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'isFactory': isFactory,
      'rating': rating,
      'visualSystem': visualSystem,
      'geometry': geometry,
      'audio': audio.toJson(),
      'visual': visual.toJson(),
      'mapping': mapping.toJson(),
    };
  }

  /// Create from JSON
  factory SynthPreset.fromJson(Map<String, dynamic> json) {
    return SynthPreset(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      tags: List<String>.from(json['tags'] ?? []),
      author: json['author'] ?? 'User',
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      isFactory: json['isFactory'] ?? false,
      rating: json['rating'] ?? 0,
      visualSystem: json['visualSystem'],
      geometry: json['geometry'],
      audio: AudioPresetData.fromJson(json['audio']),
      visual: VisualPresetData.fromJson(json['visual']),
      mapping: MappingPresetData.fromJson(json['mapping']),
    );
  }

  /// Create a copy with modifications
  SynthPreset copyWith({
    String? name,
    String? description,
    String? category,
    List<String>? tags,
    int? rating,
    String? visualSystem,
    int? geometry,
    AudioPresetData? audio,
    VisualPresetData? visual,
    MappingPresetData? mapping,
  }) {
    return SynthPreset(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      author: author,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
      isFactory: isFactory,
      rating: rating ?? this.rating,
      visualSystem: visualSystem ?? this.visualSystem,
      geometry: geometry ?? this.geometry,
      audio: audio ?? this.audio,
      visual: visual ?? this.visual,
      mapping: mapping ?? this.mapping,
    );
  }
}

/// Audio parameters for preset
class AudioPresetData {
  // Oscillators
  final double osc1Waveform; // 0-1 for morphing
  final double osc2Waveform;
  final double oscMix;
  final double osc1Detune;
  final double osc2Detune;
  final double pulseWidth;

  // Filter
  final String filterType; // lowpass, highpass, bandpass, notch
  final double filterCutoff;
  final double filterResonance;
  final double filterEnvelopeAmount;

  // Envelope
  final double attack;
  final double decay;
  final double sustain;
  final double release;

  // Effects
  final double reverbMix;
  final double reverbRoomSize;
  final double reverbDamping;
  final double delayTime;
  final double delayFeedback;
  final double delayMix;

  // Modulation
  final double pitchBendRange; // In semitones
  final double vibratoDepth;
  final double noiseAmount;

  // LFO settings
  final List<LFOPresetData> lfos;

  // Master
  final double masterVolume;
  final double stereoWidth;

  const AudioPresetData({
    this.osc1Waveform = 0.5,
    this.osc2Waveform = 0.5,
    this.oscMix = 0.5,
    this.osc1Detune = 0.0,
    this.osc2Detune = 0.0,
    this.pulseWidth = 0.5,
    this.filterType = 'lowpass',
    this.filterCutoff = 1000.0,
    this.filterResonance = 0.0,
    this.filterEnvelopeAmount = 0.0,
    this.attack = 0.01,
    this.decay = 0.1,
    this.sustain = 0.7,
    this.release = 0.3,
    this.reverbMix = 0.3,
    this.reverbRoomSize = 0.5,
    this.reverbDamping = 0.5,
    this.delayTime = 250.0,
    this.delayFeedback = 0.4,
    this.delayMix = 0.3,
    this.pitchBendRange = 2.0,
    this.vibratoDepth = 0.0,
    this.noiseAmount = 0.0,
    this.lfos = const [],
    this.masterVolume = 0.7,
    this.stereoWidth = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'osc1Waveform': osc1Waveform,
        'osc2Waveform': osc2Waveform,
        'oscMix': oscMix,
        'osc1Detune': osc1Detune,
        'osc2Detune': osc2Detune,
        'pulseWidth': pulseWidth,
        'filterType': filterType,
        'filterCutoff': filterCutoff,
        'filterResonance': filterResonance,
        'filterEnvelopeAmount': filterEnvelopeAmount,
        'attack': attack,
        'decay': decay,
        'sustain': sustain,
        'release': release,
        'reverbMix': reverbMix,
        'reverbRoomSize': reverbRoomSize,
        'reverbDamping': reverbDamping,
        'delayTime': delayTime,
        'delayFeedback': delayFeedback,
        'delayMix': delayMix,
        'pitchBendRange': pitchBendRange,
        'vibratoDepth': vibratoDepth,
        'noiseAmount': noiseAmount,
        'lfos': lfos.map((lfo) => lfo.toJson()).toList(),
        'masterVolume': masterVolume,
        'stereoWidth': stereoWidth,
      };

  factory AudioPresetData.fromJson(Map<String, dynamic> json) {
    return AudioPresetData(
      osc1Waveform: json['osc1Waveform'] ?? 0.5,
      osc2Waveform: json['osc2Waveform'] ?? 0.5,
      oscMix: json['oscMix'] ?? 0.5,
      osc1Detune: json['osc1Detune'] ?? 0.0,
      osc2Detune: json['osc2Detune'] ?? 0.0,
      pulseWidth: json['pulseWidth'] ?? 0.5,
      filterType: json['filterType'] ?? 'lowpass',
      filterCutoff: json['filterCutoff'] ?? 1000.0,
      filterResonance: json['filterResonance'] ?? 0.0,
      filterEnvelopeAmount: json['filterEnvelopeAmount'] ?? 0.0,
      attack: json['attack'] ?? 0.01,
      decay: json['decay'] ?? 0.1,
      sustain: json['sustain'] ?? 0.7,
      release: json['release'] ?? 0.3,
      reverbMix: json['reverbMix'] ?? 0.3,
      reverbRoomSize: json['reverbRoomSize'] ?? 0.5,
      reverbDamping: json['reverbDamping'] ?? 0.5,
      delayTime: json['delayTime'] ?? 250.0,
      delayFeedback: json['delayFeedback'] ?? 0.4,
      delayMix: json['delayMix'] ?? 0.3,
      pitchBendRange: json['pitchBendRange'] ?? 2.0,
      vibratoDepth: json['vibratoDepth'] ?? 0.0,
      noiseAmount: json['noiseAmount'] ?? 0.0,
      lfos: (json['lfos'] as List?)
              ?.map((lfo) => LFOPresetData.fromJson(lfo))
              .toList() ??
          [],
      masterVolume: json['masterVolume'] ?? 0.7,
      stereoWidth: json['stereoWidth'] ?? 1.0,
    );
  }
}

/// LFO preset data
class LFOPresetData {
  final double frequency;
  final String waveform; // sine, triangle, square, sawtooth, random
  final double depth;
  final double offset;
  final bool retrigger;

  const LFOPresetData({
    this.frequency = 5.0,
    this.waveform = 'sine',
    this.depth = 1.0,
    this.offset = 0.0,
    this.retrigger = false,
  });

  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'waveform': waveform,
        'depth': depth,
        'offset': offset,
        'retrigger': retrigger,
      };

  factory LFOPresetData.fromJson(Map<String, dynamic> json) {
    return LFOPresetData(
      frequency: json['frequency'] ?? 5.0,
      waveform: json['waveform'] ?? 'sine',
      depth: json['depth'] ?? 1.0,
      offset: json['offset'] ?? 0.0,
      retrigger: json['retrigger'] ?? false,
    );
  }
}

/// Visual parameters for preset
class VisualPresetData {
  // 4D rotation speeds
  final double rotationSpeedXY;
  final double rotationSpeedXZ;
  final double rotationSpeedYZ;
  final double rotationSpeedXW;
  final double rotationSpeedYW;
  final double rotationSpeedZW;

  // Visual parameters
  final double morph;
  final double chaos;
  final double gridDensity;
  final double hue;
  final double intensity;
  final double intensity;
  final double dimension;
  final double layerDepth;

  const VisualPresetData({
    this.rotationSpeedXY = 0.5,
    this.rotationSpeedXZ = 0.3,
    this.rotationSpeedYZ = 0.2,
    this.rotationSpeedXW = 0.1,
    this.rotationSpeedYW = 0.15,
    this.rotationSpeedZW = 0.25,
    this.morph = 0.0,
    this.chaos = 0.0,
    this.gridDensity = 5.0,
    this.hue = 0.0,
    this.intensity = 1.0,
    this.intensity = 1.0,
    this.dimension = 2.0,
    this.layerDepth = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'rotationSpeedXY': rotationSpeedXY,
        'rotationSpeedXZ': rotationSpeedXZ,
        'rotationSpeedYZ': rotationSpeedYZ,
        'rotationSpeedXW': rotationSpeedXW,
        'rotationSpeedYW': rotationSpeedYW,
        'rotationSpeedZW': rotationSpeedZW,
        'morph': morph,
        'chaos': chaos,
        'gridDensity': gridDensity,
        'hue': hue,
        'intensity': intensity,
        'intensity': intensity,
        'dimension': dimension,
        'layerDepth': layerDepth,
      };

  factory VisualPresetData.fromJson(Map<String, dynamic> json) {
    return VisualPresetData(
      rotationSpeedXY: json['rotationSpeedXY'] ?? 0.5,
      rotationSpeedXZ: json['rotationSpeedXZ'] ?? 0.3,
      rotationSpeedYZ: json['rotationSpeedYZ'] ?? 0.2,
      rotationSpeedXW: json['rotationSpeedXW'] ?? 0.1,
      rotationSpeedYW: json['rotationSpeedYW'] ?? 0.15,
      rotationSpeedZW: json['rotationSpeedZW'] ?? 0.25,
      morph: json['morph'] ?? 0.0,
      chaos: json['chaos'] ?? 0.0,
      gridDensity: json['gridDensity'] ?? 5.0,
      hue: json['hue'] ?? 0.0,
      intensity: json['intensity'] ?? 1.0,
      intensity: json['intensity'] ?? 1.0,
      dimension: json['dimension'] ?? 2.0,
      layerDepth: json['layerDepth'] ?? 0.5,
    );
  }
}

/// Mapping configuration for preset
class MappingPresetData {
  final bool audioToVisualEnabled;
  final bool visualToAudioEnabled;
  final double audioToVisualStrength; // 0-2, 1=normal
  final double visualToAudioStrength;

  // Individual mapping enables
  final Map<String, bool> mappingEnabled;

  const MappingPresetData({
    this.audioToVisualEnabled = true,
    this.visualToAudioEnabled = true,
    this.audioToVisualStrength = 1.0,
    this.visualToAudioStrength = 1.0,
    this.mappingEnabled = const {},
  });

  Map<String, dynamic> toJson() => {
        'audioToVisualEnabled': audioToVisualEnabled,
        'visualToAudioEnabled': visualToAudioEnabled,
        'audioToVisualStrength': audioToVisualStrength,
        'visualToAudioStrength': visualToAudioStrength,
        'mappingEnabled': mappingEnabled,
      };

  factory MappingPresetData.fromJson(Map<String, dynamic> json) {
    return MappingPresetData(
      audioToVisualEnabled: json['audioToVisualEnabled'] ?? true,
      visualToAudioEnabled: json['visualToAudioEnabled'] ?? true,
      audioToVisualStrength: json['audioToVisualStrength'] ?? 1.0,
      visualToAudioStrength: json['visualToAudioStrength'] ?? 1.0,
      mappingEnabled:
          Map<String, bool>.from(json['mappingEnabled'] ?? {}),
    );
  }
}

/// Preset manager with search and filter
class PresetManager extends ChangeNotifier {
  final List<SynthPreset> _presets = [];
  SynthPreset? _currentPreset;

  // Filters
  String _searchQuery = '';
  String? _categoryFilter;
  List<String> _tagFilters = [];
  bool _showFactoryOnly = false;
  bool _showUserOnly = false;

  List<SynthPreset> get presets => _getFilteredPresets();
  SynthPreset? get currentPreset => _currentPreset;

  /// Add preset
  void addPreset(SynthPreset preset) {
    _presets.add(preset);
    notifyListeners();
  }

  /// Remove preset
  void removePreset(String id) {
    _presets.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Update preset
  void updatePreset(SynthPreset preset) {
    final index = _presets.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      _presets[index] = preset;
      if (_currentPreset?.id == preset.id) {
        _currentPreset = preset;
      }
      notifyListeners();
    }
  }

  /// Load preset
  void loadPreset(String id) {
    _currentPreset = _presets.firstWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Search presets
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Filter by category
  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  /// Filter by tags
  void setTagFilters(List<String> tags) {
    _tagFilters = tags;
    notifyListeners();
  }

  /// Toggle factory/user filter
  void setFactoryFilter(bool showFactory) {
    _showFactoryOnly = showFactory;
    notifyListeners();
  }

  void setUserFilter(bool showUser) {
    _showUserOnly = showUser;
    notifyListeners();
  }

  /// Get filtered presets
  List<SynthPreset> _getFilteredPresets() {
    return _presets.where((preset) {
      // Search query
      if (_searchQuery.isNotEmpty) {
        if (!preset.name.toLowerCase().contains(_searchQuery) &&
            !preset.description.toLowerCase().contains(_searchQuery) &&
            !preset.category.toLowerCase().contains(_searchQuery)) {
          return false;
        }
      }

      // Category filter
      if (_categoryFilter != null && preset.category != _categoryFilter) {
        return false;
      }

      // Tag filters
      if (_tagFilters.isNotEmpty) {
        if (!_tagFilters.any((tag) => preset.tags.contains(tag))) {
          return false;
        }
      }

      // Factory/user filter
      if (_showFactoryOnly && !preset.isFactory) return false;
      if (_showUserOnly && preset.isFactory) return false;

      return true;
    }).toList();
  }

  /// Get all categories
  Set<String> get allCategories {
    return _presets.map((p) => p.category).toSet();
  }

  /// Get all tags
  Set<String> get allTags {
    return _presets.expand((p) => p.tags).toSet();
  }

  /// Export preset to JSON string
  String exportPreset(String id) {
    final preset = _presets.firstWhere((p) => p.id == id);
    return jsonEncode(preset.toJson());
  }

  /// Import preset from JSON string
  void importPreset(String jsonString) {
    final preset = SynthPreset.fromJson(jsonDecode(jsonString));
    addPreset(preset);
  }

  /// Save all presets (implement with SharedPreferences or Firebase)
  Future<void> savePresets() async {
    // TODO: Implement persistence
    debugPrint('💾 Saving ${_presets.length} presets');
  }

  /// Load all presets (implement with SharedPreferences or Firebase)
  Future<void> loadPresets() async {
    // TODO: Implement persistence
    debugPrint('📂 Loading presets');
  }
}

/// Factory presets for initialization
class FactoryPresets {
  /// Create default factory presets
  static List<SynthPreset> getFactoryPresets() {
    return [
      _createPreset(
        name: 'Init Patch',
        description: 'Basic initialization preset',
        category: 'Init',
        tags: ['basic', 'default'],
        visualSystem: 'quantum',
        geometry: 0,
      ),
      _createPreset(
        name: 'Deep Bass',
        description: 'Powerful sub bass with slow attack',
        category: 'Bass',
        tags: ['bass', 'sub', 'deep'],
        visualSystem: 'holographic',
        geometry: 16,
        audio: const AudioPresetData(
          filterCutoff: 200.0,
          filterResonance: 0.6,
          attack: 0.05,
          release: 0.5,
        ),
      ),
      _createPreset(
        name: 'Bright Lead',
        description: 'Cutting lead sound with fast attack',
        category: 'Lead',
        tags: ['lead', 'bright', 'aggressive'],
        visualSystem: 'faceted',
        geometry: 7,
        audio: const AudioPresetData(
          filterCutoff: 8000.0,
          filterResonance: 0.3,
          attack: 0.001,
          release: 0.1,
        ),
      ),
      _createPreset(
        name: 'Lush Pad',
        description: 'Evolving pad with reverb',
        category: 'Pad',
        tags: ['pad', 'ambient', 'evolving'],
        visualSystem: 'holographic',
        geometry: 11,
        audio: const AudioPresetData(
          filterCutoff: 3000.0,
          attack: 1.5,
          release: 2.0,
          reverbMix: 0.6,
        ),
      ),
      _createPreset(
        name: 'Pluck Synth',
        description: 'Short percussive pluck',
        category: 'Pluck',
        tags: ['pluck', 'percussive', 'short'],
        visualSystem: 'quantum',
        geometry: 7,
        audio: const AudioPresetData(
          attack: 0.001,
          decay: 0.3,
          sustain: 0.0,
          release: 0.2,
          filterEnvelopeAmount: 0.8,
        ),
      ),
    ];
  }

  static SynthPreset _createPreset({
    required String name,
    required String description,
    required String category,
    required List<String> tags,
    required String visualSystem,
    required int geometry,
    AudioPresetData audio = const AudioPresetData(),
  }) {
    return SynthPreset(
      id: 'factory_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name,
      description: description,
      category: category,
      tags: tags,
      author: 'Paul Phillips',
      isFactory: true,
      visualSystem: visualSystem,
      geometry: geometry,
      audio: audio,
      visual: const VisualPresetData(),
      mapping: const MappingPresetData(),
    );
  }
}
