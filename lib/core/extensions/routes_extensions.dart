import 'package:redstreakapp/core/routes/user_routes.dart';

extension AppRouteExtension on AppRoutes {
  String get path => this == AppRoutes.splashScreen ? "/" : "/$name";
}
