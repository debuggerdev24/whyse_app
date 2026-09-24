import 'package:redstreakapp/core/auth/session_expiry_notifier.dart';
import 'package:redstreakapp/core/session/app_session_reset.dart';
import 'package:redstreakapp/core/theme/app_palette.dart';
import 'package:redstreakapp/core/theme/app_theme.dart';
import 'package:redstreakapp/core/theme/app_theme_controller.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/services/deep_link/deep_link_handler.dart';

class WhyseApp extends StatefulWidget {
  const WhyseApp({super.key});

  @override
  State<WhyseApp> createState() => _WhyseAppState();
}

class _WhyseAppState extends State<WhyseApp> with WidgetsBindingObserver {
  late AuthProvider provider;
  late DeepLinkHandler _deepLinkHandler;
  late VoidCallback _sessionExpiryListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppThemeController.instance.addListener(_rebuildForTheme);
    provider = context.read<AuthProvider>();
    _deepLinkHandler = DeepLinkHandler();
    _sessionExpiryListener = _handleSessionExpired;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init(context: context, authProvider: provider);
    });
    SessionExpiryNotifier.instance.eventCounter.addListener(
      _sessionExpiryListener,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppThemeController.instance.removeListener(_rebuildForTheme);
    SessionExpiryNotifier.instance.eventCounter.removeListener(
      _sessionExpiryListener,
    );
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    AppThemeController.instance.refreshSystemBrightness();
  }

  /// [AppColors] is read directly by existing screens, including const widgets.
  /// Marking the tree dirty makes those screens pick up the new palette
  /// without resetting navigation.
  void _rebuildForTheme() {
    if (!mounted) return;
    void visit(Element element) {
      element.markNeedsBuild();
      element.visitChildren(visit);
    }

    visit(context as Element);
  }

  void _handleSessionExpired() {
    if (!mounted) return;

    context.read<AuthProvider>().clearAllData();
    resetAppProvidersForNewUser(context);

    // final rootContext = AppRouter.rootNavigatorKey.currentContext ?? context;
    // AppToast.error(rootContext, "Session expired. Please log in again", 3);
    AppRouter.goRouter.goNamed(AppRoutes.loginScreen.name);
    SessionExpiryNotifier.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeController = context.watch<AppThemeController>();
        final palette = themeController.palette;
        final followsDevice =
            themeController.choice == AppThemeChoice.system;
        return MaterialApp.router(
          theme: followsDevice
              ? AppThemes.light()
              : AppThemes.fromPalette(
                  palette.brightness == Brightness.light
                      ? palette
                      : AppPalette.light,
                ),
          darkTheme: followsDevice
              ? AppThemes.dark()
              : AppThemes.fromPalette(
                  palette.brightness == Brightness.dark
                      ? palette
                      : AppPalette.dark,
                ),
          themeMode: themeController.themeMode,
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: AppThemes.overlayStyle(themeController.palette),
              child: child ?? const SizedBox.shrink(),
            );
          },
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.goRouter,
        );
      },
    );
  }
}
