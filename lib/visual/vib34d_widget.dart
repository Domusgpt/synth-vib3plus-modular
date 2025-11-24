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
import '../ui/debug/webview_console_overlay.dart';

class VIB34DWidget extends StatefulWidget {
  final VisualProvider visualProvider;
  final AudioProvider audioProvider;
  final Function(String message, ConsoleMessageType type)? onConsoleMessage;
  final ValueNotifier<String>? systemStateNotifier;

  const VIB34DWidget({
    Key? key,
    required this.visualProvider,
    required this.audioProvider,
    this.onConsoleMessage,
    this.systemStateNotifier,
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
          // Handle messages from VIB3+ (errors, events, etc.)
          if (message.message.startsWith('ERROR:')) {
            setState(() {
              _errorMessage = message.message.substring(6);
            });
          }
        },
      )
      ..addJavaScriptChannel(
        'consoleMessage',
        onMessageReceived: (JavaScriptMessage message) {
          // Message format: {"message": "...", "type": "log|error|warn|info"}
          try {
            final data = jsonDecode(message.message);
            final msg = data['message'] as String;
            final type = data['type'] as String;

            // Forward to debug console
            ConsoleMessageType msgType;
            switch (type) {
              case 'error':
                msgType = ConsoleMessageType.error;
                break;
              case 'warn':
                msgType = ConsoleMessageType.warn;
                break;
              case 'info':
                msgType = ConsoleMessageType.info;
                break;
              default:
                msgType = ConsoleMessageType.log;
            }

            // Forward to callback
            widget.onConsoleMessage?.call(msg, msgType);

            // Update system state if message contains system info
            if (widget.systemStateNotifier != null &&
                (msg.contains('Switched to') || msg.contains('system initialized'))) {
              if (msg.contains('quantum')) {
                widget.systemStateNotifier!.value = 'Quantum System';
              } else if (msg.contains('holographic')) {
                widget.systemStateNotifier!.value = 'Holographic System';
              } else if (msg.contains('faceted')) {
                widget.systemStateNotifier!.value = 'Faceted System';
              }
            }
          } catch (e) {
            debugPrint('❌ Error parsing console message: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🔄 Page loading started: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('📄 Page loaded: $url');

            // Wait a moment for JavaScript to initialize
            await Future.delayed(const Duration(milliseconds: 500));

            await _injectHelperFunctions();

            // Wait another moment for systems to initialize
            await Future.delayed(const Duration(milliseconds: 300));

            setState(() {
              _isLoading = false;
            });
            debugPrint('✅ VIB34D WebView ready');
          },
          onWebResourceError: (WebResourceError error) {
            // Log all resource errors but only show critical ones to user
            debugPrint('❌ WebView Resource Error:');
            debugPrint('   Type: ${error.errorType}');
            debugPrint('   Code: ${error.errorCode}');
            debugPrint('   Description: ${error.description}');
            debugPrint('   URL: ${error.url}');

            // Only show main page load errors to user
            if (error.url == null || error.url!.contains('index.html')) {
              setState(() {
                _errorMessage = 'Failed to load visualization:\n${error.description}';
                _isLoading = false;
              });
            }
          },
        ),
      );

    // CRITICAL: Enable file access from file:// URLs (needed for Vite bundled assets)
    // This allows the HTML file to load CSS/JS from relative file:// paths
    if (_webViewController.platform is AndroidWebViewController) {
      final androidController = _webViewController.platform as AndroidWebViewController;

      // Enable debugging to see console output
      AndroidWebViewController.enableDebugging(true);

      // Allow file access from file URLs (CRITICAL for loading bundled JS/CSS)
      await androidController.setAllowFileAccess(true);

      // Allow access to content URLs
      await androidController.setAllowContentAccess(true);

      // Disable media playback gesture requirement
      await androidController.setMediaPlaybackRequiresUserGesture(false);

      debugPrint('✅ Android WebView: File access enabled for bundled assets');
    }

    // Load VIB3+ from bundled local assets (Vite build with relative paths)
    await _webViewController.loadFlutterAsset('assets/vib3_dist/index.html');

    // Attach controller to visual provider
    widget.visualProvider.setWebViewController(_webViewController);
  }

