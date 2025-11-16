/**
 * VIB34D Widget
 *
 * Flutter WebView widget that displays the THREE VIB34D visualization systems
 * with full bidirectional parameter coupling to audio synthesis.
 *
 * Integrates with:
 * - VisualProvider for parameter state
 * - AudioProvider for audio-reactive modulation
 * - ParameterBridge for bidirectional coupling
 *
 * A Paul Phillips Manifestation
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../providers/visual_provider.dart';
import '../providers/audio_provider.dart';

class VIB34DWidget extends StatefulWidget {
  final VisualProvider visualProvider;
  final AudioProvider audioProvider;

  const VIB34DWidget({
    Key? key,
    required this.visualProvider,
    required this.audioProvider,
  }) : super(key: key);

  @override
  State<VIB34DWidget> createState() => _VIB34DWidgetState();
}

class _VIB34DWidgetState extends State<VIB34DWidget> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('📨 VIB3+ Message: ${message.message}');

          // Handle errors
          if (message.message.startsWith('ERROR:')) {
            setState(() {
              _errorMessage = message.message.substring(6);
            });
          }
          // Handle VIB3+ ready signal
          else if (message.message.startsWith('READY:')) {
            debugPrint('✅ ${message.message}');
          }
          // Handle other info messages
          else if (message.message.startsWith('INFO:')) {
            debugPrint('ℹ️ ${message.message}');
          }
        },
      )
      ..setOnConsoleMessage((JavaScriptConsoleMessage message) {
        // Map JavaScript console levels to Flutter debug output
        final prefix = {
          JavaScriptLogLevel.log: '📘',
          JavaScriptLogLevel.warning: '⚠️',
          JavaScriptLogLevel.error: '❌',
        }[message.level] ?? 'ℹ️';

        debugPrint('$prefix VIB3+ ${message.message}');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            debugPrint('📄 Page loaded: $url');
            await _injectHelperFunctions();
            setState(() {
              _isLoading = false;
            });
            debugPrint('✅ VIB34D WebView ready');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = error.description;
              _isLoading = false;
            });
            debugPrint('❌ WebView error: ${error.description}');
          },
        ),
      );

    // CRITICAL: Enable file access from file:// URLs (needed for Vite bundled assets)
    // This allows the HTML file to load CSS/JS from relative file:// paths
    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
    }

    // Enable universal file access for Android WebView to load bundled CSS/JS
    await _webViewController.runJavaScript('''
      // This runs before page load to configure WebView settings
      console.log('🔧 Configuring WebView for local file access');
    ''');

    // Load VIB3+ from bundled local assets (Vite build with relative paths)
    await _webViewController.loadFlutterAsset('assets/vib3_dist/index.html');

    // Attach controller to visual provider
    widget.visualProvider.setWebViewController(_webViewController);
  }

  /// Inject CSS to hide VIB3+ standalone UI and helper functions for parameter updates
  Future<void> _injectHelperFunctions() async {
    try {
      await _webViewController.runJavaScript('''
        // STEP 1: Hide VIB3+ standalone UI controls (synthesizer has its own)
        const hideVIB3UI = () => {
          const style = document.createElement('style');
          style.id = 'synth-vib3-ui-override';
          style.textContent = \`
            /* Hide top bar logo and action buttons, but KEEP system selector visible */
            .top-bar .logo-section,
            .top-bar .action-section {
              display: none !important;
              visibility: hidden !important;
              opacity: 0 !important;
              pointer-events: none !important;
            }

            /* Keep top-bar and system-selector visible and functional */
            .top-bar {
              display: flex !important;
              justify-content: center !important;
              align-items: center !important;
              padding: 8px 0 !important;
              background: rgba(0, 0, 0, 0.8) !important;
            }

            .system-selector {
              display: flex !important;
              visibility: visible !important;
              opacity: 1 !important;
              pointer-events: all !important;
            }

            /* Hide control panel and all bezel UI */
            .control-panel,
            #controlPanel,
            .bezel-header,
            .bezel-tabs,
            .bezel-tab,
            .bezel-content {
              display: none !important;
              visibility: hidden !important;
              opacity: 0 !important;
              pointer-events: none !important;
            }

            /* Hide diagnostics panel */
            .diagnostics-panel,
            #diagnosticsPanel,
            .system-diagnostics {
              display: none !important;
              visibility: hidden !important;
              opacity: 0 !important;
              pointer-events: none !important;
            }

            /* Ensure canvas container takes full space */
            .canvas-container,
            #canvasContainer {
              position: absolute !important;
              top: 0 !important;
              left: 0 !important;
              width: 100% !important;
              height: 100% !important;
              z-index: 1 !important;
            }

            /* Ensure holographic layers take full space */
            .holographic-layers {
              position: absolute !important;
              top: 0 !important;
              left: 0 !important;
              width: 100% !important;
              height: 100% !important;
            }

            /* Hide all buttons that aren't from Flutter */
            body > button,
            .top-bar button,
            .control-panel button {
              display: none !important;
            }

            /* CRITICAL: Disable ALL VIB3+ touch/mouse event handling */
            .canvas-container,
            #canvasContainer,
            .holographic-layers,
            canvas {
              pointer-events: none !important;
              touch-action: none !important;
            }
          \`;
          document.head.appendChild(style);

          // Also directly hide elements and disable touch events after DOM loads
          setTimeout(() => {
            // Hide ONLY logo and action buttons, keep system-selector visible
            const elementsToHide = [
              '.top-bar .logo-section', '.top-bar .action-section',
              '.control-panel', '#controlPanel',
              '.diagnostics-panel', '#diagnosticsPanel',
              '.bezel-header'
            ];
            elementsToHide.forEach(selector => {
              const elements = document.querySelectorAll(selector);
              elements.forEach(el => {
                el.style.display = 'none';
                el.style.visibility = 'hidden';
                el.style.opacity = '0';
                el.style.pointerEvents = 'none';
              });
            });

            // Ensure system-selector stays visible
            const systemSelector = document.querySelector('.system-selector');
            if (systemSelector) {
              systemSelector.style.display = 'flex';
              systemSelector.style.visibility = 'visible';
              systemSelector.style.opacity = '1';
              systemSelector.style.pointerEvents = 'all';
            }

            // CRITICAL: Disable VIB3+ touch events via CSS ONLY (no cloning - that destroys WebGL!)
            const disableTouchElements = [
              '.canvas-container', '#canvasContainer',
              '.holographic-layers', 'canvas'
            ];
            disableTouchElements.forEach(selector => {
              const elements = document.querySelectorAll(selector);
              elements.forEach(el => {
                el.style.pointerEvents = 'none';
                el.style.touchAction = 'none';
                // CSS-only approach - DO NOT clone canvas elements as it destroys WebGL context!
              });
            });

            FlutterBridge.postMessage('INFO: VIB3+ UI hidden + ALL touch events disabled');
          }, 100);
        };

        // Apply immediately and after DOM loads
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', hideVIB3UI);
        } else {
          hideVIB3UI();
        }

        // STEP 2: Helper to batch parameter updates for better performance
        window.flutterUpdateParameters = function(params) {
          if (!window.updateParameter) {
            FlutterBridge.postMessage('ERROR: VIB3+ not ready yet');
            return;
          }

          // Apply each parameter
          Object.entries(params).forEach(([key, value]) => {
            try {
              window.updateParameter(key, value);
            } catch (e) {
              FlutterBridge.postMessage('ERROR: Failed to update ' + key + ': ' + e.message);
            }
          });
        };

        // STEP 2.5: VIB3+ Native System Support
        // NOTE: VIB3+ manages its own canvases - we just use window.switchSystem()
        console.log('✅ Using VIB3+ native canvas management (window.switchSystem)');

        // STEP 2.6: Audio Reactivity Handler - Send FFT data to WebGL systems
        window.updateAudioReactivity = function(audioData) {
          // audioData: { bass, mid, high, brightness, amplitude, transients }

          // Send to active VIB3+ system for real-time reactivity
          if (window.setAudioReactivity) {
            window.setAudioReactivity(audioData);
          }

          // Apply audio-reactive modulations to visual parameters
          // Bass energy → rotation speed boost
          if (audioData.bass > 0.5) {
            const bassBoost = 1.0 + (audioData.bass - 0.5) * 2.0; // 1.0-2.0x
            if (window.updateParameter) {
              window.updateParameter('rotationSpeedMultiplier', bassBoost);
            }
          }

          // Mid energy → tessellation density
          if (audioData.mid > 0.3) {
            const density = Math.floor(3 + audioData.mid * 5); // 3-8
            if (window.updateParameter) {
              window.updateParameter('tessellationDensity', density);
            }
          }

          // High energy → vertex brightness
          if (audioData.high > 0.2) {
            const brightness = 0.5 + audioData.high * 0.5; // 0.5-1.0
            if (window.updateParameter) {
              window.updateParameter('vertexBrightness', brightness);
            }
          }

          // Spectral brightness → hue shift
          if (audioData.brightness !== undefined) {
            const hue = audioData.brightness * 360.0; // 0-360°
            if (window.updateParameter) {
              window.updateParameter('hueShift', hue);
            }
          }

          // Amplitude → glow intensity
          if (audioData.amplitude > 0.1) {
            const glow = audioData.amplitude * 3.0; // 0-3
            if (window.updateParameter) {
              window.updateParameter('glowIntensity', glow);
            }
          }

          // Transients → RGB split for impact
          if (audioData.transients > 0.5) {
            const split = audioData.transients * 10.0; // 0-10
            if (window.updateParameter) {
              window.updateParameter('rgbSplitAmount', split);
            }
          }
        };

        console.log('✅ Audio reactivity handler initialized');

        // STEP 3: Error handler
        window.addEventListener('error', function(e) {
          FlutterBridge.postMessage('ERROR: ' + e.message);
        });

        // STEP 4: Notify Flutter when VIB3+ is ready
        if (window.switchSystem) {
          FlutterBridge.postMessage('READY: VIB3+ systems loaded');
        } else {
          // Wait for systems to load
          const checkReady = setInterval(() => {
            if (window.switchSystem) {
              clearInterval(checkReady);
              FlutterBridge.postMessage('READY: VIB3+ systems loaded');
            }
          }, 100);

          // Timeout after 10 seconds
          setTimeout(() => {
            clearInterval(checkReady);
            if (!window.switchSystem) {
              FlutterBridge.postMessage('ERROR: VIB3+ failed to initialize');
            }
          }, 10000);
        }
      ''');
      debugPrint('✅ Injected CSS UI override + helper functions into VIB3+ WebView');
    } catch (e) {
      debugPrint('❌ Error injecting helper functions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),

        // Loading indicator
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.cyan),
                  SizedBox(height: 20),
                  Text(
                    'Loading VIB34D Systems...',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Error message
        if (_errorMessage != null)
          Container(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 20),
                    Text(
                      'Error Loading Visualization',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
