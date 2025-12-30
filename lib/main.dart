import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_bari/core/services/notification_service.dart';
import 'package:amar_bari/features/settings/data/settings_provider.dart';
import 'package:amar_bari/l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notifications
  final container = ProviderContainer();
  await container.read(notificationServiceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AmarBariApp(),
    ),
  );
}

class AmarBariApp extends ConsumerWidget { // Renamed MyApp to AmarBariApp
  const AmarBariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Amar Bari',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent, // Make scaffold transparent
        appBarTheme: const AppBarTheme(
           backgroundColor: Colors.transparent, // Optional: make appbar transparent too? Maybe stick to default or specific color. 
           // If we make appbar transparent, it might clash with scrolling content. 
           // Let's keep appbar default or surface color, but maybe slightly transparent?
           // For safety, let's just make scaffold transparent.
           // Actually, let's keep AppBar default style which is usually surface color in M3.
        ),
      ),
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            // Global Background Layer
            Positioned.fill(
              child: Container(
                color: Colors.grey[50], // Solid base color (Light Grey)
              ),
            ),
            // Global Logo Layer
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.15, // Subtle watermark
                  child: Image.asset(
                    'assets/images/app_logo_final.jpg',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
            // The Page Content (Scaffolds are now transparent)
            if (child != null) child,
          ],
        );
      },
    );
  }
}
