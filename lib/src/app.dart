import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/llm_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/theme_controller.dart';
import 'localization/app_localizations.dart';
import 'models/interfaces/client_interface.dart';
import 'models/interfaces/control_interface.dart';
import 'models/interfaces/service_interface.dart';
import 'services/kb_service.dart';
import 'services/llm_service.dart';
import 'services/preferences_service.dart';
import 'router.dart';

/// The Widget that configures the application.
class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.clients});

  final ClientInterface clients;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ControlInterface _controls;
  late LlmController _llmController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Build services from client interface
    final preferencesService = PreferencesService(widget.clients.preferences);
    await preferencesService.init();

    final kbService = KbService(widget.clients.database);
    await kbService.init();

    final llmService = LlmService(widget.clients.fllama);

    final services = ServiceInterface(
      preferences: preferencesService,
      kb: kbService,
    );

    // Build controllers from service interface
    final themeController = ThemeController(services.preferences);
    final localeController = LocaleController(services.preferences);
    final navigationController = NavigationController();
    _llmController = LlmController(llmService, kbService: services.kb);

    // Wrap controllers in control interface
    _controls = ControlInterface(
      theme: themeController,
      locale: localeController,
      navigation: navigationController,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Glue the controllers to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to all controllers for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: Listenable.merge([
        _controls.theme,
        _controls.locale,
        _controls.navigation,
        _llmController,
      ]),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // for supported locales.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // The supported locales are used to display the correct translations
          // depending on the user's locale.
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
          ],

          // Override the locale if the user has set a preference.
          // Null means use system locale.
          locale: _controls.locale.locale,

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // ThemeController to display the correct theme.
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: _controls.theme.mode,

          // Display the view router
          home: AppRouter(
            controls: _controls,
            llmController: _llmController,
            filesystemClient: widget.clients.filesystem,
            modelDownloadClient: widget.clients.modelDownload,
          ),
        );
      },
    );
  }
}
