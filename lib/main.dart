import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:logging/logging.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:calezy/core/data/data_source/user_data_source.dart';
import 'package:calezy/core/data/repository/config_repository.dart';
import 'package:calezy/core/domain/entity/app_theme_entity.dart';
import 'package:calezy/core/presentation/main_screen.dart';
import 'package:calezy/core/presentation/widgets/image_full_screen.dart';
import 'package:calezy/core/styles/color_schemes.dart';
import 'package:calezy/core/styles/fonts.dart';
import 'package:calezy/core/utils/env.dart';
import 'package:calezy/core/utils/locator.dart';
import 'package:calezy/core/utils/logger_config.dart';
import 'package:calezy/core/utils/navigation_options.dart';
import 'package:calezy/core/utils/theme_mode_provider.dart';
import 'package:calezy/features/activity_detail/activity_detail_screen.dart';
import 'package:calezy/features/add_meal/presentation/add_meal_screen.dart';
import 'package:calezy/features/add_activity/presentation/add_activity_screen.dart';
import 'package:calezy/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:calezy/features/onboarding/onboarding_screen.dart';
import 'package:calezy/features/scanner/scanner_screen.dart';
import 'package:calezy/features/meal_detail/meal_detail_screen.dart';
import 'package:calezy/features/settings/settings_screen.dart';
import 'package:calezy/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerConfig.intiLogger();
  await initLocator();
  final isUserInitialized = await locator<UserDataSource>().hasUserData();
  final configRepo = locator<ConfigRepository>();
  final hasAcceptedAnonymousData =
      await configRepo.getConfigHasAcceptedAnonymousData();
  final savedAppTheme = await configRepo.getConfigAppTheme();
  final log = Logger('main');

  // If the user has accepted anonymous data collection, run the app with
  // sentry enabled, else run without it
  if (kReleaseMode && hasAcceptedAnonymousData) {
    log.info('Starting App with Sentry enabled ...');
    _runAppWithSentryReporting(isUserInitialized, savedAppTheme);
  } else {
    log.info('Starting App ...');
    runAppWithChangeNotifiers(isUserInitialized, savedAppTheme);
  }
}

void _runAppWithSentryReporting(
    bool isUserInitialized, AppThemeEntity savedAppTheme) async {
  await SentryFlutter.init((options) {
    options.dsn = Env.sentryDns;
    options.tracesSampleRate = 1.0;
  },
      appRunner: () =>
          runAppWithChangeNotifiers(isUserInitialized, savedAppTheme));
}

void runAppWithChangeNotifiers(
        bool userInitialized, AppThemeEntity savedAppTheme) =>
    runApp(ChangeNotifierProvider(
        create: (_) => ThemeModeProvider(appTheme: savedAppTheme),
        child: CalezyApp(userInitialized: userInitialized)));

class CalezyApp extends StatelessWidget {
  final bool userInitialized;

  const CalezyApp({super.key, required this.userInitialized});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (dynamicLightColorScheme, dynamicDarkColorScheme) {
        final themeModeProvider = Provider.of<ThemeModeProvider>(context);
        final isDynamicTheme = themeModeProvider.appTheme == AppThemeEntity.dynamic;
        
        return MaterialApp(
          onGenerateTitle: (context) => S.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: isDynamicTheme && dynamicLightColorScheme != null 
                  ? dynamicLightColorScheme 
                  : lightColorScheme,
              textTheme: appTextTheme),
          darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: isDynamicTheme && dynamicDarkColorScheme != null 
                  ? dynamicDarkColorScheme 
                  : darkColorScheme,
              textTheme: appTextTheme),
          themeMode: themeModeProvider.themeMode,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          initialRoute: userInitialized
              ? NavigationOptions.mainRoute
              : NavigationOptions.onboardingRoute,
          routes: {
            NavigationOptions.mainRoute: (context) => const MainScreen(),
            NavigationOptions.onboardingRoute: (context) =>
                const OnboardingScreen(),
            NavigationOptions.settingsRoute: (context) => const SettingsScreen(),
            NavigationOptions.addMealRoute: (context) => const AddMealScreen(),
            NavigationOptions.scannerRoute: (context) => const ScannerScreen(),
            NavigationOptions.mealDetailRoute: (context) =>
                const MealDetailScreen(),
            NavigationOptions.editMealRoute: (context) => const EditMealScreen(),
            NavigationOptions.addActivityRoute: (context) =>
                const AddActivityScreen(),
            NavigationOptions.activityDetailRoute: (context) =>
                const ActivityDetailScreen(),
            NavigationOptions.imageFullScreenRoute: (context) =>
                const ImageFullScreen(),
          },
        );
      },
    );
  }
}
