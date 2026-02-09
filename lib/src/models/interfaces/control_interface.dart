import '../../controllers/locale_controller.dart';
import '../../controllers/theme_controller.dart';

/// Interface that holds references to all initialized controllers.
///
/// This is created in the app and injected into views.
class ControlInterface {
  const ControlInterface({
    required this.theme,
    required this.locale,
  });

  final ThemeController theme;
  final LocaleController locale;
}
