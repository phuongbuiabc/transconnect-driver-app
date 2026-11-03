import 'package:flutter/material.dart';
import '../controllers/places_controller.dart';
import '../../models/transport_place.dart';
import '../../../../shared/widgets/map_actions.dart';

class PlacesScreen extends StatefulWidget {
  final PlacesController controller;
  final VoidCallback? onOpenAddresses;
  const PlacesScreen({
    super.key,
    required this.controller,
    this.onOpenAddresses,
  });
  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final query = TextEditingController();
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(changed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.search(widget.controller.query);
    });
    query.text = widget.controller.query;
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(changed);
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bạn muốn đến đâu?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tìm bến xe, điểm đón và điểm trả của VieGo.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: query,
          maxLength: 100,
          textInputAction: TextInputAction.search,
          onSubmitted: state.loading ? null : (value) => state.search(value),
          decoration: const InputDecoration(
            labelText: 'Tên hoặc địa chỉ',
            hintText: 'Ví dụ: Bến xe Miền Đông',
            prefixIcon: Icon(Icons.search),
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: state.loading
              ? null
              : () {
                  FocusScope.of(context).unfocus();
                  state.search(query.text);
                },
          icon: const Icon(Icons.search),
          label: const Text('Tìm địa điểm'),
        ),
        if (widget.onOpenAddresses != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onOpenAddresses,
              icon: const Icon(Icons.bookmark_outline),
              label: const Text('Địa chỉ đã lưu của tôi'),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                state.query.isEmpty ? 'Địa điểm VieGo' : 'Kết quả tìm kiếm',
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (!state.loading && state.error == null)
              Text('${state.total} địa điểm'),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Các địa điểm đang được VieGo công bố. Chọn một điểm để xem vị trí và chỉ đường.',
        ),
        const SizedBox(height: 16),
        if (state.loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.error != null) ...[
          Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => state.search(query.text),
              child: const Text('Thử lại'),
            ),
          ),
        ] else if (state.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Icon(Icons.travel_explore, size: 40),
                const SizedBox(height: 12),
                Text(
                  state.query.isEmpty
                      ? 'Chưa có địa điểm được công bố'
                      : 'Chưa tìm thấy địa điểm',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thử tên bến xe, khu vực hoặc một phần địa chỉ.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          for (final place in state.items) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              leading: const Icon(Icons.location_on_outlined),
              title: Text(place.name, style: theme.textTheme.titleMedium),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(place.address),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PlaceDetailScreen(place: place),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (state.totalPages > 1)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                children: [
                  IconButton(
                    tooltip: 'Trang trước',
                    onPressed: state.page > 1
                        ? () => state.search(
                            state.query,
                            pageNumber: state.page - 1,
                          )
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Trang ${state.page} / ${state.totalPages}'),
                  IconButton(
                    tooltip: 'Trang sau',
                    onPressed: state.page < state.totalPages
                        ? () => state.search(
                            state.query,
                            pageNumber: state.page + 1,
                          )
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class PlaceDetailScreen extends StatelessWidget {
  final TransportPlace place;
  const PlaceDetailScreen({super.key, required this.place});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chi tiết địa điểm')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                place.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(place.address, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              if (place.accessInstructions?.isNotEmpty == true) ...[
                Text(
                  'Hướng dẫn đến điểm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(place.accessInstructions!),
                const SizedBox(height: 24),
              ],
              if (place.hasCoordinates) ...[
                Text('Tọa độ', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(
                  '${place.latitude!.toStringAsFixed(7)}, ${place.longitude!.toStringAsFixed(7)}',
                ),
                const SizedBox(height: 24),
                MapActions(
                  latitude: place.latitude,
                  longitude: place.longitude,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ứng dụng bản đồ sẽ mở đúng tọa độ này. Đường đi do ứng dụng bản đồ cung cấp.',
                ),
              ] else
                const Text('Địa điểm này chưa có tọa độ để mở bản đồ.'),
            ],
          ),
        ),
      ),
    ),
  );
}
