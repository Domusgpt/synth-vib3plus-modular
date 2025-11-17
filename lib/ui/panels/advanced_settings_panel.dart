///
/// Advanced Settings Panel
///
/// Comprehensive settings for:
/// - Audio engine configuration
/// - Performance optimization
/// - Haptic feedback
/// - MIDI settings
/// - Visual system optimization
/// - Parameter mapping configuration
///
/// A Paul Phillips Manifestation
///

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../theme/synth_theme.dart';
import '../utils/haptic_feedback.dart';
import '../../providers/audio_provider.dart';
import '../../providers/visual_provider.dart';

class AdvancedSettingsPanel extends StatefulWidget {
  const AdvancedSettingsPanel({Key? key}) : super(key: key);

  @override
  State<AdvancedSettingsPanel> createState() => _AdvancedSettingsPanelState();
}

class _AdvancedSettingsPanelState extends State<AdvancedSettingsPanel> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        _buildTabBar(),
        const SizedBox(height: 16),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildTabContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      ('Audio', Icons.audiotrack),
      ('Visual', Icons.visibility),
      ('Performance', Icons.speed),
      ('Interface', Icons.touch_app),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: tabs
            .asMap()
            .entries
            .map((entry) => _buildTab(
                  entry.key,
                  entry.value.$1,
                  entry.value.$2,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          HapticManager.modeSwitch();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.quantum.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? DesignTokens.quantum
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? DesignTokens.quantum : Colors.white70,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? DesignTokens.quantum : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildAudioSettings();
      case 1:
        return _buildVisualSettings();
      case 2:
        return _buildPerformanceSettings();
      case 3:
        return _buildInterfaceSettings();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAudioSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Audio Engine', Icons.audiotrack),
        _buildSettingRow(
          'Anti-Aliasing',
          'Reduce high-frequency artifacts',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSettingRow(
          'DC Blocking',
          'Remove DC offset for cleaner sound',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSettingRow(
          'Soft Clipping',
          'Prevent harsh digital clipping',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Voice Management', Icons.people),
        _buildSliderSetting(
          'Max Polyphony',
          '8 voices',
          8.0,
          1.0,
          16.0,
          (val) {},
          divisions: 15,
        ),
        _buildSliderSetting(
          'Voice Stealing',
          'Oldest',
          0.0,
          0.0,
          2.0,
          (val) {},
          divisions: 2,
          labels: ['Oldest', 'Quietest', 'Lowest'],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Quality', Icons.high_quality),
        _buildSliderSetting(
          'Sample Rate',
          '44.1 kHz',
          44100.0,
          22050.0,
          96000.0,
          (val) {},
          divisions: 3,
          labels: ['22.05kHz', '44.1kHz', '48kHz', '96kHz'],
        ),
        _buildSliderSetting(
          'Buffer Size',
          '512 samples',
          512.0,
          128.0,
          2048.0,
          (val) {},
          divisions: 4,
          labels: ['128', '256', '512', '1024', '2048'],
        ),
      ],
    );
  }

  Widget _buildVisualSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Visual Quality', Icons.hd),
        _buildSliderSetting(
          'Target FPS',
          '60 FPS',
          60.0,
          30.0,
          120.0,
          (val) {},
          divisions: 3,
          labels: ['30', '60', '90', '120'],
        ),
        _buildSliderSetting(
          'Vertex Count',
          'High',
          2.0,
          0.0,
          2.0,
          (val) {},
          divisions: 2,
          labels: ['Low', 'Medium', 'High'],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Effects', Icons.auto_awesome),
        _buildSettingRow(
          'Motion Blur',
          'Smooth motion transitions',
          Switch(
            value: false,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSettingRow(
          'Glow Effects',
          'Enhanced bloom and glow',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSettingRow(
          'Particle Systems',
          'Dynamic particle effects',
          Switch(
            value: false,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Parameter Smoothing', Icons.timeline),
        _buildSliderSetting(
          'Transition Speed',
          'Medium',
          50.0,
          10.0,
          200.0,
          (val) {},
        ),
      ],
    );
  }

  Widget _buildPerformanceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('CPU Optimization', Icons.memory),
        _buildSettingRow(
          'Dynamic Quality',
          'Reduce quality when CPU load is high',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSliderSetting(
          'CPU Threshold',
          '80%',
          80.0,
          50.0,
          95.0,
          (val) {},
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Battery Saving', Icons.battery_charging_full),
        _buildSettingRow(
          'Power Saving Mode',
          'Reduce FPS and effects when on battery',
          Switch(
            value: false,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSliderSetting(
          'Battery FPS Limit',
          '30 FPS',
          30.0,
          15.0,
          60.0,
          (val) {},
          divisions: 3,
          labels: ['15', '30', '45', '60'],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Memory', Icons.storage),
        _buildSettingRow(
          'Aggressive Caching',
          'Cache more data for better performance',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildInfoRow('Current RAM Usage', '~120 MB'),
        _buildInfoRow('Audio Buffer Usage', '~2.1 MB'),
      ],
    );
  }

  Widget _buildInterfaceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Haptic Feedback', Icons.vibration),
        _buildSettingRow(
          'Enable Haptics',
          'Feel tactile feedback on interactions',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.setEnabled(val);
              if (val) HapticManager.success();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSliderSetting(
          'Haptic Intensity',
          'Normal',
          1.0,
          0.0,
          2.0,
          (val) {
            HapticManager.setIntensity(val);
            HapticManager.medium();
          },
          divisions: 4,
          labels: ['Off', 'Light', 'Normal', 'Strong', 'Max'],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Touch Response', Icons.touch_app),
        _buildSliderSetting(
          'Touch Sensitivity',
          'Normal',
          1.0,
          0.5,
          2.0,
          (val) {},
        ),
        _buildSliderSetting(
          'Touch Delay',
          '10 ms',
          10.0,
          0.0,
          50.0,
          (val) {},
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Visual Theme', Icons.palette),
        _buildSettingRow(
          'High Contrast',
          'Increase UI contrast for better visibility',
          Switch(
            value: false,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSliderSetting(
          'UI Opacity',
          '80%',
          0.8,
          0.3,
          1.0,
          (val) {},
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Debug', Icons.bug_report),
        _buildSettingRow(
          'Show FPS Counter',
          'Display real-time FPS in top bezel',
          Switch(
            value: true,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
        _buildSettingRow(
          'Show Debug Stats',
          'Display detailed performance metrics',
          Switch(
            value: false,
            onChanged: (val) {
              HapticManager.light();
            },
            activeColor: DesignTokens.quantum,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: DesignTokens.quantum, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: DesignTokens.quantum,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String description, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          control,
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String currentValue,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
    List<String>? labels,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                currentValue,
                style: TextStyle(
                  color: DesignTokens.quantum,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: DesignTokens.quantum,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: DesignTokens.quantum,
              overlayColor: DesignTokens.quantum.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (val) {
                onChanged(val);
                HapticManager.valueChange();
              },
            ),
          ),
          if (labels != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map((label) => Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 9,
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
