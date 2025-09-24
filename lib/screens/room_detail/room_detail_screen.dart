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
      body: RefreshIndicator(
        onRefresh: _loadRoom,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(
                  room.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Trạng thái: ${room.status}'),
                    Text('Giá thuê: ${room.price}'),
                    Text('Nhiệt độ: ${room.temperature}'),
                    Text('Độ ẩm: ${room.humidity}%'),
                    Text('Gas: ${room.gasLevel}%'),
                    if (room.occupant != null && room.occupant!.isNotEmpty)
                      Text('Người thuê: ${room.occupant!}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thiết bị',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    _DeviceToggle(
                      title: 'Đèn',
                      value: room.lightOn,
                      enabled: landlord,
                      onChanged: (value) =>
                          _updateRoom(room.copyWith(lightOn: value)),
                    ),
                    _DeviceToggle(
                      title: 'Quạt',
                      value: room.fanOn,
                      enabled: landlord,
                      onChanged: (value) =>
                          _updateRoom(room.copyWith(fanOn: value)),
                    ),
                    _DeviceToggle(
                      title: 'Cảnh báo gas',
                      value: room.gasAlert,
                      enabled: landlord,
                      onChanged: (value) =>
                          _updateRoom(room.copyWith(gasAlert: value)),
                    ),
                    _DeviceToggle(
                      title: 'Cảm biến chuyển động',
                      value: room.motionDetected,
                      enabled: landlord,
                      onChanged: (value) =>
                          _updateRoom(room.copyWith(motionDetected: value)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cảm biến',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    _SensorRow(
                      label: 'Nhiệt độ',
                      value: '${room.temperatureValue} C',
                    ),
                    _SensorRow(label: 'Độ ẩm', value: '${room.humidity}%'),
                    _SensorRow(label: 'Gas', value: '${room.gasLevel}%'),
                    _SensorRow(
                      label: 'Trạng thái',
                      value: room.motionDetected
                          ? 'Đang có chuyển động'
                          : 'Không có chuyển động',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceToggle extends StatelessWidget {
  const _DeviceToggle({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
