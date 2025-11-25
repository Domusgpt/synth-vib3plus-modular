# Flutter/Dart Support Integration

**Date:** November 19, 2025
**Source:** vib34d-vib3plus repository (branch: claude/add-flutter-dart-support-01WiDt1H7XB1FTsuQy3i2jZa)
**Target:** synth-vib3plus-modular (branch: claude/flutter-dart-support-01QmF9NpMzNS6zNpXLSFWNpf)

## Integration Summary

This integration brings advanced quaternion mathematics and proper 24-geometry system from the VIB34D XR Quaternion SDK into the Synth-VIB3+ modular synthesizer project.

---

## Changes Made

### 1. New Core Components

#### `lib/core/quaternion_utils.dart` (NEW)
- **QuaternionUtils class** with advanced quaternion operations:
  - `normalize()` - Normalize quaternions to unit length
  - `toEuler()` - Convert quaternions to Euler angles (roll, pitch, yaw)
  - `multiply()` - Combine rotations via quaternion multiplication
  - `conjugate()` - Get inverse rotation
  - `angularVelocity()` - Calculate rotation speed between quaternions
  - `lerp()` - Linear interpolation
  - `slerp()` - Spherical linear interpolation for smooth transitions
  - `fromAxisAngle()` - Create quaternion from axis and angle
  - `fromEuler()` - Create quaternion from Euler angles
- **EulerAngles class** for roll/pitch/yaw representation
- Enables proper 4D rotation handling for VIB3+ visualization

#### `lib/core/geometry_library.dart` (NEW)
- **Complete 24-geometry system** combining:
  - 8 base geometries (tetrahedron, hypercube, sphere, torus, Klein bottle, fractal, wave, crystal)
  - 3 core variants (base, hypersphere, hypertetrahedron)
  - 24 total unique sound+visual combinations
- **BaseGeometry enum** - Determines voice character
- **CoreVariant enum** - Determines synthesis branch
- **GeometryMetadata class** - Complete geometry description
- **VariationParameters class** - Rendering parameter management
- **GeometryLibrary static class** with utilities:
  - `encodeGeometryIndex()` - Combine base+core into single index (0-23)
  - `decodeGeometryIndex()` - Split index into base and core components
  - `describeGeometry()` - Get full metadata for any geometry
  - `listAllGeometries()` - Get all 24 geometries
  - `getVariationParameters()` - Generate geometry-specific rendering parameters
  - `getSynthesisBranch()` - Get synthesis type (Direct/FM/Ring Mod)
  - `getSoundFamily()` - Get sound characteristics by visual system
  - `usesFMSynthesis()` / `usesRingModulation()` - Check synthesis type

### 2. Updated Components

#### `lib/providers/visual_provider.dart`
**Changes:**
- Import `geometry_library.dart`
- Updated geometry range from 0-7 to **0-23** (full system)
- Added `_currentGeometryMetadata` field to store geometry info
- Enhanced `setGeometry()` method:
  - Uses `GeometryLibrary.decodeGeometryIndex()` for proper parsing
  - Gets metadata via `GeometryLibrary.describeGeometry()`
  - Logs full geometry name and synthesis branch
  - Sends only base geometry (0-7) to JavaScript (VIB3+ expects this)
- Added `currentGeometryMetadata` getter

**Impact:**
- Visual system now understands all 24 geometry combinations
- Proper routing of geometry selection to synthesis and visualization
- Better debugging output showing full geometry names

#### `lib/synthesis/synthesis_branch_manager.dart`
**Changes:**
- Import `geometry_library.dart` as `geo`
- Updated `setGeometry()` method:
  - Uses `geo.GeometryLibrary.decodeGeometryIndex()` for proper parsing
  - Gets metadata via `geo.GeometryLibrary.describeGeometry()`
  - Enhanced logging shows full geometry name and synthesis branch
- Maintains existing synthesis logic (no changes to audio generation)

**Impact:**
- Synthesis engine now properly interprets 24-geometry system
- Correct routing to Direct/FM/Ring Mod synthesis branches
- Consistent geometry interpretation across visual and audio systems

---

## Architecture Integration

### The 3D Matrix System (Now Fully Implemented)

