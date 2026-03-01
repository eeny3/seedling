import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 1)
class Session extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final int durationMinutes;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final int nectarEarned;

  Session({
    required this.id,
    required this.startTime,
    required this.durationMinutes,
    required this.isCompleted,
    required this.nectarEarned,
  });
}
