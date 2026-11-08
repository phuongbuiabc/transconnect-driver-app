import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/shared/format.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/widgets/status_pill.dart';
import '../../models/foundation_data.dart';
import '../controllers/foundation_controller.dart';

class OrganizationsScreen extends StatefulWidget {
  final FoundationController controller;
  final String? driverId;
  final bool approved;
  final VoidCallback onEnterCode;
  const OrganizationsScreen({
    super.key,
    required this.controller,
    required this.driverId,
    required this.approved,
    required this.onEnterCode,
  });
  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _PendingItem {
  final String id, organizationName, expiresAt;
  final bool byEmail;
  const _PendingItem(
    this.id,
    this.organizationName,
    this.expiresAt, {
    required this.byEmail,
  });
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  bool showAllHistory = false;

  FoundationController get state => widget.controller;

  Future<bool> confirm(String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(action),
            ),
          ],
        ),
      ) ==
      true;

  Future<void> accept(_PendingItem item) async {
    final id = widget.driverId;
    if (id == null) return;
    final ok = await confirm(
      'Nhận lời mời của ${item.organizationName}?',
      'Khi cộng tác, ${item.organizationName} xem được thông tin liên hệ và GPLX của bạn. Bạn có thể kết thúc cộng tác sau.',
      'Nhận lời mời',
    );
    if (ok) await state.acceptInvitation(id, item.id);
  }

  Future<void> end(Collaboration item) async {
    final id = widget.driverId;
    if (id == null) return;
    final ok = await confirm(
      'Kết thúc cộng tác với ${item.organizationName}?',
      '${item.organizationName} sẽ không còn xem được hồ sơ hiện tại của bạn. Muốn cộng tác lại, nhà xe cần gửi lời mời mới.',
      'Kết thúc',
    );
    if (ok) await state.end(id, item);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pending = [
      for (final i in state.invitations.where((i) => i.pendingAt(now)))
        _PendingItem(i.id, i.organizationName, i.expiresAt, byEmail: true),
      for (final c in state.collaborations.where((c) => c.pendingAt(now)))
        _PendingItem(c.id, c.organizationName, c.expiresAt, byEmail: false),
    ];
    final active = state.collaborations.where((c) => c.active).toList();
    final history = state.collaborations
        .where((c) => !c.active && !c.pendingAt(now))
        .toList();
    final shownHistory = showAllHistory ? history : history.take(5).toList();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final busy = state.busy || state.loading;

    Widget heading(String label, int count) => Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 4),
      child: Text(
        state.loading ? label : '$label ($count)',
        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
    Widget empty(String message) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
    );
    Widget subline(String value) => Text(
      value,
      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nhà xe',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Lời mời và các nhà xe bạn đang cộng tác.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        if (state.loading) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
        if (state.error != null) ...[
          const SizedBox(height: 16),
          Notice(state.error!, failure: true),
          if (widget.driverId != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: busy ? null : () => state.load(widget.driverId!),
                child: const Text('Thử lại'),
              ),
            ),
        ],
        if (!widget.approved) ...[
          const SizedBox(height: 16),
          const Notice(
            'Hồ sơ tài xế cần được duyệt trước khi bạn nhận lời mời của nhà xe.',
          ),
        ],
        heading('Lời mời đang chờ', pending.length),
        if (!state.loading && pending.isEmpty)
          empty('Chưa có lời mời nào đang chờ.'),
        for (final item in pending) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.organizationName),
            subtitle: subline(
              '${item.byEmail ? 'Mời qua email' : 'Nhà xe mời trực tiếp'} · hạn ${formatDate(item.expiresAt)}',
            ),
            trailing: FilledButton.tonal(
              style: FilledButton.styleFrom(minimumSize: const Size(72, 40)),
              onPressed: busy || !widget.approved ? null : () => accept(item),
              child: const Text('Nhận'),
            ),
          ),
          const Divider(height: 1),
        ],
        heading('Đang cộng tác', active.length),
        if (!state.loading && active.isEmpty)
          empty('Chưa cộng tác với nhà xe nào.'),
        for (final item in active) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.organizationName),
            subtitle: subline('Từ ${formatDate(item.acceptedAt)}'),
            trailing: TextButton(
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              onPressed: busy ? null : () => end(item),
              child: const Text('Kết thúc'),
            ),
          ),
          const Divider(height: 1),
        ],
        if (history.isNotEmpty) ...[
          heading('Lịch sử', history.length),
          for (final item in shownHistory) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.organizationName),
              subtitle: subline(
                item.endedAt != null
                    ? 'Kết thúc ${formatDate(item.endedAt)}'
                    : item.revokedAt != null
                    ? 'Lời mời bị thu hồi ${formatDate(item.revokedAt)}'
                    : 'Lời mời hết hạn ${formatDate(item.expiresAt)}',
              ),
              trailing: StatusPill(
                item.endedAt != null ? 'Đã kết thúc' : 'Không hiệu lực',
              ),
            ),
            const Divider(height: 1),
          ],
          if (history.length > 5)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    setState(() => showAllHistory = !showAllHistory),
                child: Text(
                  showAllHistory ? 'Thu gọn' : 'Xem tất cả ${history.length}',
                ),
              ),
            ),
        ],
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.onEnterCode,
            icon: const Icon(Icons.key_outlined, size: 18),
            label: const Text('Có mã lời mời trong email? Nhập mã'),
          ),
        ),
      ],
    );
  }
}
