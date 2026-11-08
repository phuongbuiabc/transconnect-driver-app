import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/shared/format.dart';
import 'package:transconnect_driver_app/shared/widgets/status_pill.dart';
import '../controllers/foundation_controller.dart';

class ReviewHistoryScreen extends StatelessWidget {
  final FoundationController controller;
  const ReviewHistoryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lịch sử xét duyệt')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final muted = Theme.of(context).colorScheme.onSurfaceVariant;
          if (controller.reviews.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                controller.loading
                    ? 'Đang tải…'
                    : 'Hồ sơ chưa có lượt xét duyệt nào.',
                style: TextStyle(color: muted),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: controller.reviews.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = controller.reviews[index];
              final (label, tone) = switch (item.status) {
                'Approved' => ('Đã duyệt', StatusTone.positive),
                'Rejected' => ('Từ chối', StatusTone.negative),
                'Pending' => ('Đã nộp', StatusTone.waiting),
                _ => (item.status, StatusTone.neutral),
              };
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formatDate(item.createdAt)),
                subtitle: (item.note ?? '').isEmpty
                    ? null
                    : Text(item.note!, style: TextStyle(color: muted)),
                trailing: StatusPill(label, tone: tone),
              );
            },
          );
        },
      ),
    ),
  );
}
