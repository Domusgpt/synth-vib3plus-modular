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
          // Handle system switch completion
          else if (message.message.startsWith('SWITCH_COMPLETE:')) {
            final systemName = message.message.substring(16);
            debugPrint('✅ Canvas manager switch complete: $systemName');
            widget.visualProvider.handleSystemSwitchComplete(systemName);
          }
          // Handle initial system init completion
          else if (message.message.startsWith('INIT_COMPLETE:')) {
            final systemName = message.message.substring(14);
            debugPrint('✅ Canvas manager init complete: $systemName');
            widget.visualProvider.handleSystemSwitchComplete(systemName);
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

        // Extract filename from source URL for cleaner logs
        final source = message.sourceId.split('/').last;

        debugPrint('$prefix VIB3+ [$source:${message.lineNumber}] ${message.message}');
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

            // CRITICAL: Disable ALL VIB3+ event listeners on canvas/layers
            const disableTouchElements = [
              '.canvas-container', '#canvasContainer',
              '.holographic-layers', 'canvas'
            ];
            disableTouchElements.forEach(selector => {
              const elements = document.querySelectorAll(selector);
              elements.forEach(el => {
                el.style.pointerEvents = 'none';
                el.style.touchAction = 'none';
                // Remove all event listeners (clone and replace)
                const clone = el.cloneNode(true);
                el.parentNode.replaceChild(clone, el);
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

        // STEP 2.5: WebGL Canvas Manager - Smart destroy/init to avoid context limits
        window.canvasManager = {
          activeSystem: null,
          canvases: {},

          // Destroy all canvases for a system
          destroySystem: function(systemName) {
            console.log('🗑️ Destroying ' + systemName + ' canvases');
            const canvasArray = this.canvases[systemName] || [];

            canvasArray.forEach(function(canvas) {
              // Critical: Lose WebGL context properly
              const gl = canvas.getContext('webgl') || canvas.getContext('webgl2');
              if (gl) {
                const loseContext = gl.getExtension('WEBGL_lose_context');
                if (loseContext) {
                  loseContext.loseContext();
                  console.log('  ✅ Lost WebGL context for canvas');
                }
              }

              // Remove from DOM
              if (canvas.parentNode) {
                canvas.parentNode.removeChild(canvas);
                console.log('  ✅ Removed canvas from DOM');
              }
            });

            this.canvases[systemName] = [];
            console.log('✅ ' + systemName + ' destroyed (' + canvasArray.length + ' canvases)');
          },

          // Initialize canvases for a system
          initSystem: function(systemName) {
            console.log('🎨 Initializing ' + systemName + ' canvases');

            // VIB3+ specific init based on system
            if (window.switchSystem) {
              window.switchSystem(systemName);
              this.activeSystem = systemName;
              console.log('✅ Switched to ' + systemName + ' system');

              // Track canvases created by this system (query after brief delay for DOM update)
              setTimeout(function() {
                const canvases = Array.from(document.querySelectorAll('canvas'));
                window.canvasManager.canvases[systemName] = canvases;
                console.log('📊 Tracked ' + canvases.length + ' canvases for ' + systemName);

                // Report WebGL context count
                let contextCount = 0;
                canvases.forEach(function(canvas) {
                  const gl = canvas.getContext('webgl') || canvas.getContext('webgl2');
                  if (gl) contextCount++;
                });
                console.log('🎮 Active WebGL contexts: ' + contextCount);
              }, 50);
            } else {
              console.error('❌ window.switchSystem not available');
              FlutterBridge.postMessage('ERROR: VIB3+ switchSystem function not found');
            }
          },

          // Smart switch: destroy old, init new
          switchTo: function(newSystem) {
            if (this.activeSystem === newSystem) {
              console.log('ℹ️ Already on ' + newSystem);
              return;
            }

            const self = this;

            // Destroy current system
            if (this.activeSystem) {
              this.destroySystem(this.activeSystem);

              // Give browser time to release resources (100ms)
              setTimeout(function() {
                self.initSystem(newSystem);
                FlutterBridge.postMessage('SWITCH_COMPLETE:' + newSystem);
              }, 100);
            } else {
              // First init
              this.initSystem(newSystem);
              FlutterBridge.postMessage('INIT_COMPLETE:' + newSystem);
            }
          }
        };

        console.log('✅ Canvas Manager initialized');

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
