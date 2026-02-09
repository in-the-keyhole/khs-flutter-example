// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'khs_flutter_example';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get themeHeading => 'Tema';

  @override
  String get themeSystem => 'Tema del Sistema';

  @override
  String get themeLight => 'Tema Claro';

  @override
  String get themeDark => 'Tema Oscuro';

  @override
  String get navSettings => 'Configuración';

  @override
  String get languageHeading => 'Idioma';

  @override
  String get languageSystem => 'Idioma del Sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get navLlmChat => 'Chat IA';

  @override
  String get llmChatTitle => 'Chat IA';

  @override
  String get llmLoadModelTitle => 'Cargar Modelo';

  @override
  String get llmLoadModelDescription =>
      'Ingresa la ruta a un archivo de modelo GGUF en tu dispositivo.';

  @override
  String get llmModelPathLabel => 'Ruta del Modelo';

  @override
  String get llmLoadButton => 'Cargar';

  @override
  String get llmStopGeneration => 'Detener';

  @override
  String get llmClearChat => 'Limpiar Chat';

  @override
  String get llmUnloadModel => 'Descargar Modelo';

  @override
  String get llmStartChatting => '¡Comienza a chatear!';

  @override
  String get llmLoadModelFirst => 'Carga un modelo para comenzar a chatear';

  @override
  String get llmInputHint => 'Escribe un mensaje...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get llmBrowseModels => 'Explorar Modelos';

  @override
  String get llmModelBrowserTitle => 'Modelos Disponibles';

  @override
  String get llmDownloadModel => 'Descargar';

  @override
  String get llmUseModel => 'Usar';

  @override
  String get llmDeleteModel => 'Eliminar';

  @override
  String get llmDownloading => 'Descargando...';

  @override
  String get llmDownloadComplete => 'Descarga completada';

  @override
  String get llmDownloadFailed => 'Descarga fallida';

  @override
  String get llmPickFromDevice => 'Elegir del dispositivo';

  @override
  String get llmPickFromDeviceSubtitle =>
      'Selecciona un archivo de modelo .gguf de tu dispositivo';

  @override
  String get modelHeading => 'Modelo';

  @override
  String get modelManage => 'Administrar Modelos';

  @override
  String get modelNone => 'Ninguno';

  @override
  String get contextSizeHeading => 'Tamaño de Contexto';

  @override
  String get systemPromptHeading => 'Prompt del Sistema';

  @override
  String get systemPromptHint => 'Ingresa el prompt del sistema...';

  @override
  String get conversationsTitle => 'Conversaciones';

  @override
  String get newChat => 'Nuevo Chat';

  @override
  String get renameConversation => 'Renombrar';

  @override
  String get deleteConversation => 'Eliminar';

  @override
  String get deleteConversationConfirm => '¿Eliminar esta conversación?';

  @override
  String get renameDialogTitle => 'Renombrar Conversación';

  @override
  String get save => 'Guardar';
}