  /// Inject CSS to hide VIB3+ standalone UI and helper functions for parameter updates
  Future<void> _injectHelperFunctions() async {
    try {
      await _webViewController.runJavaScript('''
        // STEP 0: Intercept console messages and forward to Flutter
        (function() {
          const originalConsole = {
            log: console.log.bind(console),
            error: console.error.bind(console),
            warn: console.warn.bind(console),
            info: console.info.bind(console)
          };

          console.log = function(...args) {
            originalConsole.log(...args);
            if (window.consoleMessage) {
              window.consoleMessage.postMessage(JSON.stringify({
                message: args.join(' '),
                type: 'log'
              }));
            }
          };

          console.error = function(...args) {
            originalConsole.error(...args);
            if (window.consoleMessage) {
              window.consoleMessage.postMessage(JSON.stringify({
                message: args.join(' '),
                type: 'error'
              }));
            }
          };

          console.warn = function(...args) {
            originalConsole.warn(...args);
            if (window.consoleMessage) {
              window.consoleMessage.postMessage(JSON.stringify({
                message: args.join(' '),
                type: 'warn'
              }));
            }
          };

          console.info = function(...args) {
            originalConsole.info(...args);
            if (window.consoleMessage) {
              window.consoleMessage.postMessage(JSON.stringify({
                message: args.join(' '),
                type: 'info'
              }));
            }
          };

          console.log('✅ Console forwarding to Flutter enabled');
        })();

        // STEP 1: Log VIB3+ initialization status
        console.log('📊 VIB3+ Status Check:');
        console.log('  - window.switchSystem:', typeof window.switchSystem);
        console.log('  - window.updateParameter:', typeof window.updateParameter);
        console.log('  - window.currentSystem:', window.currentSystem);
        console.log('  - window.engine:', !!window.engine);
        console.log('  - window.quantumEngine:', !!window.quantumEngine);
        console.log('  - window.holographicSystem:', !!window.holographicSystem);

        // STEP 2: Hide VIB3+ standalone UI controls (synthesizer has its own)
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

            /* IMPORTANT: Allow canvas interaction during initialization */
            /* Touch events will be managed by Flutter after initialization */
            .canvas-container,
            #canvasContainer,
            .holographic-layers {
              pointer-events: auto !important;
            }

            canvas {
              pointer-events: auto !important;
              touch-action: auto !important;
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

            // Ensure canvas is visible and interactive
            const canvases = document.querySelectorAll('canvas');
            console.log(\`✅ Found \${canvases.length} canvas elements\`);
            canvases.forEach((canvas, i) => {
              console.log(\`  Canvas \${i}: \${canvas.width}x\${canvas.height}, visible: \${canvas.offsetWidth > 0}\`);
            });

            FlutterBridge.postMessage('INFO: VIB3+ UI hidden, canvas enabled');
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

        // STEP 3: Error handler
        window.addEventListener('error', function(e) {
          FlutterBridge.postMessage('ERROR: ' + e.message);
        });

        // STEP 4: Initialize to faceted system and notify Flutter when VIB3+ is ready
        (async function() {
          if (window.switchSystem) {
            console.log('🎯 VIB3+ ready - switching to faceted system...');
            console.log('  Current system:', window.currentSystem);
            try {
              await window.switchSystem('faceted');
              console.log('✅ Successfully switched to faceted system');
              console.log('  New system:', window.currentSystem);
              FlutterBridge.postMessage('READY: VIB3+ faceted system active');
            } catch (error) {
              console.error('❌ Failed to switch to faceted:', error);
              FlutterBridge.postMessage('ERROR: Failed to switch to faceted system');
            }
          } else {
          // Wait for systems to load
          const checkReady = setInterval(() => {
            if (window.switchSystem) {
              clearInterval(checkReady);
              console.log('🎯 VIB3+ ready (after wait) - switching to faceted system...');
              window.switchSystem('faceted').then(() => {
                console.log('✅ Successfully switched to faceted system (delayed)');
                FlutterBridge.postMessage('READY: VIB3+ faceted system active');
              }).catch((error) => {
                console.error('❌ Failed to switch to faceted (delayed):', error);
                FlutterBridge.postMessage('ERROR: Failed to switch to faceted system');
              });
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
        })();
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
