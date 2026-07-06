import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/screens/home/widgets/continue_reading_section.dart';
import 'package:redstreakapp/screens/home/widgets/curiosity_reading_section.dart';
import 'package:redstreakapp/screens/home/widgets/books_books_section.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GamificationProvider>().fetchStreakScore();
    });
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
    return AppLayout(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 15.w),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const HomeHeader(),
            ),
            20.w.verticalSpace,

            const CalendarStrip(),
            24.w.verticalSpace,

            CuriosityReadingSection(),

            24.w.verticalSpace,

            ContinueReadingSection(),
            24.w.verticalSpace,

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const HomeStoryTopics(),
            ),

            24.w.verticalSpace,
            // const BooksBooksHomeSections(),
            // 24.w.verticalSpace,
          ],
        ),
      ),
    );
  }
}
