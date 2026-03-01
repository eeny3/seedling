import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/database_service.dart';
import '../../data/achievement_registry.dart';
import '../../models/session.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = GetIt.I<DatabaseService>();
    final history = db.getHistory(); 
    final totalMinutes = db.totalFocusMinutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Log')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Card
              Card(
                color: Colors.green[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text("Total Focus Time", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        "${(totalMinutes / 60).toStringAsFixed(1)} Hours",
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${history.where((s) => s.isCompleted).length} Completed Cycles",
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              // TROPHY ROOM (New)
              const Text("Trophy Room", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              ValueListenableBuilder(
                valueListenable: db.userBox.listenable(keys: ['unlocked_achievements']),
                builder: (context, box, _) {
                  final unlocked = db.unlockedAchievements;
                  
                  return SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AchievementRegistry.all.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final achievement = AchievementRegistry.all[index];
                        final isUnlocked = unlocked.contains(achievement.id);
                        
                        return Tooltip(
                          message: "${achievement.title}\n${achievement.description}",
                          triggerMode: TooltipTriggerMode.tap,
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUnlocked ? achievement.color.withOpacity(0.1) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUnlocked ? achievement.color : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  achievement.icon, 
                                  color: isUnlocked ? achievement.color : Colors.grey,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isUnlocked ? achievement.title : "Locked",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? achievement.color : Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text("Weekly Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Chart
              SizedBox(
                height: 200,
                child: _WeeklyChart(history: history),
              ),

              const SizedBox(height: 24),
              const Text("Recent Sessions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length > 10 ? 10 : history.length, 
                itemBuilder: (context, index) {
                  final session = history[index];
                  return ListTile(
                    leading: Icon(
                      session.isCompleted ? Icons.check_circle : Icons.cancel,
                      color: session.isCompleted ? Colors.green : Colors.red,
                    ),
                    title: Text(DateFormat('MMM d, yyyy - h:mm a').format(session.startTime)),
                    subtitle: Text(session.isCompleted 
                        ? "${session.durationMinutes} min • ${session.nectarEarned} Nectar"
                        : "Interrupted"
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Session> history;
  const _WeeklyChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<double> dailyMinutes = List.filled(7, 0.0);
    
    for (var session in history) {
      if (!session.isCompleted) continue;
      
      final diff = now.difference(session.startTime).inDays;
      if (diff < 7) {
        final index = 6 - diff;
        if (index >= 0 && index < 7) {
            dailyMinutes[index] += session.durationMinutes.toDouble();
        }
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (dailyMinutes.reduce((curr, next) => curr > next ? curr : next) + 30).clamp(60.0, 500.0), // Ensure meaningful Y-axis
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('E').format(date)[0], 
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: dailyMinutes[index],
                color: dailyMinutes[index] > 0 ? Colors.green : Colors.grey[200],
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }
}
