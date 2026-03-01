import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/timer/bloc/ticker.dart';
import 'features/orchard/bloc/fruit_bloc.dart';
import 'features/laboratory/bloc/lab_bloc.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'services/notification_service.dart';
import 'data/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjection();
  
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(SeedlingApp(startOnboarding: !hasSeenOnboarding));
}

class SeedlingApp extends StatelessWidget {
  final bool startOnboarding;
  
  const SeedlingApp({super.key, required this.startOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TimerBloc>(
          create: (context) => TimerBloc(
            ticker: const Ticker(),
            notificationService: GetIt.I<NotificationService>(),
            databaseService: GetIt.I<DatabaseService>(),
          ),
        ),
        BlocProvider<FruitBloc>(
          create: (context) => FruitBloc(
            databaseService: GetIt.I<DatabaseService>(),
          )..add(LoadFruitData()),
        ),
        BlocProvider<LabBloc>(
          create: (context) => LabBloc(
            databaseService: GetIt.I<DatabaseService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Seedling',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: startOnboarding ? const OnboardingPage() : const DashboardPage(),
      ),
    );
  }
}
