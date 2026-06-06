import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../modules/auth/views/api_service.dart';

class SocketService extends GetxService {
  late io.Socket socket;
  final ApiService _apiService = Get.find<ApiService>();

  Future<SocketService> init() async {
    // Extract the base URL (without /api/) for Socket.IO connection
    String socketUrl = _apiService.baseUrl.replaceAll('api/', '');

    socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());

    socket.onConnect((_) {
      print('✅ Connected to Socket.IO Server');
    });

    socket.onDisconnect((_) {
      print('❌ Disconnected from Socket.IO Server');
    });

    socket.connect();

    return this;
  }
}
