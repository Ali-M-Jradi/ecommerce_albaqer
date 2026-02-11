import 'package:flutter/material.dart';
import 'package:albaqer_gemstone_flutter/models/user.dart';
import 'package:albaqer_gemstone_flutter/services/user_service.dart';
import 'package:albaqer_gemstone_flutter/services/auth_service.dart';
import 'package:albaqer_gemstone_flutter/config/app_theme.dart';
import 'package:intl/intl.dart';

/// ========================================================================
/// ADMIN USERS MANAGEMENT SCREEN
/// ========================================================================
/// Display all users with ability to assign roles
/// Only visible to admin users

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  late Future<List<User>> _usersFuture;
  String _selectedFilter = 'all'; // all, user, manager, delivery_man, admin
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUsers();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = await _authService.getUserId();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _userService.fetchAllUsersAuthenticated();
    });
  }

  List<User> _filterUsers(List<User> users) {
    // Filter out the current logged-in user
    var filteredUsers = users
        .where((user) => user.id != _currentUserId)
        .toList();

    if (_selectedFilter == 'all') {
      return filteredUsers;
    }
    return filteredUsers.where((user) => user.role == _selectedFilter).toList();
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red[700]!;
      case 'manager':
        return Colors.purple[700]!;
      case 'delivery_man':
        return Colors.green[700]!;
      case 'user':
      default:
        return Colors.blue[700]!;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'manager':
        return Icons.manage_accounts;
      case 'delivery_man':
        return Icons.local_shipping;
      case 'user':
      default:
        return Icons.person;
    }
  }

  String _formatRole(String role) {
    if (role == 'delivery_man') {
      return 'Delivery';
    }
    if (role == 'user') {
      return 'User';
    }
    return role[0].toUpperCase() + role.substring(1);
  }

  Future<void> _changeUserRole(User user) async {
    final roles = ['user', 'manager', 'delivery_man', 'admin'];
    String? selectedRole = user.role;

    final confirmed = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Role to ${user.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Role: ${_formatRole(user.role)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRoleColor(user.role),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select New Role:'),
              const SizedBox(height: 8),
              ...roles.map((role) {
                return RadioListTile<String>(
                  title: Row(
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        color: _getRoleColor(role),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_formatRole(role)),
                    ],
                  ),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value;
                    });
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedRole != user.role
                  ? () => Navigator.pop(context, selectedRole)
                  : null,
              child: const Text('Assign Role'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != null && confirmed != user.role) {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final result = await _userService.assignRoleToUser(user.id!, confirmed);

      // Close loading indicator
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success']
                  ? 'Role updated successfully to ${_formatRole(confirmed)}'
                  : result['message'] ?? 'Failed to update role',
            ),
            backgroundColor: result['success'] ? Colors.green : Colors.red[700],
          ),
        );

        if (result['success']) {
          _loadUsers(); // Reload users list
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // ===========================================
          // FILTER CHIPS
          // ===========================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: AppColors.background,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Users', 'user'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Managers', 'manager'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delivery', 'delivery_man'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Admins', 'admin'),
                ],
              ),
            ),
          ),

          // ===========================================
          // USERS LIST
          // ===========================================
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final users = _filterUsers(snapshot.data ?? []);

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all'
                              ? 'No users found'
                              : 'No ${_formatRole(_selectedFilter).toLowerCase()}s found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadUsers();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _changeUserRole(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name and Role Badge
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                    child: Icon(
                      _getRoleIcon(user.role),
                      color: _getRoleColor(user.role),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatRole(user.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // User Details
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),

              // Phone
              if (user.phone != null && user.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        user.phone!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

              // Status
              Row(
                children: [
                  Icon(
                    user.isActive ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 14,
                      color: user.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (user.createdAt != null)
                    Text(
                      'Joined ${DateFormat('MMM d, yyyy').format(user.createdAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),

              // Change Role Button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _changeUserRole(user),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Change Role'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
