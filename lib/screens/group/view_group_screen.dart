import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/group/group_screen_params.dart';
import 'package:redstreakapp/screens/group/unified_group_screen.dart';

/// Opens the unified group hub on the **Updates** tab (feed + share CTA).
class ViewGroupScreen extends StatelessWidget {
  const ViewGroupScreen({super.key, required this.params});

  final GroupDetailsScreenParams params;

  @override
  Widget build(BuildContext context) {
    return UnifiedGroupScreen(
      params: GroupDetailsScreenParams(
        id: params.id,
        groupName: params.groupName,
        thumbnail: params.thumbnail,
        description: params.description,
        initialTab: 1,
        inviteCode: params.inviteCode,
        myRole: params.myRole,
      ),
    );
  }
}
