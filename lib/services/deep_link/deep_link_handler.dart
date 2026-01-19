import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/routes/app_router.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;
  bool _isProcessingLink = false;

  void init({
    required BuildContext context,
    required AuthProvider authProvider,
  }) {
    Logger.info("Deep Linking initialize");

    _sub = _appLinks.stringLinkStream.listen(
      (String? link) {
        if (link != null && !_isProcessingLink) {
          final uri = Uri.parse(link);
          Logger.info("Incoming Link: $link");
          _handleDeepLink(uri, context: context, authProvider: authProvider);
        }
      },
      onError: (err) {
        Logger.error("Error in incoming app link: $err");
      },
    );

    Logger.info("Deep Linking Success");
  }

  void dispose() {
    _sub?.cancel();
  }

  void _handleDeepLink(
    Uri uri, {
    required BuildContext context,
    required AuthProvider authProvider,
  }) {
    if (_isProcessingLink) {
      Logger.info("Already processing a link, skipping...");
      return;
    }

    _isProcessingLink = true;

    try {
      Logger.info(
        "URI -> $uri\n"
        "scheme -> ${uri.scheme}\n"
        "host -> ${uri.host}\n"
        "path -> ${uri.path}",
      );

      //todo ---------------- Password Reset ----------------
      if (uri.host == "google.com") {
        Logger.info("Navigation triggered from verify-reset-password link");

        final token = uri.queryParameters["token"];

        if (token != null && token.isNotEmpty) {
          authProvider.setResetPasswordToken = token;
          Logger.info("Reset Password Token: $token");

          context.pushNamed(AppRoutes.forgotPasswordScreen.name);
        } else {
          Logger.error("No token found in password reset link");
        }

        _isProcessingLink = false;
        return;
      }

      //todo ---------------- Parent Consent ----------------
      if (uri.host == AppConstants.domain &&
          uri.path == AppConstants.parentConsentPath) {
        Logger.info("Navigation triggered from verify-parent-consent link");

        final token = uri.queryParameters["token"];

        if (token != null && token.isNotEmpty) {
          authProvider.setParentEmailToken = token;
          Logger.info("Parent Consent Token: $token");

          authProvider.verifyConsentRequest(
            onSuccess: () {
              UserAppRoute.goRouter.goNamed(
                AppRoutes.createAccountScreen.name,
                extra: true,
              );
            },
            onFailed: (e) {
              AppToast.error(context, e.errorMsg);
            },
          );
        } else {
          Logger.error("No token found in parent consent link");
        }

        _isProcessingLink = false;
        return;
      }

      Logger.info("No matching route found for URI: $uri");
      _isProcessingLink = false;
    } catch (e, st) {
      Logger.error("Deep link error -> $e\nStackTrace -> $st");
      _isProcessingLink = false;
    }
  }
}
