import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/features/driver_profile/presentation/controllers/driver_profile_controller.dart';
import 'package:transconnect_driver_app/shared/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/validation/form_validators.dart';

class DriverProfileScreen extends StatefulWidget {
  final DriverProfileController api;
  final String fullName;
  const DriverProfileScreen({
    super.key,
    required this.api,
    required this.fullName,
  });
  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final name = TextEditingController();
  final form = GlobalKey<FormState>();
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    name.text = widget.fullName;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.api.profile;
    final status = driver?.reviewStatus;
    final approved = status == 'Approved', rejected = status == 'Rejected';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xin chào,\n' + (widget.fullName),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text(
          'Hoàn thiện hồ sơ để kết nối với đơn vị vận tải.',
          style: TextStyle(color: Color(0xFF66666B), height: 1.5),
        ),
        const SizedBox(height: 24),
        if (rejected && driver?.reviewNote != null)
          Notice(driver!.reviewNote!, failure: true),
        if (driver == null || rejected)
          Panel(
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.badge_outlined, color: red, size: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Đăng ký hồ sơ tài xế',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kiểm tra họ tên trước khi gửi hồ sơ để nền tảng xét duyệt.',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: name,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên tài xế',
                    ),
                    validator: requiredText,
                  ),
                  const SizedBox(height: 16),
                  if (error != null) ...[
                    Notice(error!, failure: true),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: Text(busy ? 'Đang gửi…' : 'Gửi hồ sơ xét duyệt'),
                  ),
                ],
              ),
            ),
          )
        else
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  approved
                      ? Icons.verified_outlined
                      : rejected
                      ? Icons.error_outline
                      : Icons.hourglass_top_rounded,
                  size: 48,
                  color: approved ? const Color(0xFF21803D) : red,
                ),
                const SizedBox(height: 20),
                Text(
                  approved
                      ? 'Hồ sơ đã được duyệt'
                      : rejected
                      ? 'Hồ sơ chưa được duyệt'
                      : status == 'Pending'
                      ? 'Đang chờ xét duyệt'
                      : 'Trạng thái: ' + (status ?? ''),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(driver.fullName),
                const SizedBox(height: 16),
                Notice(
                  approved
                      ? 'Bạn có thể chấp nhận lời mời cộng tác ở mục Lời mời.'
                      : rejected
                      ? 'Vui lòng liên hệ đơn vị vận tải hoặc quản trị nền tảng để được hướng dẫn.'
                      : 'Hồ sơ đã được tiếp nhận. Kéo xuống để cập nhật kết quả xét duyệt.',
                ),
                if ((driver.reviewNote ?? '').isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Ghi chú xét duyệt',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(driver.reviewNote!, style: const TextStyle(height: 1.5)),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
        const Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Các bước tham gia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 18),
              Text(
                '01   Xác thực email\n\n02   Nộp hồ sơ và chờ xét duyệt\n\n03   Nhận lời mời cộng tác từ nhà xe',
                style: TextStyle(height: 1.6),
              ),
            ],
          ),
        ),
      ],
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
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
