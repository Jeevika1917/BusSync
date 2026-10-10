import 'dart:math' as math;

enum FreshnessState {
  live,            // 0 - 5 mins
  recentlyUpdated, // 5 - 15 mins
  stale            // > 15 mins
}

enum BusStatus {
  available,  // > 5 seats available
  almostFull, // 1 - 5 seats available
  full,       // 0 seats available
  stale       // data > 15 mins old
}

class FreshnessUtils {
  static int calculateAvailableSeats(int capacity, int studentsBoarded) {
    if (studentsBoarded < 0) return capacity;
    if (studentsBoarded > capacity) return 0;
    return math.max(0, capacity - studentsBoarded);
  }

  static FreshnessState getFreshnessState(DateTime lastUpdated) {
    final diff = DateTime.now().difference(lastUpdated);
    final minutes = diff.inMinutes;

    if (minutes < 5) {
      return FreshnessState.live;
    } else if (minutes <= 15) {
      return FreshnessState.recentlyUpdated;
    } else {
      return FreshnessState.stale;
    }
  }

  static BusStatus getBusStatus(int availableSeats, FreshnessState freshness) {
    if (freshness == FreshnessState.stale) {
      return BusStatus.stale;
    }
    if (availableSeats == 0) {
      return BusStatus.full;
    } else if (availableSeats <= 5) {
      return BusStatus.almostFull;
    } else {
      return BusStatus.available;
    }
  }

  static String getFreshnessLabel(FreshnessState state) {
    switch (state) {
      case FreshnessState.live:
        return 'LIVE';
      case FreshnessState.recentlyUpdated:
        return 'RECENTLY UPDATED';
      case FreshnessState.stale:
        return 'STALE';
    }
  }

  static String formatTimeAgo(DateTime lastUpdated) {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  // Sort buses: 1. Highest available seats first, 2. Most recently updated when availability equal
  static void sortBuses<T>({
    required List<T> buses,
    required int Function(T) getAvailableSeats,
    required DateTime Function(T) getLastUpdated,
  }) {
    buses.sort((a, b) {
      final seatsA = getAvailableSeats(a);
      final seatsB = getAvailableSeats(b);

      if (seatsA != seatsB) {
        return seatsB.compareTo(seatsA); // Higher available seats first
      }

      final dateA = getLastUpdated(a);
      final dateB = getLastUpdated(b);
      return dateB.compareTo(dateA); // Most recent first
    });
  }
}
