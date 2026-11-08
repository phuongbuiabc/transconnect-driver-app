import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/features/driver_profile/presentation/controllers/driver_profile_controller.dart';
import 'package:transconnect_driver_app/shared/validation/form_validators.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';

class DriverProfileForm extends StatefulWidget {
  final DriverProfileController api;
  final String fullName;
  final VoidCallback onSubmitted;
  const DriverProfileForm({
    super.key,
    required this.api,
    required this.fullName,
    required this.onSubmitted,
  });
  @override
  State<DriverProfileForm> createState() => _DriverProfileFormState();
}

class _DriverProfileFormState extends State<DriverProfileForm> {
  final name = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    name.text = widget.api.profile?.fullName ?? widget.fullName;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resubmit = widget.api.profile?.reviewStatus == 'Rejected';
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: name,
            maxLength: 200,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Họ và tên trên giấy phép lái xe',
            ),
            validator: requiredText,
          ),
          const SizedBox(height: 8),
          if (error != null) ...[
            Notice(error!, failure: true),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: busy ? null : submit,
            child: Text(
              busy
                  ? 'Đang gửi…'
                  : resubmit
                  ? 'Gửi lại hồ sơ'
                  : 'Gửi hồ sơ xét duyệt',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.submit(name.text.trim());
      widget.onSubmitted();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
