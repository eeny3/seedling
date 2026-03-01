import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seedling/services/notification_service.dart';
import 'package:seedling/data/database_service.dart';
import 'package:uuid/uuid.dart';
import 'ticker.dart';
import '../../../models/session.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final NotificationService _notificationService;
  final DatabaseService _databaseService;
  static const int _defaultDuration = 25 * 60; 

  StreamSubscription<int>? _tickerSubscription;
  DateTime? _endTime;
  int _remainingWhenPaused = 0;
  DateTime? _startTime; 

  TimerBloc({
      required Ticker ticker, 
      required NotificationService notificationService,
      required DatabaseService databaseService,
  }) : _ticker = ticker,
       _notificationService = notificationService,
       _databaseService = databaseService,
       super(const TimerState(duration: _defaultDuration, status: TimerStatus.initial)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);
    on<TimerCompleted>(_onCompleted);
    on<TimerFailed>(_onFailed);
    
    _checkRestoredSession();
  }

  void _checkRestoredSession() {
      final restoredEndTime = _databaseService.getSessionEndTime();
      if (restoredEndTime != null) {
          add(TimerFailed());
          _databaseService.clearSession();
      }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _startTime = DateTime.now();
    _endTime = DateTime.now().add(Duration(seconds: event.duration));
    _databaseService.saveSessionEndTime(_endTime!);
    
    emit(TimerState(duration: event.duration, status: TimerStatus.running));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((_) {
          if (_endTime != null) {
            final remaining = _endTime!.difference(DateTime.now()).inSeconds;
            add(_TimerTicked(duration: remaining));
          }
        });
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state.status == TimerStatus.running) {
      _tickerSubscription?.pause();
      _remainingWhenPaused = state.duration;
      _endTime = null;
      _databaseService.clearSession(); 
      emit(TimerState(duration: state.duration, status: TimerStatus.paused));
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state.status == TimerStatus.paused) {
      _endTime = DateTime.now().add(Duration(seconds: _remainingWhenPaused));
      _databaseService.saveSessionEndTime(_endTime!);
      _tickerSubscription?.resume();
      emit(TimerState(duration: _remainingWhenPaused, status: TimerStatus.running));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    _endTime = null;
    _databaseService.clearSession();
    emit(const TimerState(duration: _defaultDuration, status: TimerStatus.initial));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    if (event.duration > 0) {
      emit(TimerState(duration: event.duration, status: TimerStatus.running));
    } else {
      add(TimerCompleted());
    }
  }
  
  void _onCompleted(TimerCompleted event, Emitter<TimerState> emit) async {
     _tickerSubscription?.cancel();
     _endTime = null;
     _databaseService.clearSession();
     
     // REWARDS & HISTORY
     _databaseService.addNectar(100); 
     
     final session = Session(
       id: const Uuid().v4(),
       startTime: _startTime ?? DateTime.now(),
       durationMinutes: 25, 
       isCompleted: true,
       nectarEarned: 100,
     );
     await _databaseService.saveSession(session);
     
     // CHECK ACHIEVEMENTS
     await _checkAchievements(session);
     
     emit(const TimerState(duration: 0, status: TimerStatus.success));
     _notificationService.showNotification(
       title: 'Sunlight Cycle Complete!',
       body: 'Your fruit has thrived. Collect your Nectar.',
     );
  }
  
  Future<void> _checkAchievements(Session session) async {
      // 1. First Step
      if (_databaseService.totalSessionsCompleted >= 1) {
          await _unlockIfNew('first_step');
      }
      
      // 2. Early Bird (< 8 AM)
      if (session.startTime.hour < 8) {
          await _unlockIfNew('early_bird');
      }
      
      // 3. Night Owl (> 10 PM)
      if (session.startTime.hour >= 22) {
          await _unlockIfNew('night_owl');
      }
      
      // 4. Dedicated (10 Sessions)
      if (_databaseService.totalSessionsCompleted >= 10) {
          await _unlockIfNew('dedicated');
      }
      
      // 5. Focus Master (24 hours)
      if (_databaseService.totalFocusMinutes >= 1440) {
          await _unlockIfNew('master');
      }
  }
  
  Future<void> _unlockIfNew(String id) async {
      final unlocked = _databaseService.unlockedAchievements;
      if (!unlocked.contains(id)) {
          await _databaseService.unlockAchievement(id);
          // Optional: Send a second notification specifically for the achievement
          _notificationService.showNotification(
              title: 'Achievement Unlocked!',
              body: 'Check your Trophy Room in History.',
          );
      }
  }
  
  void _onFailed(TimerFailed event, Emitter<TimerState> emit) {
     _tickerSubscription?.cancel();
     _endTime = null;
     _databaseService.clearSession();
     
     if (_startTime != null) { 
         final session = Session(
           id: const Uuid().v4(),
           startTime: _startTime!,
           durationMinutes: 0, 
           isCompleted: false,
           nectarEarned: 0,
         );
         _databaseService.saveSession(session);
     }

     emit(TimerState(duration: state.duration, status: TimerStatus.failure));
  }
}
