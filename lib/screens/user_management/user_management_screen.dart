import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ Hàm chia danh sách user thành nhóm 2 người
  List<List<UserProfile>> chunkUsers(List<UserProfile> users, int chunkSize) {
    final chunks = <List<UserProfile>>[];
    for (var i = 0; i < users.length; i += chunkSize) {
      final end = (i + chunkSize < users.length) ? i + chunkSize : users.length;
      chunks.add(users.sublist(i, end));
    }
    return chunks;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Refresh user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          2,
          86,
          164,
        ), // 💙 Màu nền theo yêu cầu
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Làm đậm chữ
            fontSize: 18,
            color: Color.fromARGB(
              255,
              236,
              235,
              235,
            ), // 👈 Cho chữ trắng để nổi bật trên nền xanh
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color.fromARGB(
            255,
            87,
            242,
            136,
          ), // Màu xanh cho tab được chọn
          unselectedLabelColor: Colors.grey, // Màu xám cho tab không chọn
          indicatorColor: Color.fromARGB(255, 87, 242, 136),
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Tất cả'),
            Tab(icon: Icon(Icons.meeting_room), text: 'Đã có phòng'),
            Tab(icon: Icon(Icons.person_add), text: 'Chưa có phòng'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ), // 👈 icon trắng
            onPressed: () {
              context.read<AuthProvider>().refreshUsers();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),

      body: Stack(
        children: [
          // 👉 Hình nền phía sau
          Positioned.fill(
            child: Image.asset(
              'assets/nenmay.jpg',
              fit: BoxFit.cover, // hoặc BoxFit.fill nếu muốn full
            ),
          ),

          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!authProvider.isAuthenticated || !authProvider.isLandlord) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Chức năng này chỉ dành cho chủ trọ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // Gộp Status Card và Current User Card trên cùng một hàng
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Khung 1 - Status Card
                        Expanded(
                          flex: 5,
                          child: _buildUserCard(
                            authProvider.currentUser!,
                            authProvider,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Khung 2 - Current User Card
                        Expanded(
                          flex: 5,
                          child: _buildStatusCard(authProvider),
                        ),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllUsersTab(authProvider),
                        _buildAssignedUsersTab(authProvider),
                        _buildUnassignedUsersTab(authProvider),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: authProvider.isOnline
              ? [Colors.green[50]!, Colors.green[100]!]
              : [Colors.orange[50]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: authProvider.isOnline
              ? Colors.green[200]!
              : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            authProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: authProvider.isOnline
                ? Colors.green[700]
                : Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.isOnline ? 'Kết nối Firebase' : 'Dữ liệu cục bộ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: authProvider.isOnline
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
                Text(
                  '${authProvider.users.length} người dùng • ${authProvider.getAssignedTenants().length} đã có phòng • ${authProvider.getUnassignedTenants().length} chưa có phòng',
                  style: TextStyle(
                    color: authProvider.isOnline
                        ? Colors.green[600]
                        : Colors.orange[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab(AuthProvider authProvider) {
    final seenIds = <String>{};
    final currentUserId = authProvider.currentUser?.id;

    final filteredUsers = authProvider.users.where((user) {
      if (user.id == currentUserId) return false;
      if (seenIds.contains(user.id)) return false;
      seenIds.add(user.id);
      return true;
    }).toList();

    final userChunks = chunkUsers(filteredUsers, 2); // chia mỗi hàng 2 người

    return filteredUsers.isEmpty
        ? const Center(
            child: Text(
              'Chưa có người dùng nào',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: userChunks.length,
            itemBuilder: (context, index) {
              final chunk = userChunks[index];
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildUserCard(chunk[0], authProvider),
                  ),
                  const SizedBox(width: 12),
                  if (chunk.length > 1)
                    Expanded(
                      flex: 5,
                      child: _buildUserCard(chunk[1], authProvider),
                    )
                  else
                    const Spacer(
                      flex: 5,
                    ), // để cân layout nếu chỉ có 1 thẻ cuối
                ],
              );
            },
          );
  }

  Widget _buildAssignedUsersTab(AuthProvider authProvider) {
    final assignedTenants = authProvider.getAssignedTenants();
    final userChunks = chunkUsers(assignedTenants, 2);

    return assignedTenants.isEmpty
        ? const Center(
            child: Text(
              'Chưa có người thuê nào được gán phòng',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: userChunks.length,
            itemBuilder: (context, index) {
              final chunk = userChunks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildUserCard(chunk[0], authProvider),
                    ),
                    const SizedBox(width: 12),
                    if (chunk.length > 1)
                      Expanded(
                        flex: 5,
                        child: _buildUserCard(chunk[1], authProvider),
                      )
                    else
                      const Spacer(flex: 5),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildUnassignedUsersTab(AuthProvider authProvider) {
    final unassignedTenants = authProvider.getUnassignedTenants();
    final userChunks = chunkUsers(unassignedTenants, 2);

    return unassignedTenants.isEmpty
        ? const Center(
            child: Text(
              'Tất cả người thuê đã có phòng',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: userChunks.length,
            itemBuilder: (context, index) {
              final chunk = userChunks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildUserCard(
                        chunk[0],
                        authProvider,
                        showRoomAssignment: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (chunk.length > 1)
                      Expanded(
                        flex: 5,
                        child: _buildUserCard(
                          chunk[1],
                          authProvider,
                          showRoomAssignment: true,
                        ),
                      )
                    else
                      const Spacer(flex: 5),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildUserCard(
    UserProfile user,
    AuthProvider authProvider, {
    bool showRoomAssignment = false,
  }) {
    final isCurrentUser = authProvider.currentUser?.id == user.id;
    final roleColor = user.role == UserRole.landlord
        ? Colors.blue
        : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? BorderSide(color: roleColor[300]!, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor[100],
                  child: Icon(
                    user.role == UserRole.landlord
                        ? Icons.admin_panel_settings
                        : Icons.person,
                    color: roleColor[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: roleColor[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Bạn',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: roleColor[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ SỬA TẠI ĐÂY: dùng Wrap thay vì Row + Expanded
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildInfoChip(
                  icon: Icons.shield_outlined,
                  label: user.role == UserRole.landlord
                      ? 'Chủ trọ'
                      : 'Người thuê',
                  color: roleColor,
                ),
                if (user.roomId != null)
                  _buildInfoChip(
                    icon: Icons.meeting_room,
                    label: 'Phòng ${user.roomId}',
                    color: Colors.purple,
                  ),
                _buildInfoChip(
                  icon: Icons.circle,
                  label: user.status == 'active' ? 'Hoạt động' : 'Bị khóa',
                  color: user.status == 'active' ? Colors.green : Colors.red,
                ),
              ],
            ),

            if (user.createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tạo lúc: ${_formatDate(user.createdAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],

            if (showRoomAssignment &&
                user.role == UserRole.tenant &&
                (user.roomId == null || user.roomId!.isEmpty)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showRoomAssignmentDialog(user, authProvider),
                  icon: const Icon(Icons.meeting_room_outlined),
                  label: const Text('Gán phòng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blue[200]!),
                    ),
                  ),
                ),
              ),
            ],
            if (authProvider.isLandlord &&
                user.role == UserRole.tenant &&
                user.roomId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUnassignRoomDialog(user, authProvider),
                  icon: const Icon(Icons.meeting_room_outlined),
                  label: Text('Bỏ gán Phòng ${user.roomId}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[50],
                    foregroundColor: Colors.orange[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.orange[200]!),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color[700]),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRoomAssignmentDialog(UserProfile user, AuthProvider authProvider) {
    final roomController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.meeting_room, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gán phòng cho ${user.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email: ${user.email}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nhập số Phòng :',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: roomController,
                  decoration: InputDecoration(
                    prefixText: 'Phòng ',
                    hintText: 'Ví dụ: 101, 102 ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.meeting_room_outlined),
                    suffixIcon: roomController.text.isNotEmpty
                        ? Icon(Icons.check_circle, color: Colors.green[600])
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số phòng';
                    }
                    final trimmed = value.trim();
                    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
                      return 'Vui lòng chỉ nhập số phòng (vd: 101)';
                    }
                    return null;
                  },
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {}); // cập nhật suffixIcon
                  },
                  onFieldSubmitted: (value) {
                    if (formKey.currentState!.validate()) {
                      final roomId = value.trim();
                      _assignRoom(user, roomId, authProvider);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Phòng sẽ được tạo tự động nếu chưa tồn tại',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final roomId = roomController.text.trim();
                _assignRoom(user, roomId, authProvider);
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Gán phòng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _assignRoom(
    UserProfile user,
    String roomId,
    AuthProvider authProvider,
  ) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('Đang gán phòng $roomId cho ${user.name}...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Assign room
      final success = await authProvider.assignRoomToUser(user.id, roomId);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ Gán phòng $roomId cho ${user.name} thành công!',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Xem trang chủ',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                },
              ),
            ),
          );

          // Additional success feedback
          if (kDebugMode) {
            debugPrint(
              'UserManagement: Room assignment successful for ${user.name}',
            );
          }
        } else {
          // Show error from auth provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage ?? 'Lỗi không xác định',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi gán phòng: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showUnassignRoomDialog(UserProfile user, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.remove_circle_outline, color: Colors.orange[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Bỏ gán phòng', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc muốn bỏ gán ${user.roomId} khỏi người dùng này?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 20,
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${user.roomId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Người dùng sẽ không còn được gán phòng nào sau thao tác này.',
                      style: TextStyle(color: Colors.orange[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _unassignRoom(user, authProvider);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('Bỏ gán phòng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _unassignRoom(UserProfile user, AuthProvider authProvider) async {
    try {
      final roomId = user.roomId;

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('Đang bỏ gán phòng $roomId khỏi ${user.name}...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Unassign room (set roomId to null)
      final success = await authProvider.assignRoomToUser(user.id, null);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (success) {
          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ Đã bỏ gán phòng $roomId khỏi ${user.name} thành công!',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );

          if (kDebugMode) {
            debugPrint(
              'UserManagement: Room unassignment successful for ${user.name}',
            );
          }
        } else {
          // Show error from auth provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage ?? 'Lỗi không xác định',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi bỏ gán phòng: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
