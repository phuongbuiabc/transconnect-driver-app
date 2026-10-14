import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/validation/form_validators.dart';

class InvitationScreen extends StatefulWidget {
  final DriverController api;
  const InvitationScreen({super.key, required this.api});
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Lời mời cộng tác',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      const Text(
        'Sử dụng mã lời mời từ email của đơn vị vận tải.',
        style: TextStyle(color: Color(0xFF66666B), height: 1.5),
      ),
      const SizedBox(height: 24),
      if (!widget.api.canAccept)
        const Notice(
          'Hồ sơ tài xế cần được duyệt trước khi bạn chấp nhận lời mời.',
        )
      else
        Panel(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.handshake_outlined, color: red, size: 44),
                const SizedBox(height: 20),
                TextFormField(
                  controller: token,
                  maxLength: 128,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Mã lời mời',
                    hintText: 'Dán mã từ email',
                  ),
                  validator: requiredText,
                ),
                const SizedBox(height: 16),
                if (error != null) ...[
                  Notice(error!, failure: true),
                  const SizedBox(height: 16),
                ],
                FilledButton(
                  onPressed: busy ? null : accept,
                  child: Text(busy ? 'Đang xác nhận…' : 'Chấp nhận lời mời'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chấp nhận đồng nghĩa với việc xác nhận cộng tác cùng đơn vị đã gửi lời mời.',
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      if (widget.api.receipt != null) ...[
        const SizedBox(height: 20),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF21803D),
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                'Đã chấp nhận lời mời',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Mã đơn vị vận tải'),
              SelectableText(
                widget.api.receipt!['organizationId'] as String? ?? '',
              ),
              const SizedBox(height: 12),
              const Text('Mã cộng tác'),
              SelectableText(widget.api.receipt!['id'] as String? ?? ''),
            ],
          ),
        ),
      ],
    ],
  );
  Future<void> accept() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.accept(token.text.trim());
      token.clear();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
