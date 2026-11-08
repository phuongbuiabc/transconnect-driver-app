import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/features/invitations/presentation/controllers/invitation_controller.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/validation/form_validators.dart';

class InvitationScreen extends StatefulWidget {
  final InvitationController api;
  final bool canAccept;
  final Future<void> Function() onAccepted;
  const InvitationScreen({
    super.key,
    required this.api,
    required this.canAccept,
    required this.onAccepted,
  });
  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final token = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhập mã lời mời')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Lời mời trong ứng dụng có nút Nhận ở mục Nhà xe. Chỉ dùng mã khi lời mời không hiện ở đó.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 20),
              if (!widget.canAccept)
                const Notice(
                  'Hồ sơ tài xế cần được duyệt trước khi bạn nhận lời mời.',
                )
              else
                Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: token,
                        maxLength: 128,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'Mã lời mời trong email',
                        ),
                        validator: requiredText,
                      ),
                      const SizedBox(height: 8),
                      if (error != null) ...[
                        Notice(error!, failure: true),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: busy ? null : accept,
                        child: Text(
                          busy ? 'Đang xác nhận…' : 'Chấp nhận lời mời',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> accept() async {
    if (busy || !widget.canAccept || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.accept(token.text.trim());
      await widget.onAccepted();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã nhận lời mời.')));
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
