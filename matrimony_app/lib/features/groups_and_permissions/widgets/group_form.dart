import 'package:flutter/material.dart';
import '../../../../core/repository.dart';
import '../models/group_model.dart';
import '../models/permission_model.dart';

class GroupForm extends StatefulWidget {
  final GroupModel? group;
  final bool isLoading;
  final Function(Map<String, dynamic> data) onSubmit;

  const GroupForm({
    super.key,
    this.group,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<GroupForm> createState() => GroupFormState();
}

class GroupFormState extends State<GroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<PermissionModel> _allPermissions = [];
  Set<int> _selectedPermissionIds = {};
  bool _isLoadingPermissions = true;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _selectedPermissionIds = widget.group!.permissions
          .map((p) => p.id)
          .toSet();
    } else {
      // Dummy data for debug mode (user rule)
      // _nameController.text = "New Group"; // Optional
    }
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    try {
      final permissions = await DataRepository.i.fetchAllPermissions();
      if (mounted) {
        setState(() {
          _allPermissions = permissions;
          _isLoadingPermissions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPermissions = false;
        });
        // Handle error visually if needed
      }
    }
  }

  // Dummy data method required by user rule
  void autoFillDummyData() {
    _nameController.text = "Test Group ${DateTime.now().millisecond}";
    if (_allPermissions.isNotEmpty) {
      _selectedPermissionIds = {_allPermissions.first.id};
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'name': _nameController.text,
        'permissions': _selectedPermissionIds.toList(),
      });
    }
  }

  /// Groups permissions by their modelName
  Map<String, List<PermissionModel>> get _groupedPermissions {
    final Map<String, List<PermissionModel>> groups = {};
    for (var perm in _allPermissions) {
      // Use modelName if available, fallback to contentType ID if empty (should not happen with new backend)
      final key = perm.modelName.isNotEmpty ? perm.modelName : "Other";
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(perm);
    }
    return groups;
  }

  void _toggleGroupSelection(List<PermissionModel> groupPerms, bool? value) {
    setState(() {
      if (value == true) {
        _selectedPermissionIds.addAll(groupPerms.map((p) => p.id));
      } else {
        _selectedPermissionIds.removeAll(groupPerms.map((p) => p.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedPermissions;
    final groupKeys = grouped.keys.toList()..sort();

    return Form(
      key: _formKey,
      child: Container(
        width: 1000,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a name";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Permissions Label
            const Text(
              "Permissions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Header for Table
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Model",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "All",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Add",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Change",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Delete",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "View",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Permissions List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: _isLoadingPermissions
                    ? const Center(child: CircularProgressIndicator())
                    : _allPermissions.isEmpty
                    ? const Center(child: Text("No permissions found"))
                    : ListView.separated(
                        padding: const EdgeInsets.all(0),
                        itemCount: groupKeys.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final groupName = groupKeys[index];
                          final perms = grouped[groupName]!;

                          // Categorize permissions by codename prefix
                          PermissionModel? addPerm;
                          PermissionModel? changePerm;
                          PermissionModel? deletePerm;
                          PermissionModel? viewPerm;

                          for (var p in perms) {
                            if (p.codename.startsWith('add_')) {
                              addPerm = p;
                            } else if (p.codename.startsWith('change_')) {
                              changePerm = p;
                            } else if (p.codename.startsWith('delete_')) {
                              deletePerm = p;
                            } else if (p.codename.startsWith('view_')) {
                              viewPerm = p;
                          }

                          final areAllSelected = perms.every(
                            (p) => _selectedPermissionIds.contains(p.id),
                          );

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                // Model Name
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    groupName.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // All Checkbox
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Checkbox(
                                      value: areAllSelected,
                                      onChanged: (val) =>
                                          _toggleGroupSelection(perms, val),
                                    ),
                                  ),
                                ),
                                // Add
                                Expanded(
                                  flex: 1,
                                  child: _buildPermissionCheckbox(addPerm),
                                ),
                                // Change
                                Expanded(
                                  flex: 1,
                                  child: _buildPermissionCheckbox(changePerm),
                                ),
                                // Delete
                                Expanded(
                                  flex: 1,
                                  child: _buildPermissionCheckbox(deletePerm),
                                ),
                                // View
                                Expanded(
                                  flex: 1,
                                  child: _buildPermissionCheckbox(viewPerm),
                                ),
                              ],
                            ),
                          );
                          }
                          return null;
                        }
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCheckbox(PermissionModel? perm) {
    if (perm == null) return const SizedBox.shrink();

    final isSelected = _selectedPermissionIds.contains(perm.id);
    return Align(
      alignment: Alignment.centerLeft,
      child: Checkbox(
        value: isSelected,
        onChanged: (val) {
          setState(() {
            if (val == true) {
              _selectedPermissionIds.add(perm.id);
            } else {
              _selectedPermissionIds.remove(perm.id);
            }
          });
        },
      ),
    );
  }
}
