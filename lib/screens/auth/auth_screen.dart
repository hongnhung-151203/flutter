import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();
  UserRole _registerRole = UserRole.tenant;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final auth = context.read<AuthProvider>();
      auth.clearError();
      setState(() {
        if (_tabController.index == 0) {
          _registerNameController.clear();
          _registerEmailController.clear();
          _registerPasswordController.clear();
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    body: Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[300]);
            },
          ),
        ),
        // Blur + translucent overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 48, color: Colors.pink),
                        const SizedBox(height: 12),
                        Text(
                          _tabController.index == 0
                              ? 'Chào mừng bạn đến với ứng dụng Quản Lý Nhà Trọ'
                              : 'Hãy tạo một tài khoản',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tabs: fix width & rounded indicator
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  tabs: const [
                                    Tab(text: 'Đăng nhập'),
                                    Tab(text: 'Đăng ký'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error message
                        if (auth.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    auth.errorMessage!,
                                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Form body
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: SizedBox(
                            height: _tabController.index == 0 ? 270 : 400,
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildLoginForm(auth),
                                _buildRegisterForm(auth),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildLoginForm(AuthProvider auth) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildTextField(
          controller: _loginEmailController,
          hintText: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(controller: _loginPasswordController),
        const SizedBox(height: 24),
        _buildSubmitButton(
          text: 'ĐĂNG NHẬP',
          onPressed: auth.isLoading ? null : () => _handleLogin(auth),
          isLoading: auth.isLoading,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider auth) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildTextField(
            controller: _registerNameController,
            hintText: 'Họ tên',
            icon: Icons.person_outline,
            validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _registerEmailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
          ),
          const SizedBox(height: 16),
          _buildRoleDropdown(),
          const SizedBox(height: 16),
          _buildPasswordField(controller: _registerPasswordController),
          const SizedBox(height: 24),
          _buildSubmitButton(
            text: 'ĐĂNG KÝ',
            onPressed: auth.isLoading ? null : () => _handleRegister(auth),
            isLoading: auth.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green[600]),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      validator: (value) => value == null || value.length < 6 ? 'Ít nhất 6 ký tự' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: Colors.green[600]),
        hintText: 'Mật khẩu',
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.green[600]),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 6,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButton<UserRole>(
      value: _registerRole,
      isExpanded: true,
      underline: const SizedBox(),
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.green[600]),
      items: UserRole.values.map((role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Row(
            children: [
              Icon(
                role == UserRole.landlord ? Icons.home_work : Icons.person,
                color: Colors.pink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(role == UserRole.landlord ? 'Chủ trọ' : 'Khách thuê'),
            ],
          ),
        );
      }).toList(),
      onChanged: (role) {
        if (role != null) {
          setState(() => _registerRole = role);
        }
      },
    ),
  );
}

  Future<void> _handleLogin(AuthProvider auth) async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    final success = await auth.login(email: email, password: password);
    if (success && auth.currentUser != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _handleRegister(AuthProvider auth) async {
    if (!_registerFormKey.currentState!.validate()) return;

    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text.trim();

    final success = await auth.register(
      email: email,
      password: password,
      name: name,
      role: _registerRole,
    );

    if (success && auth.currentUser != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
