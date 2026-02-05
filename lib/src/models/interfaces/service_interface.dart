import '../../services/kb_service.dart';
import '../../services/preferences_service.dart';

/// Interface that holds references to all initialized services.
///
/// This is created in the app and built from the ClientInterface.
class ServiceInterface {
  const ServiceInterface({
    required this.preferences,
    required this.kb,
  });

  final PreferencesService preferences;
  final KbService kb;
}
