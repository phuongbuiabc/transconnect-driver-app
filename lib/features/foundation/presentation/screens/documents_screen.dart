import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/widgets/status_pill.dart';
import '../controllers/foundation_controller.dart';

class DocumentsScreen extends StatefulWidget {
  final FoundationController controller;
  final String driverId;
  const DocumentsScreen({
    super.key,
    required this.controller,
    required this.driverId,
  });
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool confirmed = false, picking = false;
  String? localError;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(changed);
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(changed);
    super.dispose();
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
          title: const Text('Ảnh GPLX demo'),
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
  Widget build(BuildContext context) {
    final state = widget.controller;
    final busy = state.busy || picking;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(title: const Text('Giấy phép lái xe')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Notice(
                  'Bản demo: chỉ tải ảnh chứa dữ liệu giả. Xử lý và duyệt là mô phỏng, giấy tờ luôn ở trạng thái chưa xác minh.',
                ),
                if (state.error != null || localError != null) ...[
                  const SizedBox(height: 12),
                  Notice(localError ?? state.error!, failure: true),
                ],
                if (state.documentError != null) ...[
                  const SizedBox(height: 12),
                  Notice(state.documentError!),
                ],
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: confirmed,
                  onChanged: busy
                      ? null
                      : (value) => setState(() => confirmed = value ?? false),
                  title: const Text('Tôi xác nhận ảnh chỉ chứa dữ liệu giả.'),
                ),
                OutlinedButton.icon(
                  onPressed: busy || !confirmed ? null : upload,
                  icon: const Icon(Icons.upload_outlined),
                  label: Text(picking ? 'Đang tải lên…' : 'Tải phiên bản mới'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Các phiên bản',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.documents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Chưa tải phiên bản nào.',
                      style: TextStyle(color: muted),
                    ),
                  ),
                for (final item in state.documents) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Phiên bản ${item.version}'),
                    subtitle: Text(
                      'Trạng thái tệp: ${item.status}',
                      style: TextStyle(color: muted),
                    ),
                    trailing: const StatusPill('Chưa xác minh'),
                  ),
                  Wrap(
                    spacing: 4,
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
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: busy
                            ? null
                            : () => state.documentAction(
                                widget.driverId,
                                item.id,
                                'delete',
                              ),
                        child: const Text('Xóa tệp'),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
