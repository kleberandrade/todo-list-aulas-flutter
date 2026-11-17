import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'data/platform_native.dart'
    if (dart.library.js_interop) 'data/platform_web.dart';
import 'state/task_controller.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = TaskController(createTaskStore());
  runApp(TaskApp(controller: controller));
  unawaited(controller.load());
}

class TaskApp extends StatelessWidget {
  final TaskController controller;
  const TaskApp({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Lista • Um passo de cada vez',
    debugShowCheckedModeBanner: false,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF285D4B),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F7F2),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.1,
          color: Color(0xFF1D342B),
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 15, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.all(16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
    home: HomePage(controller: controller),
  );
}
