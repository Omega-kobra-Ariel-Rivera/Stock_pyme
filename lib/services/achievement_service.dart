import '../data/achievements_data.dart';
import '../models/achievement.dart';
import 'storage_service.dart';

class AchievementService {
  AchievementService._();

  static int unlockedCount() {
    final s = StorageService.instance;
    return achievements.where((a) => a.isUnlocked(s)).length;
  }

  /// Devuelve los logros recién desbloqueados y los marca como vistos.
  static List<Achievement> checkNew() {
    final s = StorageService.instance;
    final seen = s.seenAchievements;
    final newly = achievements.where((a) => !seen.contains(a.id) && a.isUnlocked(s)).toList();
    if (newly.isNotEmpty) {
      s.markAchievementsSeen(newly.map((a) => a.id));
    }
    return newly;
  }
}
