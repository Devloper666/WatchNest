import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/watchnest_shell.dart';
import 'auth_controller.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.isAuthenticated) {
          return const WatchNestShell();
        }
        return const AuthScreen();
      },
    );
  }
}
