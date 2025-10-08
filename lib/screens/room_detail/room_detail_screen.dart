import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/room.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  Room? _room;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    final provider = context.read<RoomProvider>();
    Room? cachedRoom;
    try {
      cachedRoom = provider.rooms.firstWhere(
        (room) => room.id == widget.roomId,
      );
    } catch (_) {
      cachedRoom = null;
    }

    if (cachedRoom != null) {
      setState(() {
        _room = cachedRoom;
        _loading = false;
      });
      return;
    }

    final fetched = await provider.fetchRoom(widget.roomId);
    if (!mounted) return;
    setState(() {
      _room = fetched;
      _loading = false;
    });
  }

  Future<void> _updateRoom(Room updated) async {
    await context.read<RoomProvider>().updateRoom(updated);
    if (!mounted) return;
    setState(() => _room = updated);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<RoomProvider>();
    Room? latest;
    try {
      latest = provider.rooms.firstWhere((room) => room.id == widget.roomId);
    } catch (_) {
      latest = null;
    }
    if (latest != null) {
      _room = latest;
    }

    final room = _room;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Phòng ${widget.roomId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Phòng ${widget.roomId}')),
        body: const Center(child: Text('Không tìm thấy phòng.')),
      );
    }

    final landlord = auth.isLandlord;
    final canView =
        landlord || (auth.isTenant && auth.currentUser?.roomId == room.id);

    if (!canView) {
      return Scaffold(
        appBar: AppBar(title: Text('Phòng ${widget.roomId}')),
        body: const Center(child: Text('Bạn không có quyền xem phòng này.')),
      );
    }

    final titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final labelStyle = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/nenmay.jpg', fit: BoxFit.cover),
          ),
          RefreshIndicator(
            onRefresh: _loadRoom,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- KHUNG 1 (Đã căn giữa và giới hạn chiều rộng) ---
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Trạng thái: ${room.status}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Giá thuê: ${room.price}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (room.occupant != null &&
                                    room.occupant!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Người thuê: ${room.occupant!}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: _StatusChip(status: room.status),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- KHUNG 2 & 3 ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // THIẾT BỊ
                          Expanded(
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Thiết bị', style: titleStyle),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    _DeviceRow(
                                      label: 'Đèn',
                                      valueWidget: Switch(
                                        value: room.lightOn,
                                        onChanged: landlord
                                            ? (v) => _updateRoom(
                                                room.copyWith(lightOn: v),
                                              )
                                            : null,
                                      ),
                                      labelStyle: labelStyle,
                                    ),
                                    _DeviceRow(
                                      label: 'Quạt',
                                      valueWidget: Switch(
                                        value: room.fanOn,
                                        onChanged: landlord
                                            ? (v) => _updateRoom(
                                                room.copyWith(fanOn: v),
                                              )
                                            : null,
                                      ),
                                      labelStyle: labelStyle,
                                    ),
                                    _DeviceRow(
                                      label: 'Cảnh báo gas',
                                      valueWidget: Switch(
                                        value: room.gasAlert,
                                        onChanged: landlord
                                            ? (v) => _updateRoom(
                                                room.copyWith(gasAlert: v),
                                              )
                                            : null,
                                      ),
                                      labelStyle: labelStyle,
                                    ),
                                    _DeviceRow(
                                      label: 'Cảm biến chuyển động',
                                      valueWidget: Switch(
                                        value: room.motionDetected,
                                        onChanged: landlord
                                            ? (v) => _updateRoom(
                                                room.copyWith(
                                                  motionDetected: v,
                                                ),
                                              )
                                            : null,
                                      ),
                                      labelStyle: labelStyle,
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // CẢM BIẾN
                          Expanded(
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cảm biến', style: titleStyle),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    _SensorRow(
                                      label: 'Nhiệt độ',
                                      value: '${room.temperatureValue}°C',
                                      labelStyle: labelStyle,
                                      valueStyle: valueStyle,
                                    ),
                                    _SensorRow(
                                      label: 'Độ ẩm',
                                      value: '${room.humidity}%',
                                      labelStyle: labelStyle,
                                      valueStyle: valueStyle,
                                    ),
                                    _SensorRow(
                                      label: 'Gas',
                                      value: '${room.gasLevel}%',
                                      labelStyle: labelStyle,
                                      valueStyle: valueStyle,
                                    ),
                                    _SensorRow(
                                      label: 'Trạng thái',
                                      value: room.motionDetected
                                          ? 'Đang có chuyển động'
                                          : 'Không có chuyển động',
                                      labelStyle: labelStyle,
                                      valueStyle: valueStyle,
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip trạng thái hiển thị đẹp hơn
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'có người':
        return Colors.green;
      case 'bảo trì':
        return Colors.orange;
      case 'trống':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.label,
    required this.valueWidget,
    required this.labelStyle,
  });

  final String label;
  final Widget valueWidget;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          valueWidget,
        ],
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: labelStyle)),
            const SizedBox(width: 8),
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.35,
                ),
                child: Text(
                  value,
                  style: valueStyle,
                  textAlign: TextAlign.right,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
