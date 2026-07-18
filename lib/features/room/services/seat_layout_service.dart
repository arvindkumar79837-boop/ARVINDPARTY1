// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/services/seat_layout_service.dart
// ARVIND PARTY - SEAT LAYOUT SERVICE (Grid Calculation, Seat Assignment)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:get/get.dart';
import '../models/room_models.dart';

enum LayoutMode {
  twoColumn,
  threeColumn,
  fourColumn,
  auto,
}

class SeatPosition {
  final int row;
  final int col;
  final int seatIndex;

  const SeatPosition({
    required this.row,
    required this.col,
    required this.seatIndex,
  });
}

class SeatLayoutConfig {
  final int columns;
  final int rows;
  final int totalSlots;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const SeatLayoutConfig({
    required this.columns,
    required this.rows,
    required this.totalSlots,
    required this.childAspectRatio,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 14,
  });
}

class SeatLayoutService extends GetxService {
  static SeatLayoutService get to => Get.find<SeatLayoutService>();

  // ═══════ LAYOUT CALCULATION ════════════════════════════════════════════

  SeatLayoutConfig calculateLayout(int seatCount, {LayoutMode mode = LayoutMode.auto}) {
    switch (mode) {
      case LayoutMode.twoColumn:
        return _buildConfig(2, seatCount);
      case LayoutMode.threeColumn:
        return _buildConfig(3, seatCount);
      case LayoutMode.fourColumn:
        return _buildConfig(4, seatCount);
      case LayoutMode.auto:
        return _autoLayout(seatCount);
    }
  }

  SeatLayoutConfig _autoLayout(int seatCount) {
    if (seatCount <= 4) {
      return _buildConfig(2, seatCount);
    } else if (seatCount <= 9) {
      return _buildConfig(3, seatCount);
    } else {
      return _buildConfig(4, seatCount);
    }
  }

  SeatLayoutConfig _buildConfig(int columns, int seatCount) {
    final rows = (seatCount / columns).ceil();
    return SeatLayoutConfig(
      columns: columns,
      rows: rows,
      totalSlots: seatCount,
      childAspectRatio: columns <= 2 ? 0.85 : 0.78,
      crossAxisSpacing: columns <= 2 ? 14 : 10,
      mainAxisSpacing: columns <= 2 ? 16 : 12,
    );
  }

  // ═══════ GRID POSITION MAPPING ═════════════════════════════════════════

  List<SeatPosition> generateGridPositions(int seatCount, {LayoutMode mode = LayoutMode.auto}) {
    final config = calculateLayout(seatCount, mode: mode);
    final positions = <SeatPosition>[];

    for (var i = 0; i < seatCount; i++) {
      final row = i ~/ config.columns;
      final col = i % config.columns;
      positions.add(SeatPosition(row: row, col: col, seatIndex: i));
    }

    return positions;
  }

  int getSeatIndex(int row, int col, int columns) {
    return row * columns + col;
  }

  // ═══════ SEAT ASSIGNMENT ═══════════════════════════════════════════════

  /// Determines optimal seat assignment order.
  /// Host gets seat 0, co-hosts get the first available seats,
  /// then speakers, then moderators, then listeners.
  List<String> assignSeats(List<RoomMemberModel> members, int totalSeats) {
    final sorted = List<RoomMemberModel>.from(members);
    sorted.sort((a, b) => _rolePriority(a.role).compareTo(_rolePriority(b.role)));

    final assignments = List<String>.filled(totalSeats, '');
    var nextSeat = 0;

    for (final member in sorted) {
      if (nextSeat >= totalSeats) break;
      assignments[nextSeat] = member.userId;
      nextSeat++;
    }

    return assignments;
  }

  int _rolePriority(MemberRole role) {
    switch (role) {
      case MemberRole.host:
        return 0;
      case MemberRole.coHost:
        return 1;
      case MemberRole.speaker:
        return 2;
      case MemberRole.moderator:
        return 3;
      case MemberRole.admin:
        return 4;
      case MemberRole.member:
        return 5;
      case MemberRole.listener:
        return 6;
      case MemberRole.muted:
        return 7;
      case MemberRole.visitor:
        return 8;
      case MemberRole.owner:
        return 0;
    }
  }

