import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../seller/become_seller_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editingProfile = false;
  bool _editingPassword = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _oldPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl.text = user?.name ?? '';
    _emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _oldPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final ok = await context
        .read<AuthProvider>()
        .updateProfile(_nameCtrl.text.trim(), _emailCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _editingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePassword() async {
    if (_oldPwdCtrl.text.isEmpty || _newPwdCtrl.text.isEmpty) return;
    final ok = await context
        .read<AuthProvider>()
        .updatePassword(_oldPwdCtrl.text, _newPwdCtrl.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _editingPassword = false);
      _oldPwdCtrl.clear();
      _newPwdCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password updated!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundImage: user.avatar != null
                  ? NetworkImage(user.avatar!.url)
                  : null,
              child: user.avatar == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(user.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user.email, style: TextStyle(color: Colors.grey[600])),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFfa9c23).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFFfa9c23), fontWeight: FontWeight.w600),
              ),
            ),
            if (user.isShopkeeper) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shop Details',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      if (user.shopName != null) Text('Shop: ${user.shopName}'),
                      if (user.shopAddress != null)
                        Text('Address: ${user.shopAddress}'),
                      if (user.pinCode != null)
                        Text('PIN: ${user.pinCode}'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Edit Profile
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profile Information',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () =>
                              setState(() => _editingProfile = !_editingProfile),
                          child: Text(_editingProfile ? 'Cancel' : 'Edit'),
                        ),
                      ],
                    ),
                    if (_editingProfile) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Name', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      _infoRow('Name', user.name),
                      _infoRow('Email', user.email),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Change Password
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Change Password',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => setState(
                              () => _editingPassword = !_editingPassword),
                          child:
                              Text(_editingPassword ? 'Cancel' : 'Change'),
                        ),
                      ],
                    ),
                    if (_editingPassword) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _oldPwdCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Current Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPwdCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _savePassword,
                          child: const Text('Update Password'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (user.role == 'user') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.store_outlined),
                  label: const Text('Become a Seller'),
                  onPressed: () => Navigator.pushNamed(context, '/become-seller'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red)),
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 60,
              child: Text(label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Text(value),
        ],
      ),
    );
  }
}
