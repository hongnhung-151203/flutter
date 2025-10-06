import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/room.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';

const _surfaceColor = Colors.white;
const _accentColor = Color(0xFF667eea);
const _warningColor = Color(0xFFFFB347);
const _dangerColor = Color(0xFFE57373);

String _normalizedStatusKey(String value) {
  const Map<String, String> diacritics = {
    '\u00e0': 'a',
    '\u00e1': 'a',
    '\u1ea3': 'a',
    '\u00e3': 'a',
    '\u1ea1': 'a',
    '\u0103': 'a',
    '\u1eaf': 'a',
    '\u1eb1': 'a',
    '\u1eb3': 'a',
    '\u1eb5': 'a',
    '\u1eb7': 'a',
    '\u00e2': 'a',
    '\u1ea5': 'a',
    '\u1ea7': 'a',
    '\u1ea9': 'a',
    '\u1eab': 'a',
    '\u1ead': 'a',
    '\u0111': 'd',
    '\u00e8': 'e',
    '\u00e9': 'e',
    '\u1ebb': 'e',
    '\u1ebd': 'e',
    '\u1eb9': 'e',
    '\u00ea': 'e',
    '\u1ebf': 'e',
    '\u1ec1': 'e',
    '\u1ec3': 'e',
    '\u1ec5': 'e',
    '\u1ec7': 'e',
    '\u00ec': 'i',
    '\u00ed': 'i',
    '\u1ec9': 'i',
    '\u0129': 'i',
    '\u1ecb': 'i',
    '\u00f2': 'o',
    '\u00f3': 'o',
    '\u1ecf': 'o',
    '\u00f5': 'o',
    '\u1ecd': 'o',
    '\u00f4': 'o',
    '\u1ed1': 'o',
    '\u1ed3': 'o',
    '\u1ed5': 'o',
    '\u1ed7': 'o',
    '\u1ed9': 'o',
    '\u01a1': 'o',
    '\u1edd': 'o',
    '\u1edf': 'o',
    '\u1ee1': 'o',
    '\u1ee3': 'o',
    '\u00f9': 'u',
    '\u00fa': 'u',
    '\u1ee7': 'u',
    '\u0169': 'u',
    '\u1ee5': 'u',
    '\u01b0': 'u',
    '\u1ee9': 'u',
    '\u1eeb': 'u',
    '\u1eed': 'u',
    '\u1eef': 'u',
    '\u1ef1': 'u',
    '\u1ef3': 'y',
    '\u00fd': 'y',
    '\u1ef7': 'y',
    '\u1ef9': 'y',
    '\u1ef5': 'y',
  };

  final buffer = StringBuffer();
  for (final codePoint in value.trim().toLowerCase().runes) {
    final character = String.fromCharCode(codePoint);
    buffer.write(diacritics[character] ?? character);
  }
  return buffer.toString();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _statusOptions = ['Trống', 'Có người', 'Bảo trì'];

  @override
  void initState() {
    super.initState();
    final provider = context.read<RoomProvider>();
    final authProvider = context.read<AuthProvider>();

    // Bootstrap room data
    Future.microtask(provider.bootstrap);

    // Refresh user data to ensure consistency
    Future.microtask(authProvider.refreshUsers);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final roomsProvider = context.watch<RoomProvider>();

    final rooms = roomsProvider.rooms.where((room) {
      if (auth.isLandlord) return true;
      if (auth.isTenant) {
        return room.id == auth.currentUser?.roomId;
      }
      return false;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/may.jpg'), // 🖼️ đường dẫn tới ảnh
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(context, auth, theme),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: roomsProvider.bootstrap,
                  displacement: 24,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryRow(context, roomsProvider.rooms, auth),
                        const SizedBox(height: 28),
                        const _SectionTitle(title: 'Danh sách phòng'),
                        const SizedBox(height: 12),

                        if (rooms.isEmpty)
                          _EmptyStateCard(isTenant: auth.isTenant)
                        else
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.9, // Điều chỉnh cho vừa ý
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: rooms.map((room) {
                              return SizedBox(
                                height:
                                    260, // 👈 Đảm bảo các card có cùng chiều cao
                                child: _RoomCard(
                                  room: room,
                                  landlordActions: auth.isLandlord
                                      ? LandlordActions(
                                          onEdit: () => _openRoomDialog(
                                            context,
                                            room: room,
                                          ),
                                          onDelete: () =>
                                              _confirmDelete(context, room),
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: auth.isLandlord
          ? FloatingActionButton.extended(
              backgroundColor: _accentColor,
              onPressed: () => _openRoomDialog(context),
              icon: const Icon(Icons.add_home_outlined, color: Colors.white),
              label: const Text(
                'Thêm phòng',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildCustomAppBar(
    BuildContext context,
    AuthProvider auth,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 2, 86, 164),
        border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            'Quản Lý Nhà Trọ IoT',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Firebase test',
            onPressed: () => Navigator.of(context).pushNamed('/firebase-test'),
            icon: const Icon(Icons.memory_outlined, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Người dùng',
            onPressed: auth.isLandlord
                ? () => Navigator.of(context).pushNamed('/management_users')
                : null,
            icon: Icon(
              Icons.people_alt_outlined,
              color: auth.isLandlord
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _UserSummaryCard(BuildContext context, AuthProvider auth) {
    final theme = Theme.of(context);
    final subtitle = auth.isLandlord ? 'Chủ Trọ' : 'Người thuê';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/nenmay.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color.fromARGB(
              255,
              0,
              0,
              0,
            ).withOpacity(0.2),
            child: Text(
              auth.currentUser?.name.substring(0, 1).toUpperCase() ?? '?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            auth.currentUser?.name ?? 'Khách',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    List<Room> rooms,
    AuthProvider auth,
  ) {
    final occupied = rooms.where((room) => room.isOccupied).length;
    final alerts = rooms
        .where((room) => room.gasAlert || room.motionDetected)
        .length;
    final total = rooms.length;
    final available = total - occupied;

    return Row(
      children: [
        // Ô "Bạn là chủ" hoặc "Người thuê"
        Expanded(flex: 2, child: _UserSummaryCard(context, auth)),

        // ✅ Thêm khoảng cách giữa user card và thống kê
        const SizedBox(width: 12),

        // 4 ô thống kê còn lại
        Expanded(
          flex: 8, // 2 + 2 + 2 + 2
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _StatisticCard(
                  title: 'Tổng phòng',
                  value: '$total',
                  color: Colors.cyan, // bạn có thể chỉnh lại màu theo ý thích
                  icon: Icons.meeting_room_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _StatisticCard(
                  title: 'Đang sử dụng',
                  value: '$occupied',
                  color: _accentColor,
                  icon: Icons.home_work_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _StatisticCard(
                  title: 'Còn trống',
                  value: '$available',
                  color: _warningColor,
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _StatisticCard(
                  title: 'Cần chú ý',
                  value: '$alerts',
                  color: _dangerColor,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Room room) async {
    final provider = context.read<RoomProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá phòng'),
        content: Text('Bạn có chắc muốn xoá ${room.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _dangerColor),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await provider.deleteRoom(room.id);
    }
  }

  Future<void> _openRoomDialog(BuildContext context, {Room? room}) async {
    final roomProvider = context.read<RoomProvider>();

    final nameController = TextEditingController(text: room?.name ?? '');
    final priceController = TextEditingController(text: room?.price ?? '');
    final occupantController = TextEditingController(
      text: room?.occupant ?? '',
    );

    String status = _initialStatus(room);
    int gasLevel = room?.gasLevel ?? 20;
    int humidity = room?.humidity ?? 50;
    bool lightOn = room?.lightOn ?? false;
    bool fanOn = room?.fanOn ?? false;
    bool gasAlert = room?.gasAlert ?? false;
    bool motionDetected = room?.motionDetected ?? false;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        room == null ? Icons.add_home : Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      room == null ? 'Thêm phòng mới' : 'Chỉnh sửa phòng',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C2534),
                      ),
                    ),
                  ],
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên phòng',
                          prefixIcon: Icon(Icons.meeting_room_outlined),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Nhập tên phòng'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: _statusOptions
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => status = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Giá thuê',
                          prefixIcon: Icon(Icons.price_change_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: occupantController,
                        decoration: const InputDecoration(
                          labelText: 'Người thuê',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SliderTile(
                        label: 'Gas',
                        value: gasLevel,
                        onChanged: (value) =>
                            setDialogState(() => gasLevel = value),
                      ),
                      const SizedBox(height: 12),
                      _SliderTile(
                        label: 'Độ ẩm',
                        value: humidity,
                        onChanged: (value) =>
                            setDialogState(() => humidity = value),
                      ),
                      const Divider(height: 24),
                      _SwitchTile(
                        label: 'Đèn',
                        value: lightOn,
                        onChanged: (value) =>
                            setDialogState(() => lightOn = value),
                      ),
                      _SwitchTile(
                        label: 'Quạt',
                        value: fanOn,
                        onChanged: (value) =>
                            setDialogState(() => fanOn = value),
                      ),
                      _SwitchTile(
                        label: 'Cảnh báo gas',
                        value: gasAlert,
                        onChanged: (value) =>
                            setDialogState(() => gasAlert = value),
                      ),
                      _SwitchTile(
                        label: 'Cảm biến chuyển động',
                        value: motionDetected,
                        onChanged: (value) =>
                            setDialogState(() => motionDetected = value),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Color(0xFF5C6774)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final newRoom = Room(
                        id: room?.id ?? '',
                        name: nameController.text.trim(),
                        status: status,
                        temperature: room?.temperature ?? '24C',
                        price: priceController.text.trim(),
                        occupant: occupantController.text.trim().isEmpty
                            ? null
                            : occupantController.text.trim(),
                        gasLevel: gasLevel,
                        humidity: humidity,
                        lightOn: lightOn,
                        fanOn: fanOn,
                        gasAlert: gasAlert,
                        motionDetected: motionDetected,
                        fanSpeed: room?.fanSpeed ?? 50,
                        temperatureValue: room?.temperatureValue ?? 24,
                        createdAt: room?.createdAt,
                        updatedAt: DateTime.now(),
                      );

                      if (room == null) {
                        await roomProvider.createRoom(newRoom);
                      } else {
                        await roomProvider.updateRoom(newRoom);
                      }

                      if (context.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      room == null ? 'Thêm' : 'Lưu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _initialStatus(Room? room) {
    final key = _normalizedStatusKey(room?.status ?? '');
    if (key.isEmpty) {
      return _statusOptions.first;
    }

    switch (key) {
      case 'trống':
        return 'Trống';
      case 'có người':
        return 'Có người';
      case 'bảo trì':
        return 'Bảo trì';
      default:
        return _statusOptions.first;
    }
  }
}

class LandlordActions {
  const LandlordActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C2534),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5C6774),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, this.landlordActions});

  final Room room;
  final LandlordActions? landlordActions;

  Color _statusColor() {
    switch (_normalizedStatusKey(room.status)) {
      case 'trong':
        return Colors.grey;
      case 'co nguoi':
        return Colors.green;
      case 'bao tri':
        return Colors.orange;
      default:
        return const Color(0xFF9AA4B2);
    }
  }

  Color _metricColorByValue(num value) {
    return value < 50 ? Colors.green : Colors.red;
  }

  Color _booleanMetricColor(bool active) {
    return active ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor();

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/room/${room.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: statusColor.withOpacity(0.1), width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.2),
                        statusColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_outlined,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2534),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Trạng thái: ${room.status}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4C5968),
                        ),
                      ),
                      if (room.occupant != null && room.occupant!.isNotEmpty)
                        Text(
                          'Người thuê: ${room.occupant!}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4C5968),
                          ),
                        ),
                      Text(
                        'Giá thuê: ${room.price}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4C5968),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room.status,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (landlordActions != null) ...[
                      const SizedBox(height: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') landlordActions!.onEdit();
                          if (value == 'delete') landlordActions!.onDelete();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Xoá')),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricChip(
                  icon: Icons.thermostat,
                  label: 'Nhiệt độ ${room.temperature}°C',
                  color: _metricColorByValue(
                    room.temperature is num
                        ? room.temperature as num
                        : num.tryParse(room.temperature.toString()) ?? 0,
                  ),
                ),
                _MetricChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Gas ${room.gasLevel}%',
                  color: _metricColorByValue(
                    room.gasLevel is num
                        ? room.gasLevel as num
                        : num.tryParse(room.gasLevel.toString()) ?? 0,
                  ),
                ),
                _MetricChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Độ ẩm ${room.humidity}%',
                  color: _metricColorByValue(
                    room.humidity is num
                        ? room.humidity as num
                        : num.tryParse(room.humidity.toString()) ?? 0,
                  ),
                ),
                _MetricChip(
                  icon: room.lightOn
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                  label: room.lightOn ? 'Đèn bật' : 'Đèn tắt',
                  color: _booleanMetricColor(room.lightOn),
                ),
                _MetricChip(
                  icon: Icons.sensors,
                  label: room.motionDetected
                      ? 'Phát hiện chuyển động'
                      : 'Không có chuyển động',
                  color: _booleanMetricColor(room.motionDetected),
                ),
                _MetricChip(
                  icon: Icons.warning_amber_rounded,
                  label: room.gasAlert ? 'Cảnh báo gas' : 'Gas an toàn',
                  color: _booleanMetricColor(room.gasAlert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.isTenant});

  final bool isTenant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: _accentColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accentColor.withOpacity(0.2),
                  _accentColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isTenant
                  ? Icons.meeting_room_outlined
                  : Icons.add_home_work_outlined,
              size: 32,
              color: _accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isTenant
                ? 'Bạn chưa được gán phòng. Vui lòng liên hệ chủ trọ.'
                : 'Chưa có phòng nào. Vui lòng thêm phòng mới.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF4C5968),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text('$value%', style: theme.textTheme.bodyMedium),
          ],
        ),
        Slider(
          min: 0,
          max: 100,
          divisions: 20,
          value: value.toDouble(),
          activeColor: _accentColor,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      activeColor: _accentColor,
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF4C5968);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E7ED)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: effectiveColor), // dùng màu dynamic
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor, // dùng màu dynamic
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
