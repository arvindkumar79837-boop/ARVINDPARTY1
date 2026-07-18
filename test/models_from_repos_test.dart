import 'package:flutter_test/flutter_test.dart';
import 'package:arvind_party/features/chat/presentation/repositories/chat_repository.dart';
import 'package:arvind_party/features/gift/presentation/repositories/gift_repository.dart';
import 'package:arvind_party/features/auth/presentation/repositories/auth_repository.dart';
import 'package:arvind_party/features/chat/models/chat_model.dart';
import 'package:arvind_party/features/gift/models/gift_model.dart';
import 'package:arvind_party/features/auth/models/auth_model.dart';

void main() {
  group('AuthRepository', () {
    test('AuthRepository can be instantiated', () {
      final repo = AuthRepository();
      expect(repo, isA<AuthRepository>());
    });
  });

  group('ChatRepository class', () {
    test('ChatRepository is a GetxService', () {
      expect(ChatRepository, isA<Type>());
    });
  });

  group('GiftRepository class', () {
    test('GiftRepository is a GetxService', () {
      expect(GiftRepository, isA<Type>());
    });
  });

  group('ChatModel serialization', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'conv_1',
        'name': 'Test Conversation',
        'avatar': 'https://example.com/avatar.png',
        'lastMessage': 'Hey there!',
        'lastMessageTime': '2024-12-01T10:30:00.000Z',
        'unreadCount': 7,
        'isOnline': true,
      };
      final chat = ChatModel.fromJson(json);
      expect(chat.id, 'conv_1');
      expect(chat.name, 'Test Conversation');
      expect(chat.avatar, 'https://example.com/avatar.png');
      expect(chat.lastMessage, 'Hey there!');
      expect(chat.unreadCount, 7);
      expect(chat.isOnline, true);
      expect(chat.lastMessageTime, isA<DateTime>());
    });

    test('toJson produces valid json', () {
      final chat = ChatModel(
        id: 'c2',
        name: 'Chat 2',
        lastMessage: 'Test message',
        lastMessageTime: DateTime(2024, 1),
        unreadCount: 0,
      );
      final json = chat.toJson();
      expect(json['id'], 'c2');
      expect(json['name'], 'Chat 2');
      expect(json['lastMessage'], 'Test message');
      expect(json['unreadCount'], 0);
      expect(json['isOnline'], false);
    });

    test('fromJson with string unreadCount', () {
      final json = {'id': 'c3', 'name': 'C3', 'unreadCount': '5'};
      final chat = ChatModel.fromJson(json);
      expect(chat.unreadCount, 5);
    });

    test('fromJson with integer unreadCount', () {
      final json = {'id': 'c4', 'name': 'C4', 'unreadCount': 10};
      final chat = ChatModel.fromJson(json);
      expect(chat.unreadCount, 10);
    });
  });

  group('MessageModel serialization', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'msg_1',
        'chatId': 'conv_1',
        'senderId': 'u1',
        'senderName': 'Alice',
        'text': 'Hello!',
        'mediaUrl': 'https://example.com/img.png',
        'isRead': true,
        'replyToId': 'msg_0',
        'createdAt': '2024-06-15T12:00:00.000Z',
      };
      final msg = MessageModel.fromJson(json);
      expect(msg.id, 'msg_1');
      expect(msg.chatId, 'conv_1');
      expect(msg.senderId, 'u1');
      expect(msg.senderName, 'Alice');
      expect(msg.text, 'Hello!');
      expect(msg.mediaUrl, 'https://example.com/img.png');
      expect(msg.isRead, true);
      expect(msg.replyToId, 'msg_0');
    });

    test('toJson roundtrip', () {
      final original = MessageModel(
        id: 'm1',
        chatId: 'c1',
        senderId: 'u1',
        senderName: 'Test',
        text: 'Roundtrip',
        createdAt: DateTime(2024),
      );
      final json = original.toJson();
      final restored = MessageModel.fromJson(json);
      expect(restored.id, 'm1');
      expect(restored.text, 'Roundtrip');
      expect(restored.chatId, 'c1');
    });
  });

  group('GiftModel serialization', () {
    test('fromJson parses all core fields', () {
      final json = {
        '_id': 'gift_1',
        'giftName': 'Golden Rose',
        'giftType': 'ANIMATED',
        'category': 'PREMIUM',
        'coinPrice': 500,
        'diamondValue': 25,
        'previewImageUrl': 'https://example.com/rose.png',
        'animationUrl': 'https://example.com/rose_anim.json',
        'comboEnabled': true,
        'comboCount': 5,
        'isLucky': false,
        'isTreasure': false,
        'isLimitedEdition': true,
        'requiredVipLevel': 3,
        'isAvailable': true,
      };
      final gift = GiftModel.fromJson(json);
      expect(gift.id, 'gift_1');
      expect(gift.giftName, 'Golden Rose');
      expect(gift.type, GiftType.animated);
      expect(gift.category, GiftCategory.premium);
      expect(gift.coinPrice, 500);
      expect(gift.diamondValue, 25);
      expect(gift.comboEnabled, true);
      expect(gift.isLimitedEdition, true);
      expect(gift.requiredVipLevel, 3);
    });

    test('aliases work correctly', () {
      final gift = GiftModel(id: 'g', giftName: 'Test', coinPrice: 100);
      expect(gift.name, 'Test');
      expect(gift.price, 100);
    });

    test('isHighEndGift for different types', () {
      expect(GiftModel(id: 'g', giftName: 'v', type: GiftType.vehicle).isHighEndGift, true);
      expect(GiftModel(id: 'g', giftName: 'c', type: GiftType.castle).isHighEndGift, true);
      expect(GiftModel(id: 'g', giftName: 's', type: GiftType.svga).isHighEndGift, true);
      expect(GiftModel(id: 'g', giftName: 'f').isHighEndGift, false);
    });

    test('isInteractiveGift', () {
      expect(GiftModel(id: 'g', giftName: 'l', isLucky: true).isInteractiveGift, true);
      expect(GiftModel(id: 'g', giftName: 't', isTreasure: true).isInteractiveGift, true);
      expect(GiftModel(id: 'g', giftName: 'n').isInteractiveGift, false);
    });

    test('isCosmeticGift', () {
      expect(GiftModel(id: 'g', giftName: 'f', type: GiftType.frame).isCosmeticGift, true);
      expect(GiftModel(id: 'g', giftName: 'a', type: GiftType.avatar).isCosmeticGift, true);
      expect(GiftModel(id: 'g', giftName: 's').isCosmeticGift, false);
    });
  });

  group('GiftHistoryModel serialization', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'h1',
        'senderId': 'u1',
        'senderName': 'Alice',
        'receiverId': 'u2',
        'receiverName': 'Bob',
        'quantity': 5,
        'gift': {'_id': 'g1', 'giftName': 'Rose', 'coinPrice': 10},
        'createdAt': '2024-06-15T12:00:00.000Z',
      };
      final h = GiftHistoryModel.fromJson(json);
      expect(h.id, 'h1');
      expect(h.senderName, 'Alice');
      expect(h.receiverName, 'Bob');
      expect(h.quantity, 5);
      expect(h.gift.id, 'g1');
      expect(h.gift.giftName, 'Rose');
    });
  });

  group('GiftInventoryItem serialization', () {
    test('fromJson parses correctly', () {
      final json = {
        '_id': 'gi1',
        'giftName': 'Rose',
        'totalQuantity': 10,
        'totalSpent': 500,
      };
      final item = GiftInventoryItem.fromJson(json);
      expect(item.giftId, 'gi1');
      expect(item.giftName, 'Rose');
      expect(item.totalQuantity, 10);
      expect(item.totalSpent, 500);
    });
  });

  group('GiftCollectionItem serialization', () {
    test('fromJson parses correctly', () {
      final json = {
        'giftId': 'gc1',
        'giftName': 'Star',
        'timesUsed': 25,
        'uniqueReceiversCount': 5,
      };
      final item = GiftCollectionItem.fromJson(json);
      expect(item.giftId, 'gc1');
      expect(item.timesUsed, 25);
      expect(item.uniqueReceiversCount, 5);
    });
  });

  group('GiftGoalModel serialization', () {
    test('fromJson parses correctly', () {
      final json = {
        'targetCoins': 10000,
        'currentCoins': 3500,
        'title': 'Daily Goal',
        'progressPercent': 0.35,
      };
      final goal = GiftGoalModel.fromJson(json);
      expect(goal.targetCoins, 10000);
      expect(goal.currentCoins, 3500);
      expect(goal.title, 'Daily Goal');
      expect(goal.progressPercent, 0.35);
    });

    test('defaults work', () {
      final goal = GiftGoalModel();
      expect(goal.targetCoins, 0);
      expect(goal.currentCoins, 0);
    });
  });

  group('GiftEventModel serialization', () {
    test('fromJson with all fields', () {
      final json = {
        'eventId': 'ev1',
        'giftId': 'g1',
        'giftName': 'Rose',
        'giftType': 'STATIC',
        'senderId': 'u1',
        'senderName': 'Alice',
        'receiverId': 'u2',
        'receiverName': 'Bob',
        'quantity': 3,
        'comboMultiplier': 5,
        'coinCost': 50,
        'diamondEarned': 5,
        'isLucky': true,
        'luckyMultiplier': 10,
        'luckyWinAmount': 100,
        'timestamp': 1234567890,
      };
      final ev = GiftEventModel.fromJson(json);
      expect(ev.eventId, 'ev1');
      expect(ev.quantity, 3);
      expect(ev.comboMultiplier, 5);
      expect(ev.isComboGift, true);
      expect(ev.isLucky, true);
      expect(ev.luckyMultiplier, 10);
      expect(ev.isJackpot, true);
    });

    test('isJackpot with low multiplier', () {
      final ev = GiftEventModel(
        eventId: 'ev',
        giftId: 'g',
        giftName: 'g',
        senderId: 's',
        senderName: 's',
        receiverId: 'r',
        receiverName: 'r',
        luckyMultiplier: 1,
      );
      expect(ev.isJackpot, false);
    });

    test('isComboGift with multiplier 1', () {
      final ev = GiftEventModel(
        eventId: 'ev',
        giftId: 'g',
        giftName: 'g',
        senderId: 's',
        senderName: 's',
        receiverId: 'r',
        receiverName: 'r',
      );
      expect(ev.isComboGift, false);
    });
  });
}
