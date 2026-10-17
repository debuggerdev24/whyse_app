import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/home/widgets/continue_reading_section.dart';
import 'package:redstreakapp/screens/home/widgets/curiosity_reading_section.dart';
import 'package:redstreakapp/screens/home/widgets/home_topics_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
  } 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Returned to Home from another screen (story ideas / reader etc).
    if (!mounted) return;
    context.read<HomeProvider>().getContinueReading(force: true);
    context.read<GamificationProvider>().fetchStreakScore(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return AppLayout(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
              child: const HomeHeader(),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.vertical) {
                    return false;
                  }
                  if (notification.metrics.maxScrollExtent <= 0) return false;
                  if (notification.metrics.pixels <
                      notification.metrics.maxScrollExtent - 280) {
                    return false;
                  }
                  final home = context.read<HomeProvider>();
                  if (home.hasMoreTopics &&
                      !home.isTopicsLoadingMore &&
                      !home.isTopicsLoading) {
                    home.getMyTopicsLoadMore();
                  }
                  return false;
                },
                child: ListView(
                  padding: EdgeInsets.only(bottom: bottomInset + 108.h),
                  children: [
                    const CuriosityReadingSection(),
                    26.h.verticalSpace,
                    const ContinueReadingSection(),
                    26.h.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: const HomeStoryTopics(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
