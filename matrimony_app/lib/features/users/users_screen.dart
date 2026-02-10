import 'package:flutter/material.dart';
import '../../../../core/repository.dart';
import '../../../../core/error_exception_handler.dart';
import '../../../../core/pagination_response.dart';
import '../../../../services/snackbar_utils.dart';
import '../../../../widgets/network_resource.dart';
import '../../../../widgets/error_widget_with_retry.dart';
import '../../../../widgets/management_app_bar.dart';
import '../../../../widgets/common_table_header.dart';
import '../../../../widgets/common_list_row.dart';
import '../../../../widgets/common_empty_state.dart';
import '../../../../widgets/common_dialog_frame.dart';
import '../groups_and_permissions/models/group_model.dart';
import 'models/user_model.dart';
import 'widgets/user_form.dart';

class UsersScreen extends StatefulWidget {
  static const String path = "/users";
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  Future<PaginationResponse<UserModel>>? _future;
  final TextEditingController _searchController = TextEditingController();

  int _page = 1;
  // ignore: prefer_final_fields
  int _pageSize = 10;

  final List<TableColumnHeader> _columns = [
    const TableColumnHeader(label: "ID", flex: 1),
    const TableColumnHeader(label: "Username", flex: 3),
    const TableColumnHeader(label: "Name", flex: 3),
    const TableColumnHeader(label: "Email", flex: 4),
    const TableColumnHeader(label: "Status", flex: 2),
    const TableColumnHeader(
      label: "Actions",
      width: 80,
      alignment: Alignment.center,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    setState(() {
      _future = DataRepository.i.fetchUsers(
        page: _page,
        pageSize: _pageSize,
        search: _searchController.text,
      );
    });
  }

  void _onSearchChanged() {
    _page = 1;
    _fetchUsers();
  }

  void _onAddUser() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        final formKey = GlobalKey<UserFormState>();
        return StatefulBuilder(
          builder: (context, setState) {
            return CommonDialogFrame(
              title: "Add User",
              actionLabel: "Create User",
              isLoading: isLoading,
              onCancel: () => Navigator.of(context).pop(),
              onAction: () {
                formKey.currentState?.submit();
              },
              child: UserForm(
                key: formKey,
                isLoading: isLoading,
                onSubmit: (data) async {
                  setState(() => isLoading = true);
                  try {
                    // Create dummy UserModel from data map for passing to create
                    // Or construct UserModel properly
                    final user = UserModel(
                      id: 0,
                      username: data['username'],
                      email: data['email'],
                      firstName: data['first_name'],
                      lastName: data['last_name'],
                      isActive: data['is_active'],
                      isStaff: data['is_staff'],
                      isSuperuser: data['is_superuser'],
                      groups: [], // IDs are in data['groups'] as List<int>
                      password: data['password'],
                    );

                    // We need to inject group IDs because UserModel only holds GroupModels
                    // But toRequestMap uses GroupModels -> map(x=>x.id).
                    // So we must populate groups with dummy GroupModels containing IDs.
                    final groupIds = data['groups'] as List<int>;
                    final userWithGroups = user.copyWith(
                      groups: groupIds
                          .map(
                            (id) =>
                                GroupModel(id: id, name: '', permissions: []),
                          )
                          .toList(),
                    );

                    await DataRepository.i.createUser(userWithGroups);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showSuccessMessage("User created successfully");
                      _fetchUsers();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showErrorMessage(handleError(e));
                      setState(() => isLoading = false);
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _onEditUser(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        final formKey = GlobalKey<UserFormState>();
        return StatefulBuilder(
          builder: (context, setState) {
            return CommonDialogFrame(
              title: "Edit User",
              actionLabel: "Save Changes",
              isLoading: isLoading,
              onCancel: () => Navigator.of(context).pop(),
              onAction: () {
                formKey.currentState?.submit();
              },
              child: UserForm(
                key: formKey,
                user: user,
                isLoading: isLoading,
                onSubmit: (data) async {
                  setState(() => isLoading = true);
                  try {
                    final groupIds = data['groups'] as List<int>;
                    final updatedUser = user.copyWith(
                      username: data['username'],
                      email: data['email'],
                      firstName: data['first_name'],
                      lastName: data['last_name'],
                      isActive: data['is_active'],
                      isStaff: data['is_staff'],
                      isSuperuser: data['is_superuser'],
                      password: data['password'],
                      groups: groupIds
                          .map(
                            (id) =>
                                GroupModel(id: id, name: '', permissions: []),
                          )
                          .toList(),
                    );

                    await DataRepository.i.updateUser(user.id, updatedUser);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showSuccessMessage("User updated successfully");
                      _fetchUsers();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showErrorMessage(handleError(e));
                      setState(() => isLoading = false);
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _onDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete ${user.username}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await DataRepository.i.deleteUser(user.id);
                showSuccessMessage("User deleted successfully");
                _fetchUsers();
              } catch (e) {
                showErrorMessage(handleError(e));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkResource<PaginationResponse<UserModel>>(
              _future,
              loading: ManagementAppBar(
                title: "Users Management",
                subtitle: "Loading...",
                searchController: _searchController,
                onSearch: _onSearchChanged,
                onRefresh: _fetchUsers,
                searchHint: "Search users...",
                onAdd: _onAddUser,
              ),
              error: (_) => ManagementAppBar(
                title: "Users Management",
                subtitle: "Error",
                searchController: _searchController,
                onSearch: _onSearchChanged,
                onRefresh: _fetchUsers,
                searchHint: "Search users...",
                onAdd: _onAddUser,
              ),
              success: (data) => ManagementAppBar(
                title: "Users Management",
                subtitle: "${data.count} users",
                searchController: _searchController,
                onSearch: _onSearchChanged,
                onRefresh: _fetchUsers,
                searchHint: "Search users...",
                onAdd: _onAddUser,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    NetworkResource<PaginationResponse<UserModel>>(
                      _future,
                      loading: CommonTableHeader(
                        columns: _columns,
                        onSelectAll: (_) {},
                      ),
                      error: (_) => CommonTableHeader(
                        columns: _columns,
                        onSelectAll: (_) {},
                      ),
                      success: (data) => CommonTableHeader(
                        columns: _columns,
                        allSelected: false,
                        onSelectAll: (_) {},
                      ),
                    ),
                    Expanded(
                      child: NetworkResource<PaginationResponse<UserModel>>(
                        _future,
                        loading: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0D9488),
                          ),
                        ),
                        error: (error) => ErrorWidgetWithRetry(
                          retry: _fetchUsers,
                          exception: error,
                        ),
                        success: (data) {
                          if (data.results.isEmpty) {
                            return CommonEmptyState(
                              message: "No users found",
                              subMessage: "Create a new user to get started",
                              onAction: _fetchUsers,
                              actionLabel: "Refresh",
                              icon: Icons.people_outline,
                            );
                          }

                          return ListView.builder(
                            itemCount: data.results.length,
                            itemBuilder: (context, index) {
                              final user = data.results[index];
                              return CommonListRow(
                                isSelected: false,
                                onSelected: (_) {},
                                children: [
                                  // ID
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "#${user.id}",
                                      style: const TextStyle(
                                        color: Color(0xFF374151),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // Username
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      user.username,
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Name
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName
                                          : "-",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  // Email
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      user.email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Status
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: user.isActive
                                                ? Colors.green[50]
                                                : Colors.red[50],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            user.isActive
                                                ? "Active"
                                                : "Inactive",
                                            style: TextStyle(
                                              color: user.isActive
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (user.isStaff) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.shield_outlined,
                                            size: 16,
                                            color: Colors.blue[700],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  SizedBox(
                                    width: 80,
                                    child: Center(
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Color(0xFF6B7280),
                                          size: 20,
                                        ),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _onEditUser(user);
                                          } else if (value == 'delete') {
                                            _onDeleteUser(user);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          if (!user.isSuperuser ||
                                              true) // Allow deleting even super, maybe handle self delete blocked by backend
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
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
