import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ifridge_app/core/services/voice_command_service.dart';
import 'package:ifridge_app/core/services/api_service.dart';

/// Floating microphone button for voice commands.
///
/// Shows a pulsing animation while listening,
/// displays recognized text in a bottom sheet,
/// and routes the command to the appropriate handler.
class VoiceCommandFab extends StatefulWidget {
  final String userId;
  final void Function(String message)? onAssistantReply;
  final void Function(String item)? onAddToShoppingList;

  const VoiceCommandFab({
    super.key,
    required this.userId,
    this.onAssistantReply,
    this.onAddToShoppingList,
  });

  @override
  State<VoiceCommandFab> createState() => _VoiceCommandFabState();
}

class _VoiceCommandFabState extends State<VoiceCommandFab>
    with SingleTickerProviderStateMixin {
  final VoiceCommandService _voice = VoiceCommandService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _recognizedText = '';
  bool _isListening = false;
  bool _isProcessing = false;
  StreamSubscription? _textSub;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textSub = _voice.onText.listen((text) {
      setState(() => _recognizedText = text);
    });

    _statusSub = _voice.onStatus.listen((status) {
      if (status == VoiceStatus.done && _recognizedText.isNotEmpty) {
        _handleCommand(_recognizedText);
      }
      if (status == VoiceStatus.done || status == VoiceStatus.error) {
        _pulseController.stop();
        setState(() => _isListening = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voice.stopListening();
    } else {
      setState(() {
        _recognizedText = '';
        _isListening = true;
      });
      _pulseController.repeat(reverse: true);
      await _voice.startListening();
    }
  }

  Future<void> _handleCommand(String text) async {
    final intent = _voice.parseCommand(text);

    setState(() => _isProcessing = true);

    try {
      switch (intent.type) {
        case VoiceIntentType.askRecipe:
        case VoiceIntentType.askAssistant:
          final api = ApiService();
          final result = await api.chatWithAssistant(
            messages: [
              {'role': 'user', 'content': text},
            ],
          );
          final reply = result['data']?['content'] ?? 'I couldn\'t process that. Try again!';
          widget.onAssistantReply?.call(reply);
          _showReply(reply);
          break;

        case VoiceIntentType.addToShoppingList:
          widget.onAddToShoppingList?.call(intent.parameter ?? text);
          _showReply('Added "${intent.parameter}" to your shopping list! 🛒');
          break;

        case VoiceIntentType.setTimer:
          _showReply('Timer set for ${intent.parameter}! ⏰');
          break;
      }
    } catch (e) {
      _showReply('Sorry, something went wrong. Please try again.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showReply(String message) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: Color(0xFF4FC3F7), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'iFridge AI',
                  style: TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recognizedText.isNotEmpty) ...[
              Text(
                '"$_recognizedText"',
                style: const TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: FloatingActionButton(
            heroTag: 'voice_fab',
            onPressed: _isProcessing ? null : _toggleListening,
            backgroundColor: _isListening
                ? const Color(0xFFEF5350)
                : const Color(0xFF4FC3F7),
            elevation: _isListening ? 12 : 6,
            child: _isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
          ),
        );
      },
    );
  }
}
