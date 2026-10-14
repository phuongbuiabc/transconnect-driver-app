import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/validation/form_validators.dart';

class EmailVerificationScreen extends StatefulWidget {
  final DriverController api;
  const EmailVerificationScreen({super.key, required this.api});
  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final code = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false, failed = false;
  String? message;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Panel(
    child: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_unread_outlined, size: 48, color: red),
          const SizedBox(height: 20),
          const Text(
            'Xác thực email',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Nhập mã được gửi đến ' +
                (widget.api.user?['email'] as String? ?? '') +
                ' để tiếp tục nộp hồ sơ tài xế.',
            style: const TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: code,
            maxLength: 10,
            decoration: const InputDecoration(labelText: 'Mã xác thực'),
            validator: requiredText,
          ),
          const SizedBox(height: 16),
          if (message != null) ...[
            Notice(message!, failure: failed),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: busy ? null : () => act(false),
            child: Text(busy ? 'Đang xử lý…' : 'Xác thực email'),
          ),
          Center(
            child: TextButton(
              onPressed: busy ? null : () => act(true),
              child: const Text('Gửi lại mã xác thực'),
            ),
          ),
          const Text('Nếu đã xác thực trên thiết bị khác, hãy làm mới hồ sơ.'),
        ],
      ),
    ),
  );
  Future<void> act(bool resend) async {
    if (!resend && !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (resend) {
        await widget.api.publicAction('resend-verification', {
          'email': widget.api.user!['email'],
        });
      } else {
        await widget.api.verify(code.text.trim());
      }
      if (mounted) {
        setState(() {
          failed = false;
          message = resend
              ? 'Nếu email cần xác thực, mã mới đã được gửi.'
              : 'Xác thực thành công.';
        });
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
