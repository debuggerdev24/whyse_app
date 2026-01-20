import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/constants/shared_pref.dart';
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
          _handleDeepLink(uri, context: context, provider: authProvider);
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
    required AuthProvider provider,
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
      final currentCtx =
          UserAppRoute.goRouter.routerDelegate.navigatorKey.currentContext;

      //todo ---------------- Password Reset ----------------

      if (uri.path == AppConstants.forgotPasswordPath &&
          uri.host == AppConstants.domain) {
        Logger.info("Navigation triggered from verify-reset-password link");

        // final token = uri.queryParameters[AppConstants.accessToken];
        final fragment = uri.fragment;
        Logger.info("Fragment: $fragment");

        final params = Uri.splitQueryString(fragment);
        final token = params[AppConstants.accessToken];

        if (token != null && token.isNotEmpty) {
          provider.setResetPasswordToken = token;
          Logger.info("Reset Password Token: $token");
          provider.verifyForgotPasswordEmail(
            onSuccess: () {
              UserAppRoute.goRouter.goNamed(
                AppRoutes.resetPasswordScreen.name,
                extra: true,
              );
              AppToast.success(currentCtx!, "Email verify successfully.");
            },
            onFailed: (e) {
              AppToast.error(context, e.errorMsg);
            },
          );
        } else {
          // AppToast

          if (currentCtx != null) {
            AppToast.info(
              context: currentCtx,
              message:
                  "Password reset link is invalid or has expired. Please request a new one.",
            );
          } else {
            Logger.error("Root context not available for toast");
          }
        }

        _isProcessingLink = false;
        return;
      }

      //todo ---------------- Parent Consent ----------------
      if (uri.host == AppConstants.domain &&
          uri.path == AppConstants.parentConsentPath) {
        //todo if already verify then it wll be return.
        if (LocalStorageService.instance.getConsentRequestStatus) {
          AppToast.info(
            context: currentCtx!,
            message: "Consent request all ready approved",
          );
          return;
        }
        final token = uri.queryParameters[AppConstants.token];
        if (token != null && token.isNotEmpty) {
          provider.setConsentRequestToken = token;
          Logger.info("Parent Consent Token: $token");

          provider.verifyConsentRequest(
            onSuccess: () {
              UserAppRoute.goRouter.goNamed(
                AppRoutes.createAccountScreen.name,
                extra: AppConstants.trueSt,
              );
              LocalStorageService.instance.saveParentConsentStatus(
                status: true,
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
