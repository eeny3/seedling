import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';
import 'dart:math' as math; 
import '../../timer/bloc/timer_bloc.dart';
import '../../orchard/bloc/fruit_bloc.dart';
import '../../shared/fruit_image.dart';
import '../../../data/database_service.dart';
import '../../../data/theme_registry.dart'; 
import 'sound_control.dart'; 

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state.status == TimerStatus.success) {
           context.read<FruitBloc>().add(const AddExperience(100));
        }
      },
      child: ValueListenableBuilder(
        valueListenable: GetIt.I<DatabaseService>().userBox.listenable(keys: ['active_theme']),
        builder: (context, box, _) {
          final themeId = box.get('active_theme', defaultValue: 'default');
          final theme = ThemeRegistry.getById(themeId);
          
          return Scaffold(
            backgroundColor: Colors.transparent, // Let parent background show through
            extendBodyBehindAppBar: true, 
            appBar: AppBar(
              backgroundColor: Colors.transparent, 
              elevation: 0,
              title: Text('Focus Greenhouse', style: TextStyle(color: theme.textColor)),
              iconTheme: IconThemeData(color: theme.textColor),
              actions: [
                const SoundControl(),
                ValueListenableBuilder(
                  valueListenable: GetIt.I<DatabaseService>().userBox.listenable(keys: ['nectar']),
                  builder: (context, box, _) {
                    final nectar = box.get('nectar', defaultValue: 0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.local_drink, color: Colors.amber), 
                          const SizedBox(width: 4),
                          Text(
                            '$nectar',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SafeArea( 
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               const Spacer(), 
                               FruitDisplay(textColor: theme.textColor), 
                               const SizedBox(height: 20),
                               TimerView(textColor: theme.textColor),
                               const Spacer(), 
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          );
        },
      ),
    );
  }
}

class FruitDisplay extends StatefulWidget {
  final Color textColor;
  const FruitDisplay({super.key, required this.textColor});

  @override
  State<FruitDisplay> createState() => _FruitDisplayState();
}

class _FruitDisplayState extends State<FruitDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: widget.textColor, 
      shadows: widget.textColor == Colors.white 
          ? [const Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black)]
          : null,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    );
    
    return BlocBuilder<FruitBloc, FruitState>(
      builder: (context, fruitState) {
        if (fruitState is! FruitLoaded) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final fruit = fruitState.activeFruit;

        return BlocBuilder<TimerBloc, TimerState>(
          builder: (context, timerState) {
            final isFocusing = timerState.status == TimerStatus.running;
            final isFailed = timerState.status == TimerStatus.failure;
            
            if (isFocusing) {
              if (!_controller.isAnimating) _controller.repeat(reverse: true);
            } else {
              _controller.stop();
              _controller.value = 0.5; 
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.textColor == Colors.white 
                        ? Colors.black45 
                        : Colors.grey[200], 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(timerState.status)),
                  ),
                  child: Text(
                    _getStatusText(timerState.status),
                    style: TextStyle(
                      color: _getStatusColor(timerState.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final value = _controller.value;
                    final scale = 0.95 + (0.2 * value);
                    final rotation = 0.05 * math.sin(value * math.pi);

                    return Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: isFailed 
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: FruitImage(type: fruit.type, level: fruit.level, size: 220),
                      )
                    : FruitImage(type: fruit.type, level: fruit.level, size: 220),
                ),
                 const SizedBox(height: 30),
                 Text(
                   "${fruit.type} (Lvl ${fruit.level})",
                   style: textStyle, 
                 ),
                 const SizedBox(height: 10),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 40.0),
                   child: Column(
                     children: [
                       LinearProgressIndicator(
                         value: fruit.progress,
                         backgroundColor: widget.textColor == Colors.white ? Colors.white24 : Colors.grey[300],
                         color: Colors.greenAccent,
                         minHeight: 10,
                         borderRadius: BorderRadius.circular(5),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         "${fruit.xp} / ${fruit.maxXpForCurrentLevel} XP",
                         style: textStyle.copyWith(fontSize: 14),
                       )
                     ],
                   ),
                 ),
              ],
            );
          },
        );
      },
    );
  }
  
  Color _getStatusColor(TimerStatus status) {
      switch(status) {
          case TimerStatus.running: return Colors.greenAccent;
          case TimerStatus.paused: return Colors.orangeAccent;
          case TimerStatus.failure: return Colors.grey;
          case TimerStatus.success: return Colors.amber;
          default: return Colors.blueGrey;
      }
  }

  String _getStatusText(TimerStatus status) {
      switch(status) {
          case TimerStatus.running: return "Growing...";
          case TimerStatus.paused: return "Paused";
          case TimerStatus.failure: return "Withered (Drought)";
          case TimerStatus.success: return "Harvest Ready!";
          default: return "Ready to Plant";
      }
  }
}

class TimerView extends StatelessWidget {
  final Color textColor;
  const TimerView({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    
    final displayStyle = TextStyle(
        fontSize: 64, 
        fontWeight: FontWeight.bold, 
        color: textColor,
        shadows: textColor == Colors.white 
            ? const [Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black26)]
            : null,
    );

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final duration = state.duration;
        final minutesStr = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
        final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');

        return Column(
          children: [
            Text(
              '$minutesStr:$secondsStr',
              style: displayStyle,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.status == TimerStatus.initial || state.status == TimerStatus.success || state.status == TimerStatus.failure)
                  FloatingActionButton(
                    onPressed: () => context.read<TimerBloc>().add(const TimerStarted(duration: 25 * 60)),
                    child: const Icon(Icons.play_arrow),
                  ),
                if (state.status == TimerStatus.running) ...[
                   FloatingActionButton(
                    onPressed: () => context.read<TimerBloc>().add(TimerPaused()),
                    child: const Icon(Icons.pause),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    backgroundColor: Colors.redAccent,
                    onPressed: () => context.read<TimerBloc>().add(TimerFailed()),
                    child: const Icon(Icons.stop),
                  ),
                ],
                if (state.status == TimerStatus.paused) ...[
                   FloatingActionButton(
                    onPressed: () => context.read<TimerBloc>().add(TimerResumed()),
                    child: const Icon(Icons.play_arrow),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    backgroundColor: Colors.redAccent,
                    onPressed: () => context.read<TimerBloc>().add(TimerReset()),
                    child: const Icon(Icons.stop),
                  ),
                ]
              ],
            )
          ],
        );
      },
    );
  }
}
