import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/core/routes/app_router.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/screens/home/story/shared_story_screen.dart';
import 'package:redstreakapp/screens/home/story/story_series_screen.dart';

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
        if (link != null) {
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
        "URI Data-> ${uri.data}\n"
        "URI query-> ${uri.query}\n"
        "URI queryParameters-> ${uri.queryParameters}\n"
        "scheme -> ${uri.scheme}\n"
        "host -> ${uri.host}\n"
        "path -> ${uri.path}",
      );
      final currentCtx =
          AppRouter.goRouter.routerDelegate.navigatorKey.currentContext;

      //todo ---------------- Password Reset ----------------

      if (uri.path == AppConstants.forgotPasswordPath &&
          uri.host == AppConstants.domain) {
        Logger.info("Navigation triggered from verify-reset-password link");

        
        final fragment = uri.fragment;
        Logger.info("Fragment: $fragment");

        final params = Uri.splitQueryString(fragment);
        final token = params[AppConstants.accessToken];
        final type = params[AppConstants.type];
        Logger.info("Type: $type");

        if (type == AppConstants.recovery) {
          if (token != null && token.isNotEmpty) {
            provider.setResetPasswordToken = token;
            Logger.info("Reset Password Token: $token");
            provider.verifyForgotPasswordEmail(
              onSuccess: () {
                AppRouter.goRouter.goNamed(
                  AppRoutes.resetPasswordScreen.name,
                  extra: true,
                );
                AppToast.success(currentCtx!, "Email verify successfully.");
              },
              onFailed: (e) {
                AppToast.error(context, e.errorMsg);
              },
            );
            return;
          }
          AppToast.info(
            context: context,
            message:
                "Password reset link is invalid or has expired. Please request a new one.",
          );

          if (currentCtx != null) {
            AppToast.info(
              context: currentCtx,
              message:
                  "Password reset link is invalid or has expired. Please request a new one.",
            );
          } else {
            Logger.error("Root context not available for toast");
          }
        } else {
          if (type == AppConstants.signup && token != null) {
            AppRouter.goRouter.goNamed(
              AppRoutes.createAccountScreen.name,
              // extra: true,
            );
            provider.verifyCreateAccEmail(currentCtx!);
            return;
          }
          if (currentCtx != null) {
            AppToast.info(
              context: currentCtx,
              message:
                  "Confirmation link is invalid or has expired. Please request a new one.",
            );
          }
        }
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
              AppRouter.goRouter.goNamed(
                (provider.isUnder16FromGoogle)
                    ? AppRoutes.profileInfoScreen.name
                    : AppRoutes.createAccountScreen.name,
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

        return;
      }

      // ---------------- Story / topic (share link) ----------------
      // Prefer topicId: fetch ideas by topic, set story series state, show story series screen and generate first story.
      if (uri.host == AppConstants.domain &&
          uri.path == AppConstants.storyPath) {
        final topicId = uri.queryParameters[AppConstants.topicIdParam];
        final storyIdeaId = uri.queryParameters[AppConstants.storyIdeaIdParam];

        if (topicId != null && topicId.trim().isNotEmpty) {
          Logger.info("Story deep link -> topicId: $topicId");
          if (currentCtx != null) {
            _openStorySeriesByTopicId(
              context: currentCtx,
              topicId: topicId.trim(),
            );
          }
          return;
        }

        // Fallback: legacy link with story idea id only -> open single story reading screen.
        if (storyIdeaId != null && storyIdeaId.trim().isNotEmpty) {
          Logger.info("Story deep link (legacy) -> storyIdeaId: $storyIdeaId");
          StoryReadingScreen.skipLeaveDialogForDeepLink = true;
          AppRouter.goRouter.goNamed(
            AppRoutes.createdStoryReadingScreen.name,
            extra: <String, dynamic>{"storyIdeaId": storyIdeaId.trim()},
          );
          return;
        }

        Logger.error("Story link missing topicId or id parameter: $uri");
        return;
      }

      Logger.info("No matching route found for URI: $uri");
    } catch (e, st) {
      Logger.error("Deep link error -> $e\nStackTrace -> $st");
    } finally {
      _isProcessingLink = false; // ✅ SINGLE PLACE
    }
  }

  /// Fetches story ideas by topicId, sets StoryProvider for series screen, then navigates and triggers first story generation.
  Future<void> _openStorySeriesByTopicId({
    required BuildContext context,
    required String topicId,
  }) async {
    final homeProvider = context.read<HomeProvider>();
    final storyProvider = context.read<StoryProvider>();

    await homeProvider.getStoryIdeasByTopicId(topicId: topicId);

    if (!context.mounted) return;
    final summary = homeProvider.storySummary;
    if (summary == null ||
        summary.storyIdeas.isEmpty ||
        summary.topicId != topicId) {
      Logger.error(
        "Deep link: no story ideas for topicId $topicId or topic mismatch",
      );
      if (context.mounted) {
        AppToast.error(
          context,
          "Could not load stories for this topic.",
        );
      }
      return;
    }

    storyProvider.setFromStorySummary(summary);
    SharedStoryScreen.prepareForDeepLink();

    if (!context.mounted) return;
    AppRouter.goRouter.goNamed(AppRoutes.sharedStoryScreen.name);
  }
}
