import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import '../controllers/foundation_controller.dart';

class ContactScreen extends StatefulWidget {
  final FoundationController controller;
  final String driverId;
  const ContactScreen({
    super.key,
    required this.controller,
    required this.driverId,
  });
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final phone = TextEditingController(), address = TextEditingController();
  final form = GlobalKey<FormState>();
  bool saved = false;

  @override
  void initState() {
    super.initState();
    final contact = widget.controller.contact;
    phone.text = contact?.phone ?? '';
    address.text = contact?.address ?? '';
    widget.controller.addListener(changed);
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(changed);
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saved = false);
    await widget.controller.updateContact(
      widget.driverId,
      phone.text.trim(),
      address.text.trim(),
    );
    if (mounted && widget.controller.error == null) {
      setState(() => saved = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller;
    final busy = state.busy || state.loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin liên hệ')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Nhà xe đang cộng tác dùng số và địa chỉ này để liên hệ với bạn.',
                    style: TextStyle(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phone,
                    maxLength: 20,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Số liên hệ'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập số liên hệ'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: address,
                    maxLength: 500,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ liên hệ',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập địa chỉ liên hệ'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  if (state.error != null) ...[
                    Notice(state.error!, failure: true),
                    const SizedBox(height: 12),
                  ],
                  if (saved && state.error == null) ...[
                    const Notice('Đã lưu thông tin liên hệ.'),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: busy ? null : save,
                    child: Text(state.busy ? 'Đang lưu…' : 'Lưu liên hệ'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
