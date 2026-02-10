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
import 'models/group_model.dart';
import 'models/permission_model.dart';
import 'widgets/group_form.dart';

class GroupsAndPermissionsScreen extends StatefulWidget {
  static const String path = "/groups-and-permissions";
  const GroupsAndPermissionsScreen({super.key});

  @override
  State<GroupsAndPermissionsScreen> createState() =>
      _GroupsAndPermissionsScreenState();
}

class _GroupsAndPermissionsScreenState
    extends State<GroupsAndPermissionsScreen> {
  Future<PaginationResponse<GroupModel>>? _future;
  final TextEditingController _searchController = TextEditingController();

  int _page = 1;
  // ignore: prefer_final_fields
  int _pageSize = 10;
  final List<TableColumnHeader> _columns = [
    const TableColumnHeader(label: "ID", flex: 1),
    const TableColumnHeader(label: "Name", flex: 3),
    const TableColumnHeader(label: "Permissions", flex: 6),
    const TableColumnHeader(
      label: "Actions",
      width: 80,
      alignment: Alignment.center,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Ensure common data initialized if needed, though for groups maybe not critical
    // await CommonDataService.i.initialize();
    _fetchGroups();
  }

  void _fetchGroups() {
    setState(() {
      _future = DataRepository.i.fetchGroups(
        page: _page,
        pageSize: _pageSize,
        search: _searchController.text,
      );
    });
  }

  void _onSearchChanged() {
    _page = 1;
    _fetchGroups();
  }

  void _onAddGroup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        final formKey = GlobalKey<GroupFormState>();
        return StatefulBuilder(
          builder: (context, setState) {
            return CommonDialogFrame(
              width: 1000,
              title: "Add Group",
              actionLabel: "Create Group",
              isLoading: isLoading,
              onCancel: () => Navigator.of(context).pop(),
              onAction: () {
                formKey.currentState?.submit();
              },
              child: GroupForm(
                key: formKey,
                isLoading: isLoading,
                onSubmit: (data) async {
                  setState(() => isLoading = true);
                  try {
                    // Create group first
                    await DataRepository.i.createGroup(
                      GroupModel(
                        id: 0,
                        name: data['name'],
                        permissions:
                            [], // Model with IDs is handled inside toRequestMap if we used a modified model,
                        // BUT here GroupModel stores objects.
                      ).copyWith(
                        permissions: (data['permissions'] as List<int>)
                            .map(
                              (id) =>
                                  // Create simplified permission models just for ID
                                  _createDummyPermission(id),
                            )
                            .toList(),
                      ),
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showSuccessMessage("Group created successfully");
                      _fetchGroups();
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

  // Helper to create dummy permission for ID passing
  // Ideally we should have better model support
  // This requires importing PermissionModel
  // I'll add import above.

  void _onEditGroup(GroupModel group) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        final formKey = GlobalKey<GroupFormState>();
        return StatefulBuilder(
          builder: (context, setState) {
            return CommonDialogFrame(
              width: 1000,
              title: "Edit Group",
              actionLabel: "Save Changes",
              isLoading: isLoading,
              onCancel: () => Navigator.of(context).pop(),
              onAction: () {
                formKey.currentState?.submit();
              },
              child: GroupForm(
                key: formKey,
                group: group,
                isLoading: isLoading,
                onSubmit: (data) async {
                  setState(() => isLoading = true);
                  try {
                    final updatedGroup = group.copyWith(
                      name: data['name'],
                      permissions: (data['permissions'] as List<int>)
                          .map((id) => _createDummyPermission(id))
                          .toList(),
                    );

                    await DataRepository.i.updateGroup(group.id, updatedGroup);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      showSuccessMessage("Group updated successfully");
                      _fetchGroups();
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

  void _onDeleteGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Group"),
        content: Text("Are you sure you want to delete ${group.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await DataRepository.i.deleteGroup(group.id);
                showSuccessMessage("Group deleted successfully");
                _fetchGroups();
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
            NetworkResource<PaginationResponse<GroupModel>>(
              _future,
              loading: ManagementAppBar(
                title: "Groups & Permissions",
                subtitle: "Loading...",
                searchController: _searchController,
                onSearch: _onSearchChanged,
                onRefresh: _fetchGroups,
                searchHint: "Search groups...",
                onAdd: _onAddGroup,
              ),
              error: (_) => ManagementAppBar(
                title: "Groups & Permissions",
                subtitle: "Error",
                searchController: _searchController,
                onSearch: _onSearchChanged,
                onRefresh: _fetchGroups,
                searchHint: "Search groups...",
                onAdd: _onAddGroup,
              ),
              success: (data) => ManagementAppBar(
                title: "Groups & Permissions",
                subtitle: "${data.count} groups",
                searchController: _searchController,
                onSearch: _onSearchChanged,
                onRefresh: _fetchGroups,
                searchHint: "Search groups...",
                onAdd: _onAddGroup,
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
                    NetworkResource<PaginationResponse<GroupModel>>(
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
                        allSelected:
                            false, // Selection not implemented for bulk actions yet
                        onSelectAll: (_) {},
                      ),
                    ),
                    Expanded(
                      child: NetworkResource<PaginationResponse<GroupModel>>(
                        _future,
                        loading: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0D9488),
                          ),
                        ),
                        error: (error) => ErrorWidgetWithRetry(
                          retry: _fetchGroups,
                          exception: error,
                        ),
                        success: (data) {
                          if (data.results.isEmpty) {
                            return CommonEmptyState(
                              message: "No groups found",
                              subMessage: "Create a new group to get started",
                              onAction: _fetchGroups,
                              actionLabel: "Refresh",
                              icon: Icons.security,
                            );
                          }

                          return ListView.builder(
                            itemCount: data.results.length,
                            itemBuilder: (context, index) {
                              final group = data.results[index];
                              return CommonListRow(
                                isSelected: false,
                                onSelected: (_) {},
                                children: [
                                  // ID
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "#${group.id}",
                                      style: const TextStyle(
                                        color: Color(0xFF374151),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // Name
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      group.name,
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Permissions
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      group.permissions.isEmpty
                                          ? "No permissions"
                                          : "${group.permissions.length} permissions", // Show count or trunc list
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
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
                                            _onEditGroup(group);
                                          } else if (value == 'delete') {
                                            _onDeleteGroup(group);
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

// Dummy permission creator helper needs to be outside or static
PermissionModel _createDummyPermission(int id) {
  return PermissionModel(
    id: id,
    name: '',
    contentType: 0,
    codename: '',
    modelName: '',
  );
}
