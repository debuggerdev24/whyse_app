import 'package:redstreakapp/core/auth/session_expiry_notifier.dart';
import 'package:redstreakapp/core/session/app_session_reset.dart';
import 'package:redstreakapp/core/theme/theme_refresh.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/theme/app_theme_provider.dart';
import 'package:redstreakapp/services/deep_link/deep_link_handler.dart';

class WhyseApp extends StatefulWidget {
  const WhyseApp({super.key});

  @override
  State<WhyseApp> createState() => _WhyseAppState();
}

class _WhyseAppState extends State<WhyseApp> {
  late AuthProvider provider;
  late DeepLinkHandler _deepLinkHandler;
  late VoidCallback _sessionExpiryListener;

  @override
  void initState() {
    super.initState();
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
    SessionExpiryNotifier.instance.eventCounter.removeListener(
      _sessionExpiryListener,
    );
    _deepLinkHandler.dispose();
    super.dispose();
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
    final palette = context.watch<AppThemeProvider>().palette;

    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: palette.background,
            colorScheme: ColorScheme.light(
              primary: palette.primary,
              secondary: palette.highlight,
              surface: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
              scrolledUnderElevation: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: AppTextStyles.semibold(
                fontSize: 20,
                color: AppColors.black,
              ),
            ),
          ),
          builder: (context, navChild) {
            return ThemeRefresh(
              themeId: palette.id,
              child: navChild ?? const SizedBox.shrink(),
            );
          },
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.goRouter,
        );
      },
    );
  }
}
