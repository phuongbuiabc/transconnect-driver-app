import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/validation/form_validators.dart';
import 'package:transconnect_driver_app/shared/widgets/brand.dart';

class AuthScreen extends StatefulWidget {
  final DriverController api;
  const AuthScreen({super.key, required this.api});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController(),
      phone = TextEditingController(),
      code = TextEditingController();
  String mode = 'login';
  String? message;
  bool busy = false, failed = false, hidden = true;
  @override
  void dispose() {
    for (final c in [email, password, name, phone, code]) {
      c.dispose();
    }
    super.dispose();
  }

  void change(String v) {
    setState(() {
      mode = v;
      message = null;
      password.clear();
      code.clear();
    });
    form.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Brand(),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE52027), Color(0xFFC01218)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_shipping_outlined, color: gold, size: 48),
                    SizedBox(height: 22),
                    Text(
                      'Vững tay lái.\nKết nối hành trình.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ứng dụng tài xế trong mạng lưới vận tải TransConnect.',
                      style: TextStyle(color: Colors.white, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Panel(
                child: Form(
                  key: form,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          {
                            'login': 'Chào mừng trở lại',
                            'register': 'Tạo tài khoản tài xế',
                            'forgot-password': 'Nhận mã khôi phục',
                            'reset-password': 'Đặt mật khẩu mới',
                          }[mode]!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (mode == 'register') ...[
                          TextFormField(
                            controller: name,
                            maxLength: 200,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                            ),
                            validator: requiredText,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: email,
                          maxLength: 256,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (v) =>
                              RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(v?.trim() ?? '')
                              ? null
                              : 'Nhập email hợp lệ.',
                        ),
                        const SizedBox(height: 12),
                        if (mode == 'reset-password') ...[
                          TextFormField(
                            controller: code,
                            maxLength: 10,
                            decoration: const InputDecoration(
                              labelText: 'Mã khôi phục',
                            ),
                            validator: requiredText,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (mode != 'forgot-password') ...[
                          TextFormField(
                            controller: password,
                            obscureText: hidden,
                            maxLength: 100,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: [
                              mode == 'login'
                                  ? AutofillHints.password
                                  : AutofillHints.newPassword,
                            ],
                            decoration: InputDecoration(
                              labelText: mode == 'reset-password'
                                  ? 'Mật khẩu mới'
                                  : 'Mật khẩu',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => hidden = !hidden),
                                tooltip: hidden
                                    ? 'Hiện mật khẩu'
                                    : 'Ẩn mật khẩu',
                                icon: Icon(
                                  hidden
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (v) => (v?.isEmpty ?? true)
                                ? 'Vui lòng nhập mật khẩu.'
                                : mode != 'login' && v!.length < 6
                                ? 'Mật khẩu có ít nhất 6 ký tự.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (mode == 'register') ...[
                          TextFormField(
                            controller: phone,
                            maxLength: 20,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại (không bắt buộc)',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (message != null) ...[
                          Notice(message!, failure: failed),
                          const SizedBox(height: 16),
                        ],
                        FilledButton(
                          onPressed: busy ? null : submit,
                          child: Text(
                            busy
                                ? 'Đang xử lý…'
                                : {
                                    'login': 'Đăng nhập',
                                    'register': 'Tạo tài khoản',
                                    'forgot-password': 'Gửi mã khôi phục',
                                    'reset-password': 'Đổi mật khẩu',
                                  }[mode]!,
                          ),
                        ),
                        if (mode == 'login') ...[
                          Center(
                            child: TextButton(
                              onPressed: busy
                                  ? null
                                  : () => change('forgot-password'),
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ),
                          const Divider(),
                          Center(
                            child: TextButton(
                              onPressed: busy ? null : () => change('register'),
                              child: const Text(
                                'Chưa có tài khoản? Đăng ký tài xế',
                              ),
                            ),
                          ),
                        ] else
                          Center(
                            child: TextButton(
                              onPressed: busy ? null : () => change('login'),
                              child: const Text('Quay lại đăng nhập'),
                            ),
                          ),
                        if (mode == 'forgot-password')
                          Center(
                            child: TextButton(
                              onPressed: busy
                                  ? null
                                  : () => change('reset-password'),
                              child: const Text('Tôi đã có mã khôi phục'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kết nối hành trình Việt',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final body = <String, dynamic>{'email': email.text.trim()};
      if (mode == 'login' || mode == 'register') {
        body['password'] = password.text;
        if (mode == 'register') {
          body['fullName'] = name.text.trim();
          if (phone.text.trim().isNotEmpty) {
            body['phoneNumber'] = phone.text.trim();
          }
        }
        await widget.api.authenticate(mode, body);
      } else {
        if (mode == 'reset-password') {
          body['code'] = code.text.trim();
          body['newPassword'] = password.text;
        }
        await widget.api.publicAction(mode, body);
        if (mounted) {
          setState(() {
            failed = false;
            message = mode == 'forgot-password'
                ? 'Nếu email tồn tại, mã khôi phục đã được gửi. Kiểm tra cả thư rác.'
                : 'Đổi mật khẩu thành công. Vui lòng đăng nhập lại.';
          });
        }
        password.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          failed = true;
          message = e.toString();
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
