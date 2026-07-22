import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/env_config.dart';
import 'api_service.dart';

class LiveKitService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final String liveKitWsUrl = EnvConfig.liveKitWsUrl;

  final isConnected = false.obs;
  final isMicEnabled = true.obs;
  final isCameraEnabled = false.obs;
  final isScreenSharing = false.obs;
  final isSpeakerOn = true.obs;
  final remoteUsers = <RemoteParticipant>[].obs;
  final activeUsers = <Map<String, dynamic>>[].obs;

  Room? _room;
  LocalParticipant? _localParticipant;

  Room? get room => _room;
  LocalParticipant? get localParticipant => _localParticipant;


  Future<void> initialize() async {
    try {
      await LiveKitClient.initialize();
    } catch (e) {
      debugPrint('═══ LiveKit initialize ERROR ═══');
      debugPrint('Error: $e');
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      debugPrint('═══ Microphone Permission DENIED ═══');
      return false;
    }
    return true;
  }

  Future<bool> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    bool enableAudio = true,
    bool enableVideo = false,
  }) async {
    try {
      final micGranted = await requestMicrophonePermission();
      if (!micGranted) {
        debugPrint('═══ LiveKit joinRoom ABORTED — mic permission denied ═══');
        return false;
      }

      final tokenResponse = await _fetchLiveKitToken(roomId, userId, userName);
      final token = tokenResponse['token'] as String?;
      final liveKitWs = tokenResponse['liveKitWsUrl'] as String? ?? liveKitWsUrl;

      if (token == null || token.isEmpty) return false;

      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );
      _room = room;

      await room.connect(
        liveKitWs,
        token,
        connectOptions: const ConnectOptions(
          
        ),
      );

      _localParticipant = room.localParticipant;
      isMicEnabled.value = enableAudio;
      isCameraEnabled.value = enableVideo;
      return true;
    } catch (e, stack) {
      debugPrint('═══ LiveKit joinRoom ERROR ═══');
      debugPrint('Room: $roomId, User: $userId, Error: $e');
      debugPrint('Stack: $stack');
      return false;
    }
  }

  Future<void> leaveRoom() async {
    try {
      await _room?.disconnect();
      _room = null;
      _localParticipant = null;
      isConnected.value = false;
      remoteUsers.clear();
      activeUsers.clear();
    } catch (e) {
      debugPrint('═══ LiveKit leaveRoom ERROR ═══');
      debugPrint('Error: $e');
    }
  }

  Future<void> toggleMicrophone(bool enable) async {
    try {
      await _localParticipant?.setMicrophoneEnabled(enable);
      isMicEnabled.value = enable;
    } catch (e) {
      debugPrint('═══ LiveKit toggleMicrophone ERROR ═══');
      debugPrint('Error: $e');
    }
  }

  Future<void> toggleCamera(bool enable) async {
    try {
      await _localParticipant?.setCameraEnabled(enable);
      isCameraEnabled.value = enable;
    } catch (e) {
      debugPrint('═══ LiveKit toggleCamera ERROR ═══');
      debugPrint('Error: $e');
    }
  }

  Future<void> toggleSpeaker(bool enable) async {
    try {
      await Helper.setSpeakerphoneOn(enable);
      isSpeakerOn.value = enable;
    } catch (e) {
      debugPrint('Speaker toggle error: $e');
    }
  }

  Future<void> muteRemoteUser(String uid, bool mute) async {
    try {
      if (_room == null) return;
      for (final participant in _room!.remoteParticipants.values) {
        if (participant.identity == uid) {
          // Note: LiveKit SDK does not expose client-side remote track muting
          // This should be handled server-side via socket or control API
          break;
        }
      }
    } catch (e) {
      debugPrint('═══ LiveKit muteRemoteUser ERROR ═══');
      debugPrint('Error: $e');
    }
  }

  Future<void> kickUser(String uid) async {
    try {
      if (_room == null) return;
      // Remote participant removal is handled server-side via socket events.
      // LiveKit client SDK does not expose a client-side kick API.
    } catch (e) {
      // Kick may fail if room is null
    }
  }

  Future<Map<String, dynamic>> _fetchLiveKitToken(
      String roomId, String userId, String userName) async {
    try {
      final token = await _apiService.get('${EnvConfig.liveKitTokenPath}/$roomId/livekit/token');
      if (token is Map && token['token'] != null) return Map<String, dynamic>.from(token);

      final altToken = await _apiService.post('/livekit/token', body: {
        'roomId': roomId,
        'userId': userId,
        'userName': userName,
      });
      if (altToken is Map && altToken['token'] != null) return Map<String, dynamic>.from(altToken);

      return {};
    } catch (e) {
      debugPrint('═══ LiveKit token fetch ERROR ═══');
      debugPrint('Error: $e');
      return {};
    }
  }

  @override
  void onClose() {
    leaveRoom();
    super.onClose();
  }
}