import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../core/theme/theme_selector_button.dart';
import '../../../core/widgets/audio_guide/audio_guide.dart';
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
  String? _audioGuideMessage;

  String get _defaultAudioGuideText =>
      'Pantalla de registro. Escribe tu usuario, nombre, email y contrasena. Acepta los terminos y pulsa crear cuenta.';

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
      _setAudioGuideMessage("Debes aceptar los terminos y condiciones.");
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
        final message = _registerErrorMessage(e);
        _setAudioGuideMessage(message);
        showAuthSnackBar(context, message);
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

  void _setAudioGuideMessage(String message) {
    setState(() {
      _audioGuideMessage = message.replaceAll("Exception: ", "");
    });
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
    final autoRead = MediaQuery.of(context).accessibleNavigation;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [ThemeSelectorButton()],
      ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: AudioGuideWidget(
        text: _audioGuideMessage ?? _defaultAudioGuideText,
        autoRead: autoRead,
      ),
    );
  }
}
