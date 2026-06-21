// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/services/agora_service.dart
// ARVIND PARTY - AGORA REAL-TIME COMMUNICATION SERVICE
// ═══════════════════════════════════════════════════════════════════════════

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class AgoraService extends GetxService {
  late RtcEngine _agoraEngine;
  final ApiService _apiService = Get.find<ApiService>();

  // Agora configuration
  final appId = 'YOUR_AGORA_APP_ID'; // Set from config/environment
  
  // Room state
  final isConnected = false.obs;
  final isMicEnabled = true.obs;
  final isCameraEnabled = true.obs;
  final isScreenSharing = false.obs;
  final remoteUsers = <int>[].obs;
  final activeUsers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAgora();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initializeAgora() async {
    try {
      _agoraEngine = createAgoraRtcEngine();

      await _agoraEngine.initialize(const RtcEngineContext(
        appId: 'YOUR_AGORA_APP_ID',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Enable audio
      await _agoraEngine.enableAudio();
      await _agoraEngine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioDefault,
      );

      // Enable video
      await _agoraEngine.enableVideo();
      await _agoraEngine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 540, height: 960),
          frameRate: 15,
          bitrate: 1130,
          degradationPreference: DegradationPreference.maintainFramerate,
        ),
      );

      _setupAgoraEventHandlers();
      debugPrint('✅ Agora engine initialized');
    } catch (e) {
      debugPrint('❌ Agora initialization error: $e');
    }
  }

  void _setupAgoraEventHandlers() {
    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('✅ Joined channel: ${connection.channelId}');
          isConnected.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('✅ User joined: $remoteUid');
          remoteUsers.add(remoteUid);
          _fetchUserDetails(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👤 User offline: $remoteUid');
          remoteUsers.removeWhere((uid) => uid == remoteUid);
          activeUsers.removeWhere((user) => user['uid'] == remoteUid);
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('✅ Left channel');
          isConnected.value = false;
          remoteUsers.clear();
          activeUsers.clear();
        },
        onError: (ErrorCodeType errorCode, String errorMessage) {
          debugPrint('❌ Agora error: $errorCode - $errorMessage');
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JOIN / LEAVE ROOM
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> joinRoom({
    required String roomId,
    required int userId,
    required bool enableAudio,
    required bool enableCamera,
  }) async {
    try {
      // Get Agora token from backend
      final tokenResponse = await _apiService.get('/room/$roomId/agora/token');
      final token = tokenResponse['token'];

      // Join channel with fixed ChannelMediaOptions for 6.x SDK
      await _agoraEngine.joinChannel(
        token: token,
        channelId: roomId,
        uid: userId,
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: enableAudio,
          publishCameraTrack: enableCamera,
          clientRoleType: ClientRoleType.clientRoleBroadcaster, // Role set karna zaroori hai
        ),
      );

      isMicEnabled.value = enableAudio;
      isCameraEnabled.value = enableCamera;

      debugPrint('✅ Joined room: $roomId');
    } catch (e) {
      debugPrint('❌ Error joining room: $e');
      rethrow;
    }
  }

  Future<void> leaveRoom() async {
    try {
      await _agoraEngine.leaveChannel();
      isConnected.value = false;
      remoteUsers.clear();
      activeUsers.clear();
      debugPrint('✅ Left room');
    } catch (e) {
      debugPrint('❌ Error leaving room: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUDIO / VIDEO CONTROLS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> toggleMicrophone(bool enable) async {
    try {
      // Naye SDK me mute/unmute use hota hai stream control ke liye
      await _agoraEngine.muteLocalAudioStream(!enable);
      isMicEnabled.value = enable;
      debugPrint('${enable ? '✅' : '❌'} Microphone ${enable ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Error toggling microphone: $e');
    }
  }

  Future<void> toggleCamera(bool enable) async {
    try {
      // Naye SDK me mute/unmute use hota hai stream control ke liye
      await _agoraEngine.muteLocalVideoStream(!enable);
      isCameraEnabled.value = enable;
      debugPrint('${enable ? '✅' : '❌'} Camera ${enable ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Error toggling camera: $e');
    }
  }

  Future<void> muteRemoteUser(int uid, bool mute) async {
    try {
      await _agoraEngine.muteRemoteAudioStream(uid: uid, mute: mute);
      debugPrint('${mute ? '🔇' : '🔊'} User $uid ${mute ? 'muted' : 'unmuted'}');
    } catch (e) {
      debugPrint('❌ Error muting user: $e');
    }
  }

  Future<void> startScreenShare() async {
    try {
      // Screen share activate karne ka basic logic (platform specific setups handle hone par)
      await _agoraEngine.startScreenCapture(const ScreenCaptureParameters2(
        captureAudio: true,
        captureVideo: true,
      ));
      isScreenSharing.value = true;
      debugPrint('✅ Screen sharing started');
    } catch (e) {
      debugPrint('❌ Error starting screen share: $e');
    }
  }

  Future<void> stopScreenShare() async {
    try {
      await _agoraEngine.stopScreenCapture();
      isScreenSharing.value = false;
      debugPrint('✅ Screen sharing stopped');
    } catch (e) {
      debugPrint('❌ Error stopping screen share: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROOM MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> kickUser(int uid, String roomId) async {
    try {
      await _apiService.post('/room/$roomId/kick-user', body: {'uid': uid});
      debugPrint('✅ User $uid kicked from room');
    } catch (e) {
      debugPrint('❌ Error kicking user: $e');
    }
  }

  Future<void> promoteUserToCoHost(int uid, String roomId) async {
    try {
      await _apiService.post('/room/$roomId/promote-cohost', body: {'uid': uid});
      debugPrint('✅ User $uid promoted to co-host');
    } catch (e) {
      debugPrint('❌ Error promoting user: $e');
    }
  }

  Future<void> _fetchUserDetails(int uid) async {
    try {
      // Fetch user details from room members endpoint
      // Add to activeUsers list
      debugPrint('👤 Fetched details for user: $uid');
    } catch (e) {
      debugPrint('⚠️ Error fetching user details: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    // Engine release karne se pehle active channel chorna safe rehta hai
    _agoraEngine.leaveChannel();
    _agoraEngine.release();
    super.onClose();
  }
}