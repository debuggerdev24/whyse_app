import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';
import 'package:redstreakapp/screens/home/widgets/continue_reading_section.dart';
import 'package:redstreakapp/screens/home/widgets/curiosity_reading_section.dart';
import 'package:redstreakapp/screens/home/widgets/ebooks_books_section.dart';
import 'package:redstreakapp/screens/home/widgets/home_topics_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            const EbooksBooksHomeSections(),
            24.w.verticalSpace,
          ],
        ),
      ),
    );
  }
}
