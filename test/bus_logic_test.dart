import 'package:flutter_test/flutter_test.dart';
import 'package:bussync/core/utils/freshness_utils.dart';

void main() {
  group('BusSync Domain Logic Tests', () {
    test('Calculate available seats correctly (Capacity - Boarded)', () {
      expect(FreshnessUtils.calculateAvailableSeats(40, 12), equals(28));
      expect(FreshnessUtils.calculateAvailableSeats(35, 30), equals(5));
      expect(FreshnessUtils.calculateAvailableSeats(45, 45), equals(0));
    });

    test('Validate capacity limits (Never negative available seats)', () {
      expect(FreshnessUtils.calculateAvailableSeats(40, 50), equals(0)); // Over capacity caps at 0
      expect(FreshnessUtils.calculateAvailableSeats(40, -5), equals(40)); // Negative boarded defaults to cap
    });

    test('Calculate data freshness state correctly based on timestamps', () {
      final now = DateTime.now();

      final twoMinsAgo = now.subtract(const Duration(minutes: 2));
      expect(FreshnessUtils.getFreshnessState(twoMinsAgo), equals(FreshnessState.live));

      final tenMinsAgo = now.subtract(const Duration(minutes: 10));
      expect(FreshnessUtils.getFreshnessState(tenMinsAgo), equals(FreshnessState.recentlyUpdated));

      final twentyMinsAgo = now.subtract(const Duration(minutes: 20));
      expect(FreshnessUtils.getFreshnessState(twentyMinsAgo), equals(FreshnessState.stale));
    });

    test('Calculate bus status correctly (AVAILABLE, ALMOST_FULL, FULL, STALE)', () {
      // Available > 5
      expect(
        FreshnessUtils.getBusStatus(12, FreshnessState.live),
        equals(BusStatus.available),
      );

      // Almost full (1 to 5)
      expect(
        FreshnessUtils.getBusStatus(5, FreshnessState.live),
        equals(BusStatus.almostFull),
      );
      expect(
        FreshnessUtils.getBusStatus(1, FreshnessState.recentlyUpdated),
        equals(BusStatus.almostFull),
      );

      // Full (0 available)
      expect(
        FreshnessUtils.getBusStatus(0, FreshnessState.live),
        equals(BusStatus.full),
      );

      // Stale (> 15 mins) overrides status to STALE
      expect(
        FreshnessUtils.getBusStatus(15, FreshnessState.stale),
        equals(BusStatus.stale),
      );
    });

    test('Sort buses by highest available seats first, then by most recently updated', () {
      final now = DateTime.now();

      final busA = {
        'id': 1,
        'seats': 5,
        'updated': now.subtract(const Duration(minutes: 2)),
      };
      final busB = {
        'id': 2,
        'seats': 12,
        'updated': now.subtract(const Duration(minutes: 4)),
      };
      final busC = {
        'id': 3,
        'seats': 12,
        'updated': now.subtract(const Duration(minutes: 1)), // Tied with Bus B on seats, but updated more recently
      };

      final list = [busA, busB, busC];

      FreshnessUtils.sortBuses<Map<String, dynamic>>(
        buses: list,
        getAvailableSeats: (b) => b['seats'] as int,
        getLastUpdated: (b) => b['updated'] as DateTime,
      );

      // Expected order: busC (12 seats, 1m ago), busB (12 seats, 4m ago), busA (5 seats, 2m ago)
      expect(list[0]['id'], equals(3));
      expect(list[1]['id'], equals(2));
      expect(list[2]['id'], equals(1));
    });
  });
}
