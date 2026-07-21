import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';

class LikeAnimationOverlay extends StatefulWidget {
  const LikeAnimationOverlay({super.key});

  @override
  State<LikeAnimationOverlay> createState() => _LikeAnimationOverlayState();
}

class _LikeAnimationOverlayState extends State<LikeAnimationOverlay> {
  final _hearts = <_HeartData>[];
  int _heartId = 0;

  @override
  void initState() {
    super.initState();
    ever(Get.find<SingingRoomController>().likeCount, (_) => _spawnHeart());
  }

  void _spawnHeart() {
    final id = _heartId++;
    final random = (id % 5);
    final xPos = 0.6 + (random * 0.08);
    setState(() {
      _hearts.add(_HeartData(id: id, x: xPos));
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _hearts.removeWhere((h) => h.id == id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _hearts.map((heart) {
          return Positioned(
            right: MediaQuery.of(context).size.width * (1 - heart.x),
            bottom: 100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: -200.0),
              duration: const Duration(milliseconds: 1500),
              builder: (_, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: (1 + value / 200).clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Icon(
                Icons.favorite,
                color: Colors.red.withOpacity(0.8),
                size: 28 + (_heartId % 3) * 6.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeartData {
  final int id;
  final double x;
  _HeartData({required this.id, required this.x});
}
