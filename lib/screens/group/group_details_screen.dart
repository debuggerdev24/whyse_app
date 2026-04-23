import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/group/group_screen_params.dart';
import 'package:redstreakapp/screens/group/unified_group_screen.dart';

export 'group_screen_params.dart';

/// Opens the unified group hub on the **Details** tab.
class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key, required this.params});

  final GroupDetailsScreenParams params;

  @override
  Widget build(BuildContext context) {
    return UnifiedGroupScreen(params: params);
  }
}
