import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:transconnect_driver_app/features/driver_profile/presentation/controllers/driver_profile_controller.dart';
import 'package:transconnect_driver_app/features/foundation/presentation/controllers/foundation_controller.dart';
import 'package:transconnect_driver_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:transconnect_driver_app/features/driver_profile/presentation/widgets/driver_profile_form.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';
import 'package:transconnect_driver_app/shared/widgets/status_pill.dart';

class HomeScreen extends StatelessWidget {
  final AuthController api;
  final DriverProfileController profiles;
  final FoundationController foundation;
  final VoidCallback onOpenOrganizations;
  final VoidCallback onEnterCode;
  final Future<void> Function() onChanged;
  const HomeScreen({
    super.key,
    required this.api,
    required this.profiles,
    required this.foundation,
    required this.onOpenOrganizations,
    required this.onEnterCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final driver = profiles.profile;
    final now = DateTime.now();
    final pending =
        foundation.invitations.where((i) => i.pendingAt(now)).length +
        foundation.collaborations.where((c) => c.pendingAt(now)).length;
    final active = foundation.collaborations.where((c) => c.active).length;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          api.user?.fullName ?? 'Tài xế',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          api.user?.email ?? '',
          style: text.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        if (!api.verified)
          EmailVerificationScreen(api: api)
        else
          _NextStep(
            api: api,
            profiles: profiles,
            pending: pending,
            active: active,
            onOpenOrganizations: onOpenOrganizations,
            onEnterCode: onEnterCode,
            onChanged: onChanged,
          ),
        const SizedBox(height: 24),
        _Progress(
          verified: api.verified,
          approved: driver?.isApproved == true,
          collaborating: active > 0,
        ),
        if (driver?.isApproved == true) ...[
          const SizedBox(height: 24),
          if (foundation.error != null)
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chưa tải được danh sách nhà xe: ${foundation.error}'),
                  TextButton(
                    onPressed: foundation.loading
                        ? null
                        : () => foundation.load(driver!.id),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          else
            _Summary(
              loading: foundation.loading,
              pending: pending,
              active: active,
              onOpen: onOpenOrganizations,
            ),
        ],
      ],
    );
  }
}

class _NextStep extends StatelessWidget {
  final AuthController api;
  final DriverProfileController profiles;
  final int pending, active;
  final VoidCallback onOpenOrganizations, onEnterCode;
  final Future<void> Function() onChanged;
  const _NextStep({
    required this.api,
    required this.profiles,
    required this.pending,
    required this.active,
    required this.onOpenOrganizations,
    required this.onEnterCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final driver = profiles.profile;
    final status = driver?.reviewStatus;
    final (pill, tone, title, body) = switch (status) {
      null => (
        'Chưa có hồ sơ',
        StatusTone.neutral,
        'Gửi hồ sơ tài xế',
        'Nền tảng xét duyệt hồ sơ trước khi nhà xe có thể mời bạn cộng tác.',
      ),
      'Pending' => (
        'Chờ xét duyệt',
        StatusTone.waiting,
        'Hồ sơ đang chờ xét duyệt',
        'Hồ sơ của ${driver!.fullName} đã được gửi. Kéo xuống để cập nhật kết quả.',
      ),
      'Rejected' => (
        'Chưa được duyệt',
        StatusTone.negative,
        'Sửa và gửi lại hồ sơ',
        'Xem ghi chú xét duyệt bên dưới, sửa thông tin rồi gửi lại.',
      ),
      'Approved' when active > 0 => (
        'Đã duyệt',
        StatusTone.positive,
        'Đang cộng tác với $active nhà xe',
        'Lịch chạy và chuyến được phân công sẽ hiện ở đây khi chức năng chuyến được mở.',
      ),
      'Approved' when pending > 0 => (
        'Đã duyệt',
        StatusTone.positive,
        'Bạn có $pending lời mời đang chờ',
        'Nhận lời mời để bắt đầu cộng tác với nhà xe.',
      ),
      'Approved' => (
        'Đã duyệt',
        StatusTone.positive,
        'Chờ nhà xe gửi lời mời',
        'Nhà xe mời bạn qua email ${api.user?.email ?? ''}. Lời mời sẽ hiện ở mục Nhà xe.',
      ),
      _ => (
        status,
        StatusTone.neutral,
        'Trạng thái hồ sơ: $status',
        'Liên hệ quản trị nền tảng nếu trạng thái này không thay đổi.',
      ),
    };
    final note = driver?.reviewNote;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: StatusPill(pill, tone: tone),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(height: 1.5)),
          if (status == 'Rejected' && (note ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            Notice('Ghi chú xét duyệt: $note', failure: true),
          ],
          if (status == null || status == 'Rejected') ...[
            const SizedBox(height: 20),
            DriverProfileForm(
              api: profiles,
              fullName: api.user?.fullName ?? '',
              onSubmitted: onChanged,
            ),
          ],
          if (status == 'Approved' && active == 0) ...[
            const SizedBox(height: 20),
            if (pending > 0)
              FilledButton(
                onPressed: onOpenOrganizations,
                child: const Text('Xem lời mời'),
              )
            else
              OutlinedButton(
                onPressed: onEnterCode,
                child: const Text('Nhập mã lời mời từ email'),
              ),
          ],
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final bool verified, approved, collaborating;
  const _Progress({
    required this.verified,
    required this.approved,
    required this.collaborating,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget row(String label, bool done) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: done ? const Color(0xFF1E7A43) : scheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: done ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các bước tham gia',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        row('Xác thực email', verified),
        row('Hồ sơ tài xế được duyệt', approved),
        row('Cộng tác với ít nhất một nhà xe', collaborating),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final bool loading;
  final int pending, active;
  final VoidCallback onOpen;
  const _Summary({
    required this.loading,
    required this.pending,
    required this.active,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    Widget row(String label, int value) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loading ? '—' : '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onOpen,
    );
    return Column(
      children: [
        row('Lời mời đang chờ', pending),
        const Divider(height: 1),
        row('Nhà xe đang cộng tác', active),
      ],
    );
  }
}
