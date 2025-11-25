/**
 * WebView Console Debug Overlay
 *
 * Floating overlay that captures and displays JavaScript console messages
 * from the VIB34D visualization WebView to help diagnose visual issues.
 *
 * A Paul Phillips Manifestation
 */

import 'package:flutter/material.dart';
import 'dart:collection';

enum ConsoleMessageType { log, error, warn, info }

class ConsoleMessage {
  final String message;
  final ConsoleMessageType type;
  final DateTime timestamp;

  ConsoleMessage({
    required this.message,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Color get color {
    switch (type) {
      case ConsoleMessageType.error:
        return Colors.red;
      case ConsoleMessageType.warn:
        return Colors.orange;
      case ConsoleMessageType.info:
        return Colors.blue;
      case ConsoleMessageType.log:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (type) {
      case ConsoleMessageType.error:
        return Icons.error;
      case ConsoleMessageType.warn:
        return Icons.warning;
      case ConsoleMessageType.info:
        return Icons.info;
      case ConsoleMessageType.log:
        return Icons.check_circle;
    }
  }
}

class WebViewConsoleOverlay extends StatefulWidget {
  final Widget child;
  final ValueNotifier<String>? systemStateNotifier;

  const WebViewConsoleOverlay({
    super.key,
    required this.child,
    this.systemStateNotifier,
  });

  @override
  State<WebViewConsoleOverlay> createState() => WebViewConsoleOverlayState();
}

class WebViewConsoleOverlayState extends State<WebViewConsoleOverlay> {
  final Queue<ConsoleMessage> _messages = Queue();
  bool _isExpanded = false;
  bool _autoScroll = true;
  final ScrollController _scrollController = ScrollController();
  static const int _maxMessages = 100;

  // Public method to add console messages from WebView
  void addMessage(String message, ConsoleMessageType type) {
    setState(() {
      _messages.add(ConsoleMessage(message: message, type: type));

      // Keep only last N messages
      while (_messages.length > _maxMessages) {
        _messages.removeFirst();
      }
    });

    // Auto-scroll to bottom if enabled
    if (_autoScroll && _scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main child widget (the WebView)
        widget.child,

        // Debug console overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? MediaQuery.of(context).size.height * 0.5 : 50,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Colors.cyan.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Header bar
                GestureDetector(
                  onTap: _toggleExpanded,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          _isExpanded ? Icons.expand_more : Icons.expand_less,
                          color: Colors.cyan,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'WebView Console',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                        const Spacer(),
                        if (_isExpanded) ...[
                          IconButton(
                            icon: Icon(
                              _autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center,
                              color: _autoScroll ? Colors.cyan : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _autoScroll = !_autoScroll;
                              });
                            },
                            tooltip: 'Auto-scroll',
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear_all, color: Colors.red),
                            onPressed: _clearMessages,
                            tooltip: 'Clear console',
                          ),
                        ],
                        Text(
                          '${_messages.length} msgs',
                          style: TextStyle(
                            color: Colors.cyan.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Console messages (only visible when expanded)
                if (_isExpanded)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.95),
                      ),
                      child: Column(
                        children: [
                          // System state section
                          if (widget.systemStateNotifier != null)
                            ValueListenableBuilder<String>(
                              valueListenable: widget.systemStateNotifier!,
                              builder: (context, systemState, _) {
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withOpacity(0.1),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.cyan.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.settings_system_daydream,
                                        color: Colors.cyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'System: $systemState',
                                        style: const TextStyle(
                                          color: Colors.cyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          // Messages list
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages.elementAt(index);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        message.icon,
                                        color: message.color,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message.message,
                                              style: TextStyle(
                                                color: message.color,
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            Text(
                                              _formatTimestamp(message.timestamp),
                                              style: TextStyle(
                                                color: Colors.grey.withOpacity(0.5),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
