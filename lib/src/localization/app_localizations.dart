import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'khs_flutter_example'**
  String get appTitle;

  /// Title for the home page
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Greeting message displayed on the home page
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get homeGreeting;

  /// Title for the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Heading for the theme settings section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeHeading;

  /// Label for system theme option
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get themeSystem;

  /// Label for light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// Label for dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// Label for home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Label for settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Heading for the language settings section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageHeading;

  /// Label for system language option
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get languageSystem;

  /// Label for English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Label for Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// Label for LLM chat navigation item
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get navLlmChat;

  /// Title for the LLM chat page
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get llmChatTitle;

  /// Title for load model dialog
  ///
  /// In en, this message translates to:
  /// **'Load Model'**
  String get llmLoadModelTitle;

  /// Description text in load model dialog
  ///
  /// In en, this message translates to:
  /// **'Enter the path to a GGUF model file on your device.'**
  String get llmLoadModelDescription;

  /// Label for model path input field
  ///
  /// In en, this message translates to:
  /// **'Model Path'**
  String get llmModelPathLabel;

  /// Label for load model button
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get llmLoadButton;

  /// Tooltip for stop generation button
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get llmStopGeneration;

  /// Menu item to clear chat messages
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get llmClearChat;

  /// Menu item to unload the model
  ///
  /// In en, this message translates to:
  /// **'Unload Model'**
  String get llmUnloadModel;

  /// Placeholder text when chat is empty but model is loaded
  ///
  /// In en, this message translates to:
  /// **'Start chatting!'**
  String get llmStartChatting;

  /// Placeholder text when no model is loaded
  ///
  /// In en, this message translates to:
  /// **'Load a model to start chatting'**
  String get llmLoadModelFirst;

  /// Hint text for chat input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get llmInputHint;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to open model browser
  ///
  /// In en, this message translates to:
  /// **'Browse Models'**
  String get llmBrowseModels;

  /// Title for model browser dialog
  ///
  /// In en, this message translates to:
  /// **'Available Models'**
  String get llmModelBrowserTitle;

  /// Button to download a model
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get llmDownloadModel;

  /// Button to use/load a downloaded model
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get llmUseModel;

  /// Button to delete a downloaded model
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get llmDeleteModel;

  /// Status text while downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get llmDownloading;

  /// Status text when download finishes
  ///
  /// In en, this message translates to:
  /// **'Download complete'**
  String get llmDownloadComplete;

  /// Status text when download fails
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get llmDownloadFailed;

  /// Option to pick a model file from device storage
  ///
  /// In en, this message translates to:
  /// **'Pick from device'**
  String get llmPickFromDevice;

  /// Subtitle for pick from device option
  ///
  /// In en, this message translates to:
  /// **'Select a .gguf model file from your device'**
  String get llmPickFromDeviceSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
