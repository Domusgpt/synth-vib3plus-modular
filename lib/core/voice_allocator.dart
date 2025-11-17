///
/// Voice Allocator - Intelligent Polyphony Management
///
/// Professional voice allocation system with:
/// - Velocity-based voice stealing (steal quieter notes first)
/// - Age-based secondary stealing (steal oldest among equal velocity)
/// - Dual indexing for O(1) lookups
/// - Configurable polyphony (1-64 voices)
/// - Proper MIDI note tracking
///
/// Adopted from synther-refactored architecture
/// A Paul Phillips Manifestation
///

library;

/// Voice state for polyphony management
class VoiceState {
  final int voiceId;
  final int note;
  final double velocity;
  final DateTime startedAt;
  final bool released;
  final DateTime? releasedAt;

  const VoiceState({
    required this.voiceId,
    required this.note,
    required this.velocity,
    required this.startedAt,
    this.released = false,
    this.releasedAt,
  });

  /// Copy with modifications
  VoiceState copyWith({
    int? voiceId,
    int? note,
    double? velocity,
    DateTime? startedAt,
    bool? released,
    DateTime? releasedAt,
  }) {
    return VoiceState(
      voiceId: voiceId ?? this.voiceId,
      note: note ?? this.note,
      velocity: velocity ?? this.velocity,
      startedAt: startedAt ?? this.startedAt,
      released: released ?? this.released,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }

  @override
  String toString() {
    return 'Voice($voiceId, note=$note, vel=${velocity.toStringAsFixed(2)}, '
        'released=$released)';
  }
}

/// Voice allocation result
class VoiceAllocation {
  final VoiceState voice;
  final List<VoiceState> stolenVoices;

  const VoiceAllocation({
    required this.voice,
    this.stolenVoices = const [],
  });

  bool get hasStolen => stolenVoices.isNotEmpty;
}

/// Voice allocator with intelligent stealing
class VoiceAllocator {
  final int maxVoices;

  // Dual indexing for efficient lookups
  final Map<int, VoiceState> _voicesById = {};
  final Map<int, Set<int>> _voicesByNote = {}; // MIDI note → voice IDs

  int _nextVoiceId = 0;

  static const double velocityEpsilon = 1e-9;

  VoiceAllocator({this.maxVoices = 16}) {
    if (maxVoices < 1 || maxVoices > 64) {
      throw ArgumentError('maxVoices must be between 1 and 64');
    }
  }

  /// Allocate a voice for a new note
  VoiceAllocation allocate(int note, double velocity) {
    final clampedVelocity = velocity.clamp(0.0, 1.0);
    final now = DateTime.now();

    // Try to find an inactive voice (released or completed envelope)
    for (final voice in _voicesById.values) {
      if (voice.released) {
        // Reuse this voice
        final newVoice = _createVoice(note, clampedVelocity, now);
        _replaceVoice(voice.voiceId, newVoice);
        return VoiceAllocation(voice: newVoice);
      }
    }

    // If we haven't reached max voices, create a new one
    if (_voicesById.length < maxVoices) {
      final newVoice = _createVoice(note, clampedVelocity, now);
      _addVoice(newVoice);
      return VoiceAllocation(voice: newVoice);
    }

    // Need to steal a voice - select victim using intelligent algorithm
    final victim = _selectVoiceToSteal();
    if (victim == null) {
      // Shouldn't happen, but fallback to creating new voice
      final newVoice = _createVoice(note, clampedVelocity, now);
      _addVoice(newVoice);
      return VoiceAllocation(voice: newVoice);
    }

    // Steal the victim voice
    final newVoice = _createVoice(note, clampedVelocity, now);
    _replaceVoice(victim.voiceId, newVoice);

    return VoiceAllocation(
      voice: newVoice,
      stolenVoices: [victim],
    );
  }

  /// Release a voice for a specific note
  VoiceState? release(int note, {int? specificVoiceId}) {
    if (specificVoiceId != null) {
      final voice = _voicesById[specificVoiceId];
      if (voice != null && voice.note == note && !voice.released) {
        final releasedVoice = voice.copyWith(
          released: true,
          releasedAt: DateTime.now(),
        );
        _voicesById[specificVoiceId] = releasedVoice;
        return releasedVoice;
      }
      return null;
    }

    // Release most recent voice for this note
    final voiceIds = _voicesByNote[note];
    if (voiceIds == null || voiceIds.isEmpty) return null;

    // Find most recent unreleased voice for this note
    VoiceState? mostRecent;
    for (final voiceId in voiceIds) {
      final voice = _voicesById[voiceId];
      if (voice != null && !voice.released) {
        if (mostRecent == null ||
            voice.startedAt.isAfter(mostRecent.startedAt)) {
          mostRecent = voice;
        }
      }
    }

    if (mostRecent != null) {
      final releasedVoice = mostRecent.copyWith(
        released: true,
        releasedAt: DateTime.now(),
      );
      _voicesById[mostRecent.voiceId] = releasedVoice;
      return releasedVoice;
    }

    return null;
  }

