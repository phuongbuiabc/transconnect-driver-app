import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/foundation_controller.dart';

class FoundationScreen extends StatefulWidget {
  final FoundationController controller;
  final String driverId;
  const FoundationScreen({
    super.key,
    required this.controller,
    required this.driverId,
  });
  @override
  State<FoundationScreen> createState() => _FoundationScreenState();
}

class _FoundationScreenState extends State<FoundationScreen> {
  final phone = TextEditingController(), address = TextEditingController();
  final form = GlobalKey<FormState>();
  bool confirmed = false, picking = false;
  String? localError;
  bool initialized = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(changed);
    widget.controller.load(widget.driverId);
  }

  void changed() {
    if (!mounted) return;
    if (!initialized && widget.controller.contact != null) {
      initialized = true;
      phone.text = widget.controller.contact!.phone ?? '';
      address.text = widget.controller.contact!.address ?? '';
    }
    setState(() {});
  }

  Future<void> upload() async {
    if (!confirmed || picking || widget.controller.busy) return;
    setState(() {
      picking = true;
      localError = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (file == null || !mounted) return;
      if (await file.length() > 5 * 1024 * 1024) {
        throw Exception('Tệp tối đa 5 MB.');
      }
      await widget.controller.upload(
        widget.driverId,
        await file.readAsBytes(),
        file.name,
      );
    } catch (error) {
      if (mounted) setState(() => localError = error.toString());
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  Future<void> preview(String id) async {
    try {
      final bytes = await widget.controller.preview(id);
      if (!mounted || !widget.controller.signedIn) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ảnh giấy tờ demo'),
          content: Image.memory(
            Uint8List.fromList(bytes),
            errorBuilder: (_, _, _) =>
                const Text('Tệp này không phải ảnh xem trực tiếp.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) setState(() => localError = error.toString());
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(changed);
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller, busy = widget.controller.busy || picking;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ và cộng tác'),
        actions: [
          IconButton(
            onPressed: state.loading || busy
                ? null
                : () => state.load(widget.driverId),
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: !state.signedIn
          ? const Center(child: Text('Vui lòng đăng nhập lại.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (state.loading) const LinearProgressIndicator(),
                if (state.error != null)
                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                if (localError != null)
                  Text(localError!, style: const TextStyle(color: Colors.red)),
                const Text(
                  'Thông tin liên hệ tài xế',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Form(
                  key: form,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: phone,
                        maxLength: 20,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số liên hệ',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nhập số liên hệ'
                            : null,
                      ),
                      TextFormField(
                        controller: address,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ liên hệ',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nhập địa chỉ liên hệ'
                            : null,
                      ),
                      FilledButton(
                        onPressed: busy || state.loading
                            ? null
                            : () {
                                if (form.currentState!.validate()) {
                                  widget.controller.updateContact(
                                    widget.driverId,
                                    phone.text.trim(),
                                    address.text.trim(),
                                  );
                                }
                              },
                        child: const Text('Lưu liên hệ'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đơn vị cộng tác',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (!state.loading && state.collaborations.isEmpty)
                  const Text('Chưa có quan hệ cộng tác.'),
                ...state.collaborations.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.organizationName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.endedAt != null
                                ? 'Đã kết thúc'
                                : item.revokedAt != null
                                ? 'Đã thu hồi'
                                : item.acceptedAt != null
                                ? 'Đang cộng tác'
                                : 'Đang mời',
                          ),
                          if (item.acceptedAt != null &&
                              item.endedAt == null &&
                              item.revokedAt == null)
                            OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => state.end(widget.driverId, item),
                              child: const Text('Kết thúc cộng tác'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lời mời qua email',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...state.invitations.map(
                  (item) => ListTile(
                    title: Text(item.organizationName),
                    subtitle: Text(
                      '${item.role} · ${item.acceptedAt != null
                          ? 'Đã nhận'
                          : item.revokedAt != null
                          ? 'Đã thu hồi'
                          : 'Hạn: ${item.expiresAt}'}',
                    ),
                  ),
                ),
                const Text(
                  'Dùng mã từ email tại mục Lời mời để chấp nhận sau khi hồ sơ được duyệt.',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lịch sử xét duyệt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...state.reviews.map(
                  (item) => ListTile(
                    title: Text(item.status),
                    subtitle: Text('${item.createdAt}\n${item.note ?? ''}'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'GPLX giả lập',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Chỉ dùng dữ liệu giả. Quét/OCR và duyệt là mô phỏng, chưa xác minh giấy tờ thật.',
                ),
                if (state.documentError != null) Text(state.documentError!),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: confirmed,
                  onChanged: busy
                      ? null
                      : (value) => setState(() => confirmed = value ?? false),
                  title: const Text('Tôi xác nhận ảnh chỉ chứa dữ liệu giả.'),
                ),
                OutlinedButton(
                  onPressed: busy || !confirmed ? null : upload,
                  child: const Text('Chọn ảnh và tải phiên bản mới'),
                ),
                ...state.documents.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phiên bản ${item.version} · ${item.status} · NOT_VERIFIED',
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: busy ? null : () => preview(item.id),
                                child: const Text('Xem ảnh'),
                              ),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () => state.documentAction(
                                        widget.driverId,
                                        item.id,
                                        'simulate',
                                      ),
                                child: const Text('Mô phỏng xử lý'),
                              ),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () => state.documentAction(
                                        widget.driverId,
                                        item.id,
                                        'review',
                                      ),
                                child: const Text('Duyệt demo'),
                              ),
                              TextButton(
                                onPressed: busy
                                    ? null
                                    : () => state.documentAction(
                                        widget.driverId,
                                        item.id,
                                        'delete',
                                      ),
                                child: const Text('Xóa tệp giả'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
