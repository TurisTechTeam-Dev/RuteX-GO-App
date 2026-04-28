import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/app_routes.dart';
import '../domain/usecases/auth_use_cases.dart';
import 'widgets/auth_snack_bar.dart';
import 'widgets/register_content.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  late final AuthUseCases _authUseCases;

  bool get _isButtonEnabled {
    return _usernameController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _acceptedTerms;
  }

  @override
  void initState() {
    super.initState();
    _authUseCases = context.read<AuthUseCases>();

    _usernameController.addListener(_refreshFormState);
    _nameController.addListener(_refreshFormState);
    _emailController.addListener(_refreshFormState);
    _passwordController.addListener(_refreshFormState);
    _confirmPasswordController.addListener(_refreshFormState);
  }

  void _refreshFormState() => setState(() {});

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes aceptar los términos y condiciones."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authUseCases.register(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
          arguments: const {AppRoutes.showInfoOnHomeStartArg: true},
        );
      }
    } catch (e) {
      if (mounted) {
        showAuthSnackBar(context, _registerErrorMessage(e));
      }
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _registerErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('email-already-in-use')) {
      return "El correo electrónico ya está registrado.";
    }

    return message.replaceAll("Exception: ", "");
  }

  void _updateAcceptedTerms(bool accepted) {
    setState(() => _acceptedTerms = accepted);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_refreshFormState);
    _nameController.removeListener(_refreshFormState);
    _emailController.removeListener(_refreshFormState);
    _passwordController.removeListener(_refreshFormState);
    _confirmPasswordController.removeListener(_refreshFormState);
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: RegisterContent(
        formKey: _formKey,
        usernameController: _usernameController,
        nameController: _nameController,
        emailController: _emailController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        acceptedTerms: _acceptedTerms,
        isLoading: _isLoading,
        isButtonEnabled: _isButtonEnabled,
        onAcceptedTermsChanged: _updateAcceptedTerms,
        onRegister: _handleRegister,
        onOpenLogin: () => Navigator.pop(context),
      ),
    );
  }
}