  /// Release all voices
  void releaseAll() {
    final now = DateTime.now();
    for (final voiceId in _voicesById.keys.toList()) {
      final voice = _voicesById[voiceId]!;
      if (!voice.released) {
        _voicesById[voiceId] = voice.copyWith(
          released: true,
          releasedAt: now,
        );
      }
    }
  }

  /// Get all active (unreleased) voices
  List<VoiceState> getActiveVoices() {
    return _voicesById.values.where((v) => !v.released).toList();
  }

  /// Get all voices for a specific note
  List<VoiceState> getVoicesForNote(int note) {
    final voiceIds = _voicesByNote[note];
    if (voiceIds == null) return [];
    return voiceIds
        .map((id) => _voicesById[id])
        .whereType<VoiceState>()
        .toList();
  }

  /// Get active voice count
  int get activeVoiceCount {
    return _voicesById.values.where((v) => !v.released).length;
  }

  /// Get total voice count (including released but still sounding)
  int get totalVoiceCount => _voicesById.length;

  /// Remove completed voices (garbage collection)
  void removeCompletedVoices() {
    final now = DateTime.now();
    final completionThreshold = Duration(seconds: 5); // 5 seconds after release

    final toRemove = <int>[];
    for (final voice in _voicesById.values) {
      if (voice.released && voice.releasedAt != null) {
        final timeSinceRelease = now.difference(voice.releasedAt!);
        if (timeSinceRelease > completionThreshold) {
          toRemove.add(voice.voiceId);
        }
      }
    }

    for (final voiceId in toRemove) {
      _removeVoice(voiceId);
    }
  }

  /// Create a new voice state
  VoiceState _createVoice(int note, double velocity, DateTime now) {
    return VoiceState(
      voiceId: _nextVoiceId++,
      note: note,
      velocity: velocity,
      startedAt: now,
      released: false,
    );
  }

  /// Add voice to internal structures
  void _addVoice(VoiceState voice) {
    _voicesById[voice.voiceId] = voice;
    _voicesByNote.putIfAbsent(voice.note, () => {}).add(voice.voiceId);
  }

  /// Replace voice (used for stealing)
  void _replaceVoice(int oldVoiceId, VoiceState newVoice) {
    final oldVoice = _voicesById[oldVoiceId];
    if (oldVoice != null) {
      // Remove old voice from note index
      _voicesByNote[oldVoice.note]?.remove(oldVoiceId);
      if (_voicesByNote[oldVoice.note]?.isEmpty ?? false) {
        _voicesByNote.remove(oldVoice.note);
      }
    }

    // Add new voice
    _voicesById[oldVoiceId] = newVoice.copyWith(voiceId: oldVoiceId);
    _voicesByNote.putIfAbsent(newVoice.note, () => {}).add(oldVoiceId);
  }

  /// Remove voice from internal structures
  void _removeVoice(int voiceId) {
    final voice = _voicesById.remove(voiceId);
    if (voice != null) {
      _voicesByNote[voice.note]?.remove(voiceId);
      if (_voicesByNote[voice.note]?.isEmpty ?? false) {
        _voicesByNote.remove(voice.note);
      }
    }
  }

  /// Select voice to steal using intelligent algorithm
  /// Priority: 1) Lowest velocity, 2) Oldest
  VoiceState? _selectVoiceToSteal() {
    final activeVoices = getActiveVoices();
    if (activeVoices.isEmpty) return null;

    VoiceState? candidate;
    for (final voice in activeVoices) {
      if (candidate == null) {
        candidate = voice;
        continue;
      }

      // PRIMARY: Compare velocity (steal quieter notes)
      final velocityDiff = (voice.velocity - candidate.velocity).abs();
      if (velocityDiff > velocityEpsilon) {
        if (voice.velocity < candidate.velocity) {
          candidate = voice;
        }
        continue;
      }

      // SECONDARY: Same velocity, compare age (steal older notes)
      if (voice.startedAt.isBefore(candidate.startedAt)) {
        candidate = voice;
      }
    }

    return candidate;
  }

  /// Clear all voices
  void clear() {
    _voicesById.clear();
    _voicesByNote.clear();
  }

  @override
  String toString() {
    return 'VoiceAllocator(active: $activeVoiceCount/$maxVoices, '
        'total: $totalVoiceCount)';
  }
}
