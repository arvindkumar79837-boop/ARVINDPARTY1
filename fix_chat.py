import os

def fix_file(path):
    full = os.path.join('d:/Alarms/arvind_party', path)
    if not os.path.exists(full):
        print(f"SKIP: {path}")
        return
    with open(full, 'r', encoding='utf-8') as fh:
        lines = fh.readlines()
    original = ''.join(lines)
    
    if path == 'lib/features/chat/presentation/views/chat_screen.dart':
        # Fix: controller.messageText is a getter, use textController directly
        content = original.replace(
            'controller.messageText.value = v',
            'controller.textController.text = v'
        )
    elif path == 'lib/features/chat/presentation/views/room_chat_screen.dart':
        # Add initChat method call fix - remove it since controller doesn't have it
        content = original.replace(
            'controller.initChat(roomId);\n',
            '// controller.initChat removed - use loadMessages instead\n'
        )
        # Fix: convert Map message to MessageModel when passing to MessageBubble
        content = content.replace(
            'return msg.MessageBubble(message: message, isMe: message.senderId == \'currentUserId\');',
            'return msg.MessageBubble(message: MessageModel.fromJson(message), isMe: message[\'senderId\'] == \'currentUserId\');'
        )
        # Add import for MessageModel
        if 'import \'../../models/chat_model.dart\';' not in content:
            content = content.replace(
                "import '../controllers/chat_controller.dart';",
                "import '../controllers/chat_controller.dart';\nimport '../../models/chat_model.dart';"
            )
    elif path == 'lib/features/chat/presentation/widgets/chat_input_bar.dart':
        # Fix Map getter 'text' -> ['text']
        content = original.replace(
            "controller.replyToMessage.value!.text ?? 'Replying to sticker'",
            "controller.replyToMessage.value!['text'] ?? 'Replying to sticker'"
        )
    elif path == 'lib/features/chat/presentation/widgets/message_bubble.dart':
        # Fix: remove pin named parameter since it's not in controller
        content = original.replace(
            'controller.pinMessage(message.id, pin: !message.isPinned)',
            'controller.pinMessage(message.id)'
        )
    else:
        content = original
    
    if content != original:
        with open(full, 'w', encoding='utf-8') as fh:
            fh.write(content)
        print(f"FIXED: {path}")
    else:
        print(f"NO CHANGES: {path}")

for p in [
    'lib/features/chat/presentation/views/chat_screen.dart',
    'lib/features/chat/presentation/views/room_chat_screen.dart',
    'lib/features/chat/presentation/widgets/chat_input_bar.dart',
    'lib/features/chat/presentation/widgets/message_bubble.dart',
]:
    fix_file(p)

print("\nDone fixing chat issues.")