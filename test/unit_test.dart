import 'package:arvind_party/core/constants/app_constants.dart';
import 'package:arvind_party/core/theme/app_colors.dart';
import 'package:arvind_party/core/theme/app_theme.dart';
import 'package:arvind_party/core/utils/api_exception.dart';
import 'package:arvind_party/core/utils/api_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('app name is correct', () {
      expect(AppConstants.appName, 'ARVIND PARTY');
    });

    test('validation limits are sane', () {
      expect(AppConstants.minPasswordLength, greaterThan(0));
      expect(AppConstants.maxPasswordLength, greaterThan(AppConstants.minPasswordLength));
      expect(AppConstants.maxOtpLength, 6);
    });

    test('wallet limits are sane', () {
      expect(AppConstants.minRechargeAmount, greaterThan(0));
      expect(AppConstants.maxRechargeAmount, greaterThan(AppConstants.minRechargeAmount));
      expect(AppConstants.minWithdrawalAmount, greaterThan(0));
    });

    test('commission rates sum to 1.0', () {
      const total = AppConstants.giftCommissionRate +
          AppConstants.agencyCommissionRate +
          AppConstants.platformCommissionRate;
      expect(total, closeTo(1.0, 0.001));
    });

    test('level system values are positive', () {
      expect(AppConstants.maxLevel, greaterThan(0));
      expect(AppConstants.expPerLevel, greaterThan(0));
      expect(AppConstants.dailyExpLimit, greaterThan(0));
    });

    test('storage keys are non-empty strings', () {
      expect(AppConstants.storageToken, isNotEmpty);
      expect(AppConstants.storageUserId, isNotEmpty);
      expect(AppConstants.storageLanguage, isNotEmpty);
    });
  });

  group('AppColors', () {
    test('primary color is correct hex', () {
      expect(AppColors.primary.value, 0xFFFF6B00);
    });

    test('background color is correct hex', () {
      expect(AppColors.background.value, 0xFF0F0E17);
    });

    test('surface and card colors are distinct', () {
      expect(AppColors.surface, isNot(equals(AppColors.card)));
    });
  });

  group('AppTheme', () {
    test('darkTheme has correct primary color', () {
      final theme = AppTheme.darkTheme;
      expect(theme.primaryColor, AppColors.primary);
    });

    test('darkTheme has correct scaffold background', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('darkTheme uses Material 3', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('lightTheme uses Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
    });
  });

  group('ApiResponse', () {
    test('constructor creates success response', () {
      final response = ApiResponse<String>(
        success: true,
        message: 'OK',
        data: 'test',
      );
      expect(response.success, isTrue);
      expect(response.message, 'OK');
      expect(response.data, 'test');
      expect(response.statusCode, 200);
    });

    test('fromJson parses correctly', () {
      final json = {
        'success': true,
        'message': 'Fetched',
        'data': 'hello',
        'statusCode': 200,
      };
      final response = ApiResponse<String>.fromJson(json);
      expect(response.success, isTrue);
      expect(response.message, 'Fetched');
      expect(response.statusCode, 200);
    });

    test('fromJson handles missing fields gracefully', () {
      final response = ApiResponse<dynamic>.fromJson({});
      expect(response.success, isFalse);
      expect(response.message, '');
      expect(response.statusCode, 200);
    });

    test('toString contains key info', () {
      final response = ApiResponse<int>(success: true, message: 'ok');
      expect(response.toString(), contains('success: true'));
      expect(response.toString(), contains('message: ok'));
    });
  });

  group('ApiListResponse', () {
    test('fromJson parses list data', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': [1, 2, 3],
        'total': 3,
        'page': 1,
        'totalPages': 1,
      };
      final response = ApiListResponse<int>.fromJson(json, fromJsonT: (e) => e as int);
      expect(response.success, isTrue);
      expect(response.data, [1, 2, 3]);
      expect(response.total, 3);
    });

    test('fromJson defaults on empty', () {
      final response = ApiListResponse<String>.fromJson({}, fromJsonT: (e) => e.toString());
      expect(response.success, isFalse);
      expect(response.data, isEmpty);
    });
  });

  group('ApiException', () {
    test('constructor stores fields', () {
      final ex = ApiException(message: 'err', statusCode: 500);
      expect(ex.message, 'err');
      expect(ex.statusCode, 500);
    });

    test('unauthorized factory', () {
      final ex = ApiException.unauthorized();
      expect(ex.statusCode, 401);
      expect(ex.message, contains('expired'));
    });

    test('notFound factory', () {
      final ex = ApiException.notFound('User');
      expect(ex.statusCode, 404);
      expect(ex.message, contains('User'));
    });

    test('serverError factory', () {
      final ex = ApiException.serverError();
      expect(ex.statusCode, 500);
    });

    test('networkError factory', () {
      final ex = ApiException.networkError();
      expect(ex.statusCode, 0);
      expect(ex.message, contains('internet'));
    });

    test('validationError factory', () {
      final ex = ApiException.validationError({'email': 'invalid'});
      expect(ex.statusCode, 422);
      expect(ex.errors, isA<Map>());
    });

    test('fromDioError with non-map returns network error', () {
      final ex = ApiException.fromDioError('timeout');
      expect(ex.message, contains('Network'));
    });

    test('fromDioError with map parses fields', () {
      final ex = ApiException.fromDioError({
        'message': 'Bad',
        'statusCode': 400,
      });
      expect(ex.message, 'Bad');
      expect(ex.statusCode, 400);
    });

    test('toString contains message', () {
      final ex = ApiException(message: 'fail', statusCode: 418);
      expect(ex.toString(), contains('fail'));
    });
  });
}
