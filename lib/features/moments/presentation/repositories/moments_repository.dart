import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class MomentsRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (_) {
      return null;
    }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Fetch moments feed
  /// GET /api/moments
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final response = await _dio.get(
        ApiConstants.momentsFeed,
        options: _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final posts = data['data'] as List<dynamic>? ?? [];
        return posts.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch moments');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Create a new moment post
  /// POST /api/moments/create
  Future<Map<String, dynamic>> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
  }) async {
    try {
      final body = <String, dynamic>{
        'content': content,
      };
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        body['mediaUrls'] = mediaUrls;
      }
      if (mediaType != null) {
        body['mediaType'] = mediaType;
      }

      final response = await _dio.post(
        ApiConstants.postCreation,
        data: body,
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Like a post
  /// POST /api/moments/{postId}/like
  Future<void> likePost(String postId) async {
    try {
      await _dio.post(
        '${ApiConstants.likeSystem}/$postId/like',
        options: _authOptions(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Add a comment to a post
  /// POST /api/moments/{postId}/comment
  Future<Map<String, dynamic>> addComment(String postId, String text) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.commentSystem}/$postId/comment',
        data: {'text': text},
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}