  // ═══════ SEAT STATE HELPERS ════════════════════════════════════════════

  /// Returns the list of seat indices currently occupied by the given members.
  List<int> getOccupiedSeats(List<SeatData> seats) {
    return seats
        .where((s) => s.isOccupied)
        .map((s) => s.seatIndex)
        .toList();
  }

  /// Returns the list of empty seat indices.
  List<int> getEmptySeats(List<SeatData> seats) {
    return seats
        .where((s) => !s.isOccupied && !s.isLocked)
        .map((s) => s.seatIndex)
        .toList();
  }

  /// Returns the first available empty seat index, or -1 if none available.
  int findNextAvailableSeat(List<SeatData> seats) {
    for (var i = 0; i < seats.length; i++) {
      if (!seats[i].isOccupied && !seats[i].isLocked) {
        return i;
      }
    }
    return -1;
  }

  /// Finds the seat index for a specific user.
  int findUserSeat(List<SeatData> seats, String userId) {
    for (var i = 0; i < seats.length; i++) {
      if (seats[i].userId == userId) {
        return i;
      }
    }
    return -1;
  }

  /// Returns the number of currently occupied seats.
  int countOccupied(List<SeatData> seats) {
    return seats.where((s) => s.isOccupied).length;
  }

  /// Returns the number of available seats.
  int countAvailable(List<SeatData> seats) {
    return seats.where((s) => !s.isOccupied && !s.isLocked).length;
  }

  // ═══════ SEAT SIZE OPTIMIZATION ════════════════════════════════════════

  /// Calculates the recommended seat tile size based on total seat count
  /// and screen width to ensure all seats fit without scrolling when possible.
  double calculateSeatTileSize(int seatCount, double screenWidth) {
    final config = calculateLayout(seatCount);
    final availableWidth = screenWidth - (config.columns + 1) * config.crossAxisSpacing;
    return availableWidth / config.columns;
  }

  /// Returns true if the grid requires scrolling for the given viewport height.
  bool requiresScrolling(int seatCount, double viewportHeight, double screenWidth) {
    final config = calculateLayout(seatCount);
    final tileSize = calculateSeatTileSize(seatCount, screenWidth);
    final gridHeight = config.rows * (tileSize / config.childAspectRatio) +
        (config.rows - 1) * config.mainAxisSpacing;
    return gridHeight > viewportHeight;
  }

  // ═══════ UTILITY ═══════════════════════════════════════════════════════

  int nextAvailableIndex(List<SeatData> seats) {
    final empty = getEmptySeats(seats);
    return empty.isNotEmpty ? empty.first : -1;
  }

  bool canUserTakeSeat(List<SeatData> seats, String userId, int seatIndex) {
    if (seatIndex < 0 || seatIndex >= seats.length) return false;
    final seat = seats[seatIndex];
    return !seat.isOccupied && !seat.isLocked;
  }

  List<SeatData> sortByHostPriority(List<SeatData> seats) {
    final sorted = List<SeatData>.from(seats);
    sorted.sort((a, b) {
      if (a.isHost && !b.isHost) return -1;
      if (!a.isHost && b.isHost) return 1;
      if (a.isOccupied && !b.isOccupied) return -1;
      if (!a.isOccupied && b.isOccupied) return 1;
      return a.seatIndex.compareTo(b.seatIndex);
    });
    return sorted;
  }

  /// Creates a fresh list of empty seats for a given count.
  List<SeatData> createEmptySeats(int count) {
    return List.generate(
      count,
      (i) => SeatData(seatIndex: i),
    );
  }

  /// Merges server seat data with local empty seat template to ensure
  /// all seat positions exist even if server only returns occupied ones.
  List<SeatData> mergeSeats(List<SeatData> serverSeats, int totalCount) {
    final merged = createEmptySeats(totalCount);
    for (final serverSeat in serverSeats) {
      if (serverSeat.seatIndex >= 0 && serverSeat.seatIndex < totalCount) {
        merged[serverSeat.seatIndex] = serverSeat;
      }
    }
    return merged;
  }
}
