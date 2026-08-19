import 'package:flutter/material.dart';

import '../../../../shared/constants/app_sizes.dart';
import '../widgets/login_form.dart';

/// Login page — demonstrates a complete feature page.
///
/// Andrea's tip #32: Use composition aggressively
/// — the page composes LoginForm, not inherits from a base class.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSizes.pageAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.flutter_dash,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  AppSizes.gap16,
                  Text(
                    'Flutter Kit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.gap8,
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  AppSizes.gap48,

                  // Form
                  const LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
