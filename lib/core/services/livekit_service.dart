import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../core/constants/env_config.dart';
import '../services/api_service.dart';

class LiveKitService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final String liveKitWsUrl = EnvConfig.liveKitWsUrl;

  final isConnected = false.obs;
  final isMicEnabled = true.obs;
  final isCameraEnabled = false.obs;
  final isScreenSharing = false.obs;
  final remoteUsers = <RemoteParticipant>[].obs;
  final activeUsers = <Map<String, dynamic>>[].obs;

  Room? _room;
  LocalParticipant? _localParticipant;

  Room? get room => _room;
  LocalParticipant? get localParticipant => _localParticipant;


  Future<void> initialize() async {
    try {
      await LiveKitClient.initialize();
      debugPrint('✅ LiveKit client initialized');
    } catch (e) {
      debugPrint('❌ LiveKit initialization error: $e');
    }
  }

  Future<bool> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    bool enableAudio = true,
    bool enableVideo = false,
  }) async {
    try {
      final tokenResponse = await _fetchLiveKitToken(roomId, userId, userName);
      final token = tokenResponse['token'] as String?;
      final liveKitRoom = tokenResponse['liveKitRoom'] as String? ?? roomId;
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
      debugPrint('✅ Joined LiveKit room: $liveKitRoom');
      return true;
    } catch (e) {
      debugPrint('❌ LiveKit join room error: $e');
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
      debugPrint('❌ LiveKit leave room error: $e');
    }
  }

  Future<void> toggleMicrophone(bool enable) async {
    try {
      await _localParticipant?.setMicrophoneEnabled(enable);
      isMicEnabled.value = enable;
    } catch (e) {
      debugPrint('❌ Error toggling microphone: $e');
    }
  }

  Future<void> toggleCamera(bool enable) async {
    try {
      await _localParticipant?.setCameraEnabled(enable);
      isCameraEnabled.value = enable;
    } catch (e) {
      debugPrint('❌ Error toggling camera: $e');
    }
  }

  Future<void> toggleSpeaker(bool enable) async {
    // Speaker toggle not available in current LiveKit API
  }

  Future<void> muteRemoteUser(String uid, bool mute) async {
    // Remote mute not available in current LiveKit API
  }

  Future<void> kickUser(String uid) async {
    // Kick not available in current LiveKit API
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
      debugPrint('❌ Error fetching LiveKit token: $e');
      return {};
    }
  }

  @override
  void onClose() {
    leaveRoom();
    super.onClose();
  }
}
