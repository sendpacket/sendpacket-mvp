import 'package:flutter/material.dart';
import '../screens/announcement/create_announcement_screen.dart';
import '../screens/auth/login_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String createAnnonce = '/create-annonce';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    createAnnonce: (_) => const CreateAnnouncementScreen(),
  };
}
