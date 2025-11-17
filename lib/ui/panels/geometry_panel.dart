///
/// Geometry Panel
///
/// Controls for 4D geometry selection, polytope core, rotation parameters,
/// and projection settings.
///
/// A Paul Phillips Manifestation
////

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/synth_theme.dart';
import '../components/holographic_slider.dart';
import '../../providers/visual_provider.dart';

class GeometryPanelContent extends StatelessWidget {
  const GeometryPanelContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visualProvider = Provider.of<VisualProvider>(context);
    final systemColors = visualProvider.systemColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Base Geometry
        Text(
          'BASE GEOMETRY',
          style: SynthTheme.textStyleHeading.copyWith(
            color: systemColors.primary,
          ),
        ),
        const SizedBox(height: SynthTheme.spacingSmall),
        _buildGeometryGrid(visualProvider, systemColors),
        const SizedBox(height: SynthTheme.spacingLarge),

        // Section: 4D Rotation
        Text(
          '4D ROTATION',
          style: SynthTheme.textStyleHeading.copyWith(
            color: systemColors.primary,
          ),
        ),
        const SizedBox(height: SynthTheme.spacingSmall),
        HolographicSlider(
          label: 'XW Plane',
          value: visualProvider.rotationXW,
          min: 0.0,
          max: 6.28, // 2π
          unit: '',
          onChanged: (value) => visualProvider.setRotationXW(value),
          systemColors: systemColors,
          icon: Icons.rotate_right,
        ),
        HolographicSlider(
          label: 'YW Plane',
          value: visualProvider.rotationYW,
          min: 0.0,
          max: 6.28,
          unit: '',
          onChanged: (value) => visualProvider.setRotationYW(value),
          systemColors: systemColors,
          icon: Icons.rotate_left,
        ),
        HolographicSlider(
          label: 'ZW Plane',
          value: visualProvider.rotationZW,
          min: 0.0,
          max: 6.28,
          unit: '',
          onChanged: (value) => visualProvider.setRotationZW(value),
          systemColors: systemColors,
          icon: Icons.sync,
        ),
        HolographicSlider(
          label: 'Rotation Speed',
          value: visualProvider.rotationSpeed,
          min: 0.0,
          max: 2.0,
          unit: '',
          onChanged: (value) => visualProvider.setRotationSpeed(value),
          systemColors: systemColors,
          icon: Icons.speed,
        ),
        const SizedBox(height: SynthTheme.spacingLarge),

        // Section: Projection
        Text(
          'PROJECTION',
          style: SynthTheme.textStyleHeading.copyWith(
            color: systemColors.primary,
          ),
        ),
        const SizedBox(height: SynthTheme.spacingSmall),
        HolographicSlider(
          label: 'Distance',
          value: visualProvider.projectionDistance,
          min: 5.0,
          max: 15.0,
          unit: '',
          onChanged: (value) => visualProvider.setProjectionDistance(value),
          systemColors: systemColors,
          icon: Icons.zoom_out_map,
        ),
        HolographicSlider(
          label: 'Layer Depth',
          value: visualProvider.layerSeparation,
          min: 0.0,
          max: 5.0,
          unit: '',
          onChanged: (value) => visualProvider.setLayerSeparation(value),
          systemColors: systemColors,
          icon: Icons.layers,
        ),
        HolographicSlider(
          label: 'Morph',
          value: visualProvider.morphParameter,
          min: 0.0,
          max: 1.0,
          unit: '%',
          onChanged: (value) => visualProvider.setMorphParameter(value),
          systemColors: systemColors,
          icon: Icons.blur_circular,
        ),
      ],
    );
  }

  Widget _buildGeometryGrid(
    VisualProvider visualProvider,
    SystemColors systemColors,
  ) {
    final theme = SynthTheme(systemColors: systemColors);
    final geometries = [
      'Hypercube',
      'Tesseract',
      'Hypersphere',
      'Torus',
      '24-Cell',
      '120-Cell',
      'Klein Bottle',
      'Fractal',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: SynthTheme.spacingSmall,
        mainAxisSpacing: SynthTheme.spacingSmall,
      ),
      itemCount: geometries.length,
      itemBuilder: (context, index) {
        final isActive = visualProvider.currentGeometry == index;
        return GestureDetector(
          onTap: () => visualProvider.setGeometry(index),
          child: AnimatedContainer(
            duration: SynthTheme.transitionQuick,
            decoration: theme.getNeoskeuButtonDecoration(isActive: isActive),
            child: Center(
              child: Text(
                geometries[index],
                style: SynthTheme.textStyleBody.copyWith(
                  color: theme.getTextColor(isActive),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
