

import 'package:redstreakapp/routes/user_routes.dart';

extension AppRouteExtension on UserAppRoutes {
  String get path => this == UserAppRoutes.splashScreen ? "/" : "/$name";
}