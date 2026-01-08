import 'package:redstreakapp/routes/user_routes.dart';

extension AppRouteExtension on AppRoutes {
  String get path => this == AppRoutes.splashScreen ? "/" : "/$name";
}