```
3 Visual Systems × 3 Synthesis Branches × 8 Base Geometries = 72 combinations

Visual System (Sound Family)     Core Variant (Synthesis)        Base Geometry (Voice Character)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
0: Quantum (Pure Harmonic)    ×   0: Base (Direct)        (0-7) ×  0: Tetrahedron (Fundamental)
1: Faceted (Geometric Hybrid) ×   1: Hypersphere (FM)     (8-15) × 1: Hypercube (Complex)
2: Holographic (Spectral Rich)×   2: Hypertetrahedron (Ring)(16-23)× 2: Sphere (Smooth)
                                                                    3: Torus (Cyclic)
                                                                    4: Klein Bottle (Twisted)
                                                                    5: Fractal (Recursive)
                                                                    6: Wave (Flowing)
                                                                    7: Crystal (Crystalline)
```

### Geometry Index Calculation

```dart
// Example: Geometry index 11
int geometryIndex = 11;
var decoded = GeometryLibrary.decodeGeometryIndex(11);
// decoded.core = 11 ~/ 8 = 1 (Hypersphere = FM synthesis)
// decoded.base = 11 % 8 = 3 (Torus = cyclic voice character)

var metadata = GeometryLibrary.describeGeometry(11);
// metadata.fullName = "Hypersphere Torus (FM Synthesis)"
```

### Data Flow

```
User selects geometry (0-23)
         ↓
VisualProvider.setGeometry(index)
         ↓
GeometryLibrary.decodeGeometryIndex(index)
         ↓         ↓
    base (0-7)  core (0-2)
         ↓         ↓
    JavaScript  Synthesis Branch
    (visual)    (audio)
         ↓         ↓
    VIB3+       SynthesizerEngine
    renderer    audio output
```

---

## Benefits

### 1. **Proper Geometry System**
- Replaces ad-hoc 0-7 indexing with structured 24-geometry library
- Clear separation of base geometry, core variant, and visual system
- Consistent interpretation across visual and audio systems

### 2. **Advanced Quaternion Math**
- Professional-grade quaternion utilities for 4D rotations
- Smooth interpolation via slerp for animations
- Proper angular velocity calculations
- Ready for future AR/VR/XR integrations

### 3. **Better Debugging**
- Geometry metadata provides human-readable names
- Clear logging of geometry selection showing full details
- Easier to understand which synthesis branch and voice character is active

### 4. **Scalability**
- Clean architecture supports easy extension
- Variation parameters allow geometry-specific adjustments
- Ready for additional geometries or synthesis methods

### 5. **Code Quality**
- Eliminates magic numbers (geometry indices now have meaning)
- Centralized geometry logic in single source of truth
- Type-safe enums prevent invalid geometry selections

---

## Usage Examples

### Setting Geometry with Full Details

```dart
// In VisualProvider or any component
visualProvider.setGeometry(11);

// Output:
// 🔷 Geometry Switching: 0 → 11
//    Hypersphere Torus (FM Synthesis)
//    Synthesis: FM Synthesis
//    Vertex count: 100 → 50
```

### Getting Geometry Information

```dart
// Get current geometry metadata
final metadata = visualProvider.currentGeometryMetadata;
print(metadata?.fullName); // "Hypersphere Torus (FM Synthesis)"
print(metadata?.baseName); // "Torus"
print(metadata?.coreName); // "Hypersphere"

// Check synthesis type
if (GeometryLibrary.usesFMSynthesis(geometryIndex)) {
  print("Using FM synthesis!");
}
```

### Using Quaternion Utilities

```dart
import 'package:vector_math/vector_math.dart';
import 'package:synther_vib34d_holographic/core/quaternion_utils.dart';

// Smooth rotation interpolation
final q1 = Quaternion(0, 0, 0, 1); // Identity
final q2 = QuaternionUtils.fromEuler(0, math.pi / 4, 0); // 45° pitch
final interpolated = QuaternionUtils.slerp(q1, q2, 0.5); // Halfway

// Convert to Euler for debugging
final euler = QuaternionUtils.toEuler(interpolated);
print('Roll: ${euler.roll}, Pitch: ${euler.pitch}, Yaw: ${euler.yaw}');

// Calculate angular velocity
final velocity = QuaternionUtils.angularVelocity(q1, q2, deltaTime);
print('Rotation speed: $velocity rad/s');
```

### Listing All Geometries

```dart
final allGeometries = GeometryLibrary.listAllGeometries();
for (final geo in allGeometries) {
  print('${geo.index}: ${geo.fullName}');
}

// Output:
// 0: Base Tetrahedron (Direct Synthesis)
// 1: Base Hypercube (Direct Synthesis)
// ...
// 8: Hypersphere Tetrahedron (FM Synthesis)
// 9: Hypersphere Hypercube (FM Synthesis)
// ...
// 16: Hypertetrahedron Tetrahedron (Ring Modulation)
// ...
// 23: Hypertetrahedron Crystal (Ring Modulation)
```

