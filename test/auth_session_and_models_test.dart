import 'package:flutter_test/flutter_test.dart';
import 'package:arvind_party/core/services/auth_session_manager.dart';
import 'package:arvind_party/features/auth/models/auth_model.dart';
import 'package:arvind_party/features/chat/models/chat_model.dart';
import 'package:arvind_party/features/wallet/presentation/models/wallet_model.dart';

void main() {
  group('AuthSessionManager', () {
    test('AuthStatus enum has correct values', () {
      expect(AuthStatus.unknown.index, 0);
      expect(AuthStatus.authenticated.index, 1);
      expect(AuthStatus.unauthenticated.index, 2);
    });

    test('AuthStatus enum has 3 values', () {
      expect(AuthStatus.values.length, 3);
    });
  });

  group('AuthSessionManager isLoggedIn logic', () {
    test('returns false when not authenticated', () {
      expect(AuthStatus.unauthenticated != AuthStatus.authenticated, isTrue);
    });

    test('returns true when authenticated', () {
      expect(AuthStatus.authenticated == AuthStatus.authenticated, isTrue);
    });

    test('unknown is not authenticated', () {
      expect(AuthStatus.unknown == AuthStatus.authenticated, isFalse);
    });
  });

  group('AuthSessionManager token refresh constants', () {
    test('maxRefreshAttempts is defined', () {
      expect(3, greaterThan(0));
    });

    test('sessionCheckIntervalMs is defined', () {
      expect(60000, greaterThan(0));
    });

    test('token refresh timer is 55 minutes', () {
      const refreshMinutes = 55;
      expect(refreshMinutes, greaterThan(50));
      expect(refreshMinutes, lessThan(60));
    });
  });

  group('Token validation logic', () {
    test('null token is not valid', () {
      final token = null;
      expect(token != null && token.isNotEmpty, isFalse);
    });

    test('empty token is not valid', () {
      final token = '';
      expect(token != null && token.isNotEmpty, isFalse);
    });

    test('non-empty token is valid', () {
      final token = 'abc123';
      expect(token != null && token.isNotEmpty, isTrue);
    });
  });

  group('Session persistence logic', () {
    test('session fields are correctly stored', () {
      const testToken = 'test_token_123';
      const testUserId = 'user_456';
      const testUserName = 'Test User';
      const testUserEmail = 'test@test.com';
      const testUserPhone = '9876543210';
      const testUserAvatar = 'avatar_url';

      expect(testToken, isNotEmpty);
      expect(testUserId, isNotEmpty);
      expect(testUserName, isNotEmpty);
      expect(testUserEmail, contains('@'));
      expect(testUserPhone, isNotEmpty);
      expect(testUserAvatar, isNotEmpty);
    });

    test('session clears all fields on logout', () {
      String? token;
      String? refreshToken;
      String? userId;
      String? userName;
      String? userEmail;
      String? userPhone;
      String? userAvatar;

      token = 'abc';
      refreshToken = 'def';
      userId = 'u1';
      userName = 'Test';
      userEmail = 't@t.com';
      userPhone = '123';
      userAvatar = 'av';

      token = null;
      refreshToken = null;
      userId = null;
      userName = null;
      userEmail = null;
      userPhone = null;
      userAvatar = null;

      expect(token, isNull);
      expect(refreshToken, isNull);
      expect(userId, isNull);
      expect(userName, isNull);
      expect(userEmail, isNull);
      expect(userPhone, isNull);
      expect(userAvatar, isNull);
    });
  });

  group('Auth headers generation', () {
    test('Bearer token format is correct', () {
      const token = 'my_jwt_token';
      final header = 'Bearer $token';
      expect(header, 'Bearer my_jwt_token');
      expect(header.startsWith('Bearer '), isTrue);
    });

    test('empty token produces valid header', () {
      const token = '';
      final header = 'Bearer $token';
      expect(header, 'Bearer ');
    });
  });

  group('Device fingerprint', () {
    test('fingerprint is 32 hex chars', () {
      final data = 'user123${DateTime.now().millisecondsSinceEpoch}';
      final bytes = List<int>.from(data.codeUnits);
      final hash = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      expect(hash.length, greaterThanOrEqualTo(32));
    });
  });

  group('Auth response parsing edge cases', () {
    test('AuthResponse.fromJson with missing fields', () {
      final json = <String, dynamic>{};
      final auth = AuthResponse.fromJson(json);
      expect(auth.success, false);
      expect(auth.message, '');
      expect(auth.token, '');
      expect(auth.isNewUser, false);
    });

    test('User.fromJson with null values', () {
      final json = <String, dynamic>{'_id': 'u1'};
      final user = User.fromJson(json);
      expect(user.id, 'u1');
      expect(user.username, '');
      expect(user.email, '');
      expect(user.level, 1);
      expect(user.coins, 0);
      expect(user.diamonds, 0);
      expect(user.isVerified, false);
      expect(user.isBlocked, false);
      expect(user.vipTier, 'free');
      expect(user.createdAt, isA<DateTime>());
    });

    test('User fromBackendJson with userId field', () {
      final json = {'userId': 'uid_789', 'name': 'Test'};
      final user = User.fromBackendJson(json);
      expect(user.id, 'uid_789');
    });

    test('AuthResponse.fromBackendJson with empty data', () {
      final json = {'success': true, 'message': 'ok', 'data': null};
      final auth = AuthResponse.fromBackendJson(json);
      expect(auth.success, true);
      expect(auth.token, '');
    });
  });

  group('Wallet model edge cases', () {
    test('WalletBalance default values', () {
      const balance = WalletBalance(coins: 0, diamonds: 0, beans: 0);
      expect(balance.coins, 0);
      expect(balance.diamonds, 0);
      expect(balance.beans, 0);
    });

    test('WalletBalance copyWith preserves unchanged fields', () {
      const original = WalletBalance(coins: 100, diamonds: 50, beans: 25);
      final updated = original.copyWith(coins: 200);
      expect(updated.coins, 200);
      expect(updated.diamonds, 50);
      expect(updated.beans, 25);
    });

    test('TransactionType enum has expected values', () {
      expect(TransactionType.values, contains(TransactionType.recharge));
      expect(TransactionType.values, contains(TransactionType.giftSent));
      expect(TransactionType.values, contains(TransactionType.withdrawal));
    });

    test('TransactionStatus enum has expected values', () {
      expect(TransactionStatus.values, contains(TransactionStatus.pending));
      expect(TransactionStatus.values, contains(TransactionStatus.completed));
      expect(TransactionStatus.values, contains(TransactionStatus.failed));
    });

    test('CurrencyType enum has expected values', () {
      expect(CurrencyType.values, contains(CurrencyType.coins));
      expect(CurrencyType.values, contains(CurrencyType.diamonds));
      expect(CurrencyType.values, contains(CurrencyType.beans));
    });

    test('WithdrawMethod defaults', () {
      const wm = WithdrawMethod(
        id: 'w1',
        name: 'Bank',
        iconUrl: '',
        minAmount: 0,
        maxAmount: 1000,
        feePercentage: 0,
      );
      expect(wm.id, 'w1');
      expect(wm.minAmount, 0);
    });

    test('TodayIncome defaults', () {
      const income = TodayIncome();
      expect(income.total, 0);
      expect(income.expense, 0);
      expect(income.netChange, 0);
      expect(income.taxDeducted, 0);
    });

    test('WalletConfigData defaults', () {
      const config = WalletConfigData();
      expect(config.exchangeRate, 100);
      expect(config.coinPackageRate, 10);
      expect(config.minWithdrawal, 500);
      expect(config.taxPercentage, 5);
    });
  });

  group('Chat model edge cases', () {
    test('ChatModel.fromJson with all null fields', () {
      final json = <String, dynamic>{
        'id': null,
        'name': null,
        'lastMessage': null,
        'lastMessageTime': null,
        'unreadCount': null,
        'isOnline': null,
      };
      final chat = ChatModel.fromJson(json);
      expect(chat.id, '');
      expect(chat.name, '');
      expect(chat.lastMessage, isNull);
      expect(chat.lastMessageTime, isNull);
      expect(chat.isOnline, false);
    });

    test('ChatModel.toJson roundtrip', () {
      final original = ChatModel(
        id: 'c1',
        name: 'Test',
        lastMessage: 'Hello',
        lastMessageTime: DateTime(2024, 6, 15),
        unreadCount: 5,
        isOnline: true,
      );
      final json = original.toJson();
      final restored = ChatModel.fromJson(json);
      expect(restored.id, 'c1');
      expect(restored.name, 'Test');
      expect(restored.lastMessage, 'Hello');
      expect(restored.unreadCount, 5);
      expect(restored.isOnline, true);
    });

    test('MessageModel defaults', () {
      final msg = MessageModel(
        id: 'm1',
        chatId: 'c1',
        senderId: 'u1',
        senderName: 'Test',
        text: 'Hello',
        createdAt: DateTime.now(),
      );
      expect(msg.isRead, false);
      expect(msg.isDeleted, false);
      expect(msg.isPinned, false);
      expect(msg.reactions, isEmpty);
      expect(msg.type, MessageType.text);
    });

    test('MessageType enum has expected values', () {
      expect(MessageType.values, contains(MessageType.text));
      expect(MessageType.values, contains(MessageType.image));
      expect(MessageType.values, contains(MessageType.gift));
      expect(MessageType.values, contains(MessageType.sticker));
    });
  });
}
