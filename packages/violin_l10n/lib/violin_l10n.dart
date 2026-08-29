import 'package:flutter/material.dart';

import 'src/gen/app_localizations.g.dart';

extension ViolinL10nExtension on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ??
      (throw Exception('AppLocalizations not found in context'));
}

abstract final class ViolinL10n {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizations.delegate;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      AppLocalizations.localizationsDelegates;

  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;
}