---

## Testing Recommendations

### Manual Testing

1. **Geometry Selection (0-23)**
   ```bash
   flutter run
   # In app: Select different geometries and verify:
   # - Visual system updates correctly
   # - Audio changes match expected synthesis branch
   # - Logs show proper geometry names
   ```

2. **Visual System Switching**
   ```bash
   # Switch between Quantum/Faceted/Holographic
   # Verify sound family changes (harmonic content, filter Q, reverb)
   ```

3. **Synthesis Branch Verification**
   ```bash
   # Test geometries 0-7 (Direct), 8-15 (FM), 16-23 (Ring Mod)
   # Listen for characteristic synthesis types:
   # - Direct: Clear harmonic tones
   # - FM: Complex bell-like timbres
   # - Ring Mod: Metallic inharmonic sounds
   ```

### Automated Testing

```dart
// test/core/geometry_library_test.dart
test('Geometry encoding/decoding', () {
  // Test all 24 geometries
  for (int i = 0; i < 24; i++) {
    final decoded = GeometryLibrary.decodeGeometryIndex(i);
    final reencoded = GeometryLibrary.encodeGeometryIndex(decoded.base, decoded.core);
    expect(reencoded, i);
  }
});

test('Synthesis branch routing', () {
  expect(GeometryLibrary.usesFMSynthesis(0), false);
  expect(GeometryLibrary.usesFMSynthesis(8), true);
  expect(GeometryLibrary.usesRingModulation(16), true);
});

// test/core/quaternion_utils_test.dart
test('Quaternion normalization', () {
  final q = Quaternion(1, 2, 3, 4);
  final normalized = QuaternionUtils.normalize(q);
  expect(normalized?.length, closeTo(1.0, 0.0001));
});

test('Slerp interpolation', () {
  final q1 = Quaternion(0, 0, 0, 1);
  final q2 = Quaternion(1, 0, 0, 0);
  final mid = QuaternionUtils.slerp(q1, q2, 0.5);
  expect(mid, isNotNull);
});
```

---

## Migration Notes

### For Existing Code

**Before (0-7 geometry):**
```dart
visualProvider.setGeometry(3); // What geometry is this?
```

**After (0-23 geometry):**
```dart
// Same index, but now with context:
visualProvider.setGeometry(3); // Base Torus (Direct Synthesis)

// Or be explicit about synthesis branch:
visualProvider.setGeometry(11); // Hypersphere Torus (FM Synthesis)
visualProvider.setGeometry(19); // Hypertetrahedron Torus (Ring Modulation)
```

### Breaking Changes

- **Geometry range extended**: Code assuming geometries are only 0-7 will need updates
- **New dependencies**: Projects must have `vector_math` package (already in pubspec.yaml)

### Non-Breaking Changes

- Visual provider still accepts 0-7 indices (maps to Base core automatically)
- Synthesis branch manager maintains backward compatibility
- No changes to audio generation algorithms

---

## Future Enhancements

### Potential Additions

1. **Quaternion-based Rotation UI**
   - Use QuaternionUtils.slerp() for smooth rotation animations
   - Implement trackball-style 4D rotation controls

2. **Geometry Presets**
   - Save favorite geometry+visual system combinations
   - Quick preset switching for live performance

3. **Parameter Variation System**
   - Use `GeometryLibrary.getVariationParameters()` for geometry-specific visual tuning
   - Implement variation levels (0-10) for progressive complexity

4. **AR/VR Integration**
   - QuaternionUtils ready for AR headset pose tracking
   - Geometry library supports XR spatial computing workflows

5. **Advanced Synthesis Routing**
   - Custom synthesis branch definitions
   - User-definable geometry→synthesis mappings

---

## References

- **Source Repository**: [vib34d-vib3plus](https://github.com/Domusgpt/vib34d-vib3plus)
- **Branch**: `claude/add-flutter-dart-support-01WiDt1H7XB1FTsuQy3i2jZa`
- **Key Files**:
  - `lib/src/core/quaternion.dart` → `lib/core/quaternion_utils.dart`
  - `lib/src/geometry/geometry_library.dart` → `lib/core/geometry_library.dart`

---

## Credits

**Integration by:** Claude (Anthropic)
**Original VIB34D SDK by:** Paul Phillips (Clear Seas Solutions LLC)
**Synth-VIB3+ Project by:** Paul Phillips

---

**"The Revolution Will Not be in a Structured Format"**

© 2025 Paul Phillips - Clear Seas Solutions LLC
