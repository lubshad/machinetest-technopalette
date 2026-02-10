import 'package:flutter/material.dart';
import '../../../../core/repository.dart';
import '../../groups_and_permissions/models/group_model.dart';
import '../models/user_model.dart';

class UserForm extends StatefulWidget {
  final UserModel? user;
  final bool isLoading;
  final Function(Map<String, dynamic> data) onSubmit;

  const UserForm({
    super.key,
    this.user,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<UserForm> createState() => UserFormState();
}

class UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isActive = true;
  bool _isStaff = false;
  bool _isSuperuser = false;

  List<GroupModel> _allGroups = [];
  Set<int> _selectedGroupIds = {};
  bool _isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _firstNameController.text = widget.user!.firstName;
      _lastNameController.text = widget.user!.lastName;
      _emailController.text = widget.user!.email;
      _isActive = widget.user!.isActive;
      _isStaff = widget.user!.isStaff;
      _isSuperuser = widget.user!.isSuperuser;

      _selectedGroupIds = widget.user!.groups.map((g) => g.id).toSet();
    } else {
      // Defaults
      _isStaff = true;
    }
    _fetchGroups();
  }

  // Dummy data rule
  void autoFillDummyData() {
    final now = DateTime.now().millisecond;
    _usernameController.text = "user$now";
    _firstNameController.text = "Test";
    _lastNameController.text = "User $now";
    _emailController.text = "user$now@example.com";
    _passwordController.text = "Password123!";
    _isStaff = true;
    _isActive = true;
    if (_allGroups.isNotEmpty) {
      _selectedGroupIds = {_allGroups.first.id};
    }
    setState(() {});
  }

  Future<void> _fetchGroups() async {
    try {
      // Assuming we can fetch all groups or page 1 big size
      final response = await DataRepository.i.fetchGroups(
        page: 1,
        pageSize: 100,
      );
      if (mounted) {
        setState(() {
          _allGroups = response.results;
          _isLoadingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGroups = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'username': _usernameController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'is_active': _isActive,
        'is_staff': _isStaff,
        'is_superuser': _isSuperuser,
        'groups': _selectedGroupIds.toList(),
      };

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      widget.onSubmit(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Username & Email
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: First Name & Last Name
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password (only required for new users, or optional update)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.user == null
                      ? "Password"
                      : "New Password (Optional)",
                  border: const OutlineInputBorder(),
                  helperText: widget.user == null
                      ? "Required for new users"
                      : "Leave empty to keep current",
                ),
                validator: (value) {
                  if (widget.user == null && (value == null || value.isEmpty)) {
                    return "Password is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Flags
              const Text(
                "User Status",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text("Active"),
                subtitle: const Text("User can login"),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val!),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text("Staff Status"),
                subtitle: const Text("User can access admin site"),
                value: _isStaff,
                onChanged: (val) => setState(() => _isStaff = val!),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text("Superuser Status"),
                subtitle: const Text("User has all permissions"),
                value: _isSuperuser,
                onChanged: (val) => setState(() => _isSuperuser = val!),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              // Groups
              const Text(
                "Groups",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingGroups
                    ? const Center(child: CircularProgressIndicator())
                    : _allGroups.isEmpty
                    ? const Center(child: Text("No groups found"))
                    : ListView.builder(
                        itemCount: _allGroups.length,
                        itemBuilder: (context, index) {
                          final group = _allGroups[index];
                          final isSelected = _selectedGroupIds.contains(
                            group.id,
                          );

                          return CheckboxListTile(
                            title: Text(group.name),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedGroupIds.add(group.id);
                                } else {
                                  _selectedGroupIds.remove(group.id);
                                }
                              });
                            },
                            dense: true,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
