import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/webview_game_model.dart';
import '../controllers/game_controller.dart';

class GameBottomSheet extends StatefulWidget {
  final WebViewGameModel game;

  const GameBottomSheet({super.key, required this.game});

  @override
  State<GameBottomSheet> createState() => _GameBottomSheetState();
}

class _GameBottomSheetState extends State<GameBottomSheet> {
  late final GameController _gameController;
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _gameController = Get.find<GameController>();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _gameController.startGameSession();
      await _setupWebViewController(widget.game.gameUrl);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to start game: $e';
      });
    }
  }

  Future<void> _setupWebViewController(String gameUrl) async {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _injectGameBridge();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load game: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(gameUrl));
  }

  void _injectGameBridge() {
    if (_webViewController == null) return;

    final javascript = '''
    (function() {
      const sendGameResult = (winAmount) => {
        const sessionId = '${_gameController.currentSession.value?.sessionId ?? ''}';
        if (sessionId) {
          window.flutter_inappwebview.callHandler('gameResult', sessionId, winAmount);
        }
      };

      window.sendGameResult = sendGameResult;
      window.gameSessionId = '${_gameController.currentSession.value?.sessionId ?? ''}';
      window.gameRewardType = '${widget.game.rewardType}';
      window.coinToDiamondRatio = ${widget.game.coinToDiamondRatio};
      console.log('Game bridge initialized');
    })();
    ''';

    _webViewController!.runJavaScript(javascript);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: widget.game.thumbnailUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.game.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.sports_esports,
                              color: Colors.white54,
                              size: 22,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.sports_esports,
                          color: Colors.white54,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Playing: ${_gameController.currentBetAmount.value} coins',
                        style: TextStyle(
                          color: Colors.orange[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _gameController.resetGameState();
                    Get.back();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _webViewController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Loading game...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeWebView,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_webViewController != null) {
      return WebViewWidget(controller: _webViewController!);
    }

    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _gameController.resetGameState();
    super.dispose();
  }
}