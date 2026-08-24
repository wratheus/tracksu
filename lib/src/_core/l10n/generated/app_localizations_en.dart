// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tracksu';

  @override
  String get guestModeTitle => 'Guest mode';

  @override
  String get guestSignedOutDescription =>
      'Browse public osu! data as a guest. Signing in will add account features.';

  @override
  String get guestSignedInDescription =>
      'You are signed in. Public browsing stays available without an account.';

  @override
  String get signInWithOsu => 'Sign in with osu!';

  @override
  String get signInWithAnotherAccount => 'Sign in with another account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signingOut => 'Signing out...';

  @override
  String get signOutFailed => 'Unable to sign out. Try again.';

  @override
  String get systemLanguage => 'System language';

  @override
  String get englishLanguage => 'English';

  @override
  String get russianLanguage => 'Russian';

  @override
  String get loginToOsu => 'Login to osu!';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get openingOsu => 'Opening osu!...';

  @override
  String get continueWithOsu => 'Continue with osu!';

  @override
  String get authorizationExpired =>
      'This authorization request has expired. Try again.';

  @override
  String get authorizationResponseUnavailable =>
      'Unable to receive the authorization response.';

  @override
  String get authorizationResponseMismatch =>
      'The authorization response did not match this login attempt.';

  @override
  String get authorizationCancelled =>
      'Authorization was cancelled or refused.';

  @override
  String get authorizationResponseInvalid =>
      'The authorization response is invalid.';

  @override
  String get authorizationPreparationFailed =>
      'Unable to prepare osu! authorization.';

  @override
  String get authorizationLaunchFailed => 'Unable to open osu! authorization.';

  @override
  String get authorizationCompletionFailed => 'Unable to finish authorization.';

  @override
  String get authorizationIncomplete =>
      'Authorization was not completed. Try again.';
}
