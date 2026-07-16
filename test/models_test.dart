import 'package:flutter_test/flutter_test.dart';
import 'package:arvind_party/features/auth/models/auth_model.dart';
import 'package:arvind_party/features/wallet/presentation/models/wallet_model.dart';
import 'package:arvind_party/features/chat/models/chat_model.dart';
import 'package:arvind_party/features/gift/models/gift_model.dart';
import 'package:arvind_party/features/room/models/room_models.dart';

void main() {
  group('User model', () {
    test('fromJson parses correctly', () {
      final json = {
        '_id': 'user123',
        'username': 'TestUser',
        'email': 'test@test.com',
        'level': 5,
        'xp': 500,
        'coins': 1000,
        'diamonds': 50,
        'isVerified': true,
        'isBlocked': false,
        'vipTier': 'gold',
        'avatar': 'https://example.com/avatar.jpg',
        'phone': '9876543210',
        'name': 'Test User',
        'arvindId': 'ARV001',
      };
      final user = User.fromJson(json);
      expect(user.id, 'user123');
      expect(user.username, 'TestUser');
      expect(user.email, 'test@test.com');
      expect(user.level, 5);
      expect(user.xp, 500);
      expect(user.coins, 1000);
      expect(user.diamonds, 50);
      expect(user.isVerified, true);
      expect(user.isBlocked, false);
      expect(user.vipTier, 'gold');
    });

    test('fromJson with empty json uses defaults', () {
      final user = User.fromJson({});
      expect(user.id, '');
      expect(user.username, '');
      expect(user.level, 1);
      expect(user.xp, 0);
      expect(user.coins, 0);
      expect(user.diamonds, 0);
      expect(user.isVerified, false);
      expect(user.vipTier, 'free');
      expect(user.followers, isEmpty);
      expect(user.following, isEmpty);
    });

    test('fromBackendJson parses backend response', () {
      final json = {
        '_id': 'user456',
        'name': 'Backend User',
        'phone': '1234567890',
        'level': 10,
      };
      final user = User.fromBackendJson(json);
      expect(user.id, 'user456');
      expect(user.name, 'Backend User');
      expect(user.phone, '1234567890');
      expect(user.level, 10);
    });

    test('toJson contains expected fields', () {
      final user = User(id: 'u1', username: 'test', email: 't@t.com', createdAt: DateTime(2024));
      final json = user.toJson();
      expect(json['id'], 'u1');
      expect(json['username'], 'test');
      expect(json['email'], 't@t.com');
    });
  });

  group('AuthResponse model', () {
    test('fromJson parses correctly', () {
      final json = {
        'success': true,
        'message': 'OK',
        'token': 'abc123',
        'refreshToken': 'ref456',
        'isNewUser': false,
        'user': {'_id': 'u1'},
      };
      final auth = AuthResponse.fromJson(json);
      expect(auth.success, true);
      expect(auth.message, 'OK');
      expect(auth.token, 'abc123');
      expect(auth.refreshToken, 'ref456');
      expect(auth.isNewUser, false);
    });

    test('fromBackendJson parses nested data', () {
      final json = {
        'success': true,
        'message': 'Login success',
        'data': {
          'token': 'jwt_token',
          'refreshToken': 'refresh_token',
          'user': {'_id': 'u2', 'name': 'Test'},
        },
      };
      final auth = AuthResponse.fromBackendJson(json);
      expect(auth.success, true);
      expect(auth.token, 'jwt_token');
      expect(auth.refreshToken, 'refresh_token');
    });
  });

  group('StringSlice extension', () {
    test('slice with negative index', () {
      expect('hello'.slice(-3), 'llo');
    });

    test('slice with range', () {
      expect('hello'.slice(1, 3), 'el');
    });
  });

  group('WalletBalance model', () {
    test('fromJson parses correctly', () {
      final json = {'coins': 100, 'diamonds': 50, 'beans': 25};
      final balance = WalletBalance.fromJson(json);
      expect(balance.coins, 100);
      expect(balance.diamonds, 50);
      expect(balance.beans, 25);
    });

    test('fromJson with empty uses zeros', () {
      final balance = WalletBalance.fromJson({});
      expect(balance.coins, 0);
      expect(balance.diamonds, 0);
      expect(balance.beans, 0);
    });

    test('copyWith creates new instance', () {
      final original = WalletBalance(coins: 10, diamonds: 5, beans: 2);
      final copied = original.copyWith(coins: 20);
      expect(copied.coins, 20);
      expect(copied.diamonds, 5);
      expect(original.coins, 10);
    });
  });

  group('TransactionModel', () {
    test('fromJson parses correctly', () {
      final json = {
        '_id': 'tx1',
        'transactionId': 'TXN001',
        'type': 'recharge',
        'walletType': 'coin',
        'currency': 'coins',
        'amount': 500,
        'status': 'completed',
        'createdAt': '2024-01-15T10:30:00.000Z',
      };
      final tx = TransactionModel.fromJson(json);
      expect(tx.id, 'tx1');
      expect(tx.transactionId, 'TXN001');
      expect(tx.type, TransactionType.recharge);
      expect(tx.walletType, WalletType.coin);
      expect(tx.amount, 500);
      expect(tx.status, TransactionStatus.completed);
    });

    test('fromJson with unknown type defaults to recharge', () {
      final json = {
        '_id': 'tx2',
        'type': 'unknown_type',
        'walletType': 'coin',
        'status': 'completed',
        'createdAt': '2024-01-15T10:30:00.000Z',
      };
      final tx = TransactionModel.fromJson(json);
      expect(tx.type, TransactionType.recharge);
    });
  });

  group('RechargePackage', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'pkg1',
        'name': 'Starter',
        'price': 9.99,
        'coins': 1000,
        'diamonds': 10,
        'beans': 0,
        'isPopular': true,
      };
      final pkg = RechargePackage.fromJson(json);
      expect(pkg.id, 'pkg1');
      expect(pkg.name, 'Starter');
      expect(pkg.price, 9.99);
      expect(pkg.coins, 1000);
      expect(pkg.isPopular, true);
    });
  });

  group('WithdrawMethod', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'wm1',
        'name': 'Bank Transfer',
        'minAmount': 100,
        'maxAmount': 10000,
        'feePercentage': 2.5,
      };
      final wm = WithdrawMethod.fromJson(json);
      expect(wm.id, 'wm1');
      expect(wm.name, 'Bank Transfer');
      expect(wm.minAmount, 100.0);
      expect(wm.maxAmount, 10000.0);
      expect(wm.feePercentage, 2.5);
    });
  });

  group('ChatModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'conv1',
        'name': 'Priya',
        'avatar': 'https://example.com/av.jpg',
        'lastMessage': 'Hello!',
        'lastMessageTime': '2024-01-15T10:30:00.000Z',
        'unreadCount': 3,
        'isOnline': true,
      };
      final chat = ChatModel.fromJson(json);
      expect(chat.id, 'conv1');
      expect(chat.name, 'Priya');
      expect(chat.lastMessage, 'Hello!');
      expect(chat.unreadCount, 3);
      expect(chat.isOnline, true);
    });

    test('toJson roundtrip preserves data', () {
      final original = ChatModel(
        id: 'c1',
        name: 'Test',
        lastMessage: 'Hi',
        lastMessageTime: DateTime(2024),
        unreadCount: 2,
        isOnline: true,
      );
      final json = original.toJson();
      final restored = ChatModel.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.unreadCount, original.unreadCount);
    });
  });

  group('MessageModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'msg1',
        'chatId': 'conv1',
        'senderId': 'u1',
        'senderName': 'Test',
        'text': 'Hello world',
        'isRead': true,
        'createdAt': '2024-01-15T10:30:00.000Z',
      };
      final msg = MessageModel.fromJson(json);
      expect(msg.id, 'msg1');
      expect(msg.text, 'Hello world');
      expect(msg.isRead, true);
    });

    test('toJson roundtrip preserves data', () {
      final original = MessageModel(
        id: 'm1',
        chatId: 'c1',
        senderId: 'u1',
        senderName: 'A',
        text: 'Test',
        createdAt: DateTime(2024),
      );
      final json = original.toJson();
      final restored = MessageModel.fromJson(json);
      expect(restored.id, 'm1');
      expect(restored.text, 'Test');
    });
  });

  group('GiftModel', () {
    test('fromJson parses correctly', () {
      final json = {
        '_id': 'g1',
        'giftName': 'Rose',
        'giftType': 'STATIC',
        'category': 'BASIC',
        'coinPrice': 10,
        'diamondValue': 1,
      };
      final gift = GiftModel.fromJson(json);
      expect(gift.id, 'g1');
      expect(gift.giftName, 'Rose');
      expect(gift.type, GiftType.static);
      expect(gift.category, GiftCategory.basic);
      expect(gift.coinPrice, 10);
    });

    test('fromJson with combo type', () {
      final json = {'_id': 'g2', 'giftType': 'COMBO', 'category': 'PREMIUM', 'comboEnabled': true};
      final gift = GiftModel.fromJson(json);
      expect(gift.type, GiftType.combo);
      expect(gift.category, GiftCategory.premium);
      expect(gift.comboEnabled, true);
    });

    test('isHighEndGift returns true for vehicle type', () {
      final gift = GiftModel(id: 'g3', giftName: 'Car', type: GiftType.vehicle);
      expect(gift.isHighEndGift, true);
    });

    test('name and price aliases work', () {
      final gift = GiftModel(id: 'g4', giftName: 'Rose', coinPrice: 100);
      expect(gift.name, 'Rose');
      expect(gift.price, 100);
    });
  });

  group('GiftEventModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'eventId': 'ev1',
        'giftId': 'g1',
        'giftName': 'Rose',
        'senderId': 'u1',
        'senderName': 'Alice',
        'receiverId': 'u2',
        'receiverName': 'Bob',
        'quantity': 5,
        'comboMultiplier': 10,
      };
      final ev = GiftEventModel.fromJson(json);
      expect(ev.eventId, 'ev1');
      expect(ev.quantity, 5);
      expect(ev.comboMultiplier, 10);
      expect(ev.isComboGift, true);
    });

    test('isJackpot when luckyMultiplier > 1', () {
      final ev = GiftEventModel(
        eventId: 'ev2',
        giftId: 'g1',
        giftName: 'Lucky',
        senderId: 'u1',
        senderName: 'A',
        receiverId: 'u2',
        receiverName: 'B',
        luckyMultiplier: 100,
      );
      expect(ev.isJackpot, true);
    });
  });

  group('RoomModel (room_models)', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'room1',
        'name': 'Party Room',
        'hostId': 'h1',
        'onlineUsers': 25,
        'seatCount': 8,
        'isLive': true,
        'roomType': 'voice',
        'tags': ['music', 'party'],
      };
      final room = RoomModel.fromJson(json);
      expect(room.id, 'room1');
      expect(room.name, 'Party Room');
      expect(room.onlineUsers, 25);
      expect(room.isLive, true);
      expect(room.tags, ['music', 'party']);
    });

    test('copyWith creates new instance', () {
      final room = RoomModel(id: 'r1', name: 'Room', hostId: 'h1');
      final updated = room.copyWith(name: 'New Room', onlineUsers: 10);
      expect(updated.name, 'New Room');
      expect(updated.onlineUsers, 10);
      expect(room.name, 'Room');
    });

    test('toJson roundtrip preserves data', () {
      final room = RoomModel(id: 'r2', name: 'Test', hostId: 'h2', seatCount: 6);
      final json = room.toJson();
      final restored = RoomModel.fromJson(json);
      expect(restored.id, 'r2');
      expect(restored.seatCount, 6);
    });
  });

  group('SeatData', () {
    test('fromJson parses correctly', () {
      final json = {
        'seatIndex': 2,
        'userId': 'u1',
        'userName': 'Host',
        'isLocked': false,
        'isMuted': true,
        'isHost': true,
        'role': 'broadcaster',
      };
      final seat = SeatData.fromJson(json);
      expect(seat.seatIndex, 2);
      expect(seat.seatNumber, '3');
      expect(seat.isOccupied, true);
      expect(seat.isHost, true);
      expect(seat.isMuted, true);
    });

    test('empty seat has correct status', () {
      final seat = SeatData(seatIndex: 0);
      expect(seat.status, SeatStatus.empty);
      expect(seat.isOccupied, false);
    });

    test('locked seat has correct status', () {
      final seat = SeatData(seatIndex: 0, isLocked: true);
      expect(seat.status, SeatStatus.locked);
    });

    test('toJson roundtrip', () {
      final seat = SeatData(seatIndex: 3, userId: 'u1', userName: 'Test');
      final json = seat.toJson();
      final restored = SeatData.fromJson(json);
      expect(restored.seatIndex, 3);
      expect(restored.userId, 'u1');
    });
  });

  group('RoomTask', () {
    test('progressPercent calculates correctly', () {
      final task = RoomTask(taskId: 't1', title: 'Send 10 gifts', targetValue: 10, currentValue: 5);
      expect(task.progressPercent, closeTo(0.5, 0.01));
    });

    test('isExpired returns true for past date', () {
      final task = RoomTask(
        taskId: 't2',
        title: 'Daily Task',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(task.isExpired, true);
    });

    test('isExpired returns false for future date', () {
      final task = RoomTask(
        taskId: 't3',
        title: 'Daily Task',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(task.isExpired, false);
    });
  });

  group('PKChallenge', () {
    test('fromJson parses correctly', () {
      final json = {
        'challengeId': 'pk1',
        'challengerRoomId': 'r1',
        'opponentRoomId': 'r2',
        'challengerScore': 100,
        'opponentScore': 80,
        'status': 'active',
        'startTime': '2024-01-15T10:00:00.000Z',
      };
      final pk = PKChallenge.fromJson(json);
      expect(pk.challengeId, 'pk1');
      expect(pk.challengerScore, 100);
      expect(pk.isActive, true);
      expect(pk.isCompleted, false);
    });
  });

  group('MemberContribution', () {
    test('fromJson parses correctly', () {
      final json = {
        'userId': 'u1',
        'uid': 'uid1',
        'coinsContributed': 500,
        'diamondsContributed': 10,
        'tasksCompleted': 3,
      };
      final mc = MemberContribution.fromJson(json);
      expect(mc.userId, 'u1');
      expect(mc.coinsContributed, 500);
      expect(mc.tasksCompleted, 3);
    });
  });

  group('GiftHistoryModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'h1',
        'senderId': 'u1',
        'senderName': 'Alice',
        'receiverId': 'u2',
        'receiverName': 'Bob',
        'quantity': 3,
        'gift': {'_id': 'g1', 'giftName': 'Rose', 'coinPrice': 10},
        'createdAt': '2024-01-15T10:30:00.000Z',
      };
      final h = GiftHistoryModel.fromJson(json);
      expect(h.id, 'h1');
      expect(h.quantity, 3);
      expect(h.gift.giftName, 'Rose');
    });
  });

  group('RoomPermissionModel', () {
    test('forRole host has all permissions', () {
      final p = RoomPermissionModel.forRole(MemberRole.host);
      expect(p.canSpeak, true);
      expect(p.canShareVideo, true);
      expect(p.canSendGifts, true);
      expect(p.canInvite, true);
    });

    test('forRole listener has limited permissions', () {
      final p = RoomPermissionModel.forRole(MemberRole.listener);
      expect(p.canSpeak, false);
      expect(p.canShareVideo, false);
      expect(p.canSendGifts, false);
    });
  });

  group('SeatModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'index': 2,
        'userId': 'u1',
        'userName': 'Host',
        'isOccupied': true,
        'isMuted': true,
      };
      final seat = SeatModel.fromJson(json);
      expect(seat.index, 2);
      expect(seat.seatNumber, '3');
      expect(seat.isOccupied, true);
      expect(seat.isMuted, true);
    });

    test('copyWith preserves existing values', () {
      final seat = SeatModel(index: 1, userId: 'u1', userName: 'A', isMuted: true);
      final updated = seat.copyWith(userName: 'B');
      expect(updated.userName, 'B');
      expect(updated.isMuted, true);
      expect(updated.index, 1);
    });
  });
}
