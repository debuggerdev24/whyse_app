import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asset name for [flutter_dotenv], derived from `--flavor` / [appFlavor].
///
/// Flavors:
/// - **local** — day-to-day development (`.env`).
/// - **staging** — final “ship candidate” build: same behavior and env layout as
///   production so you can validate the real stack; uses `.env.staging` (usually
///   identical to production, or point `BASE_URL` at a mirror/pre-prod host only
///   if you have one). Gradle cannot use a flavor id starting with `test`, so
///   this role is named `staging`, not `testing`.
/// - **production** — live app (`.env.production`).
///
/// CLI: `flutter run --flavor local|staging|production` (see pubspec `default-flavor`).
///
/// If [appFlavor] is null (for example an iOS Release archive from Xcode
/// without going through Flutter), release AOT builds default to `production`.
String flavorEnvFileName() {
  String? flavor = appFlavor;
  if (flavor == null && kReleaseMode) {
    flavor = 'production';
  }
  flavor ??= 'local';
  return switch (flavor) {
    'staging' => '.env.staging',
    'production' => '.env.production',
    _ => '.env',
  };
}
