import sys
f = open('lib/features/chat/presentation/controllers/chat_controller.dart', 'rb')
data = f.read()
f.close()

# Find the problematic string
idx1 = data.find(b'/chat/')
if idx1 != -1:
    print("Found /chat/ at index", idx1)
    print("Bytes:", data[idx1:idx1+25])
    print("Hex:", data[idx1:idx1+25].hex())

idx2 = data.find(b'Failed to load')
if idx2 != -1:
    print("Found 'Failed to load' at index", idx2)
    print("Bytes:", data[idx2:idx2+40])
    print("Hex:", data[idx2:idx2+40].hex())
