import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class EditAccountScreen extends StatefulWidget {
  final AuthController api;
  const EditAccountScreen({super.key, required this.api});
  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final profileForm = GlobalKey<FormState>();
  final passwordForm = GlobalKey<FormState>();
  bool busy = false;
  String? notice;
  @override
  void initState() {
    super.initState();
    widget.api.addListener(_authChanged);
    name.text = widget.api.user?.fullName ?? '';
    phone.text = widget.api.user?.phoneNumber ?? '';
  }

  void _authChanged() {
    if (!mounted) return;
    setState(() {});
    if (!widget.api.signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  Future<void> save(bool password) async {
    if (busy ||
        !(password ? passwordForm : profileForm).currentState!.validate()) {
      return;
    }
    setState(() {
      busy = true;
      notice = null;
    });
    try {
      if (password) {
        await widget.api.changePassword(currentPassword.text, newPassword.text);
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.of(context).pop();
        }
      } else {
        await widget.api.updateProfile(name.text.trim(), phone.text.trim());
        if (mounted) setState(() => notice = 'Đã lưu thông tin tài khoản.');
      }
    } catch (error) {
      if (mounted) setState(() => notice = error.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> avatar() async {
    if (busy) return;
    setState(() {
      busy = true;
      notice = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (file == null || !mounted) return;
      if (await file.length() > 5 * 1024 * 1024) {
        throw Exception('Ảnh tối đa 5 MB.');
      }
      await widget.api.uploadAvatar(await file.readAsBytes(), file.name);
      if (mounted) setState(() => notice = 'Đã cập nhật ảnh đại diện.');
    } catch (error) {
      if (mounted) setState(() => notice = error.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    widget.api.removeListener(_authChanged);
    name.dispose();
    phone.dispose();
    currentPassword.dispose();
    newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thông tin tài khoản')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.api.user?.avatarUrl case final String url)
          Image.network(
            url,
            height: 96,
            width: 96,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.account_circle_outlined, size: 64),
          ),
        OutlinedButton.icon(
          onPressed: busy ? null : avatar,
          icon: const Icon(Icons.photo_outlined),
          label: const Text('Chọn ảnh đại diện'),
        ),
        Form(
          key: profileForm,
          child: Column(
            children: [
              TextFormField(
                controller: name,
                enabled: !busy,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhập họ tên'
                    : null,
              ),
              TextFormField(
                controller: phone,
                enabled: !busy,
                maxLength: 20,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              FilledButton(
                onPressed: busy ? null : () => save(false),
                child: const Text('Lưu thông tin'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text('Sau khi đổi mật khẩu, bạn cần đăng nhập lại.'),
        Form(
          key: passwordForm,
          child: Column(
            children: [
              TextFormField(
                controller: currentPassword,
                enabled: !busy,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nhập mật khẩu hiện tại'
                    : null,
              ),
              TextFormField(
                controller: newPassword,
                enabled: !busy,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: (value) =>
                    value == null || value.length < 6 || value.length > 100
                    ? 'Dùng 6–100 ký tự'
                    : null,
              ),
              FilledButton(
                onPressed: busy ? null : () => save(true),
                child: const Text('Đổi mật khẩu'),
              ),
            ],
          ),
        ),
        if (notice != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(notice!, semanticsLabel: notice),
          ),
      ],
    ),
  );
}
