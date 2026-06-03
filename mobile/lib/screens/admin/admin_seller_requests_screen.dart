import 'package:flutter/material.dart';
import '../../services/seller_service.dart';
import '../../services/api_service.dart';

class AdminSellerRequestsScreen extends StatefulWidget {
  const AdminSellerRequestsScreen({super.key});

  @override
  State<AdminSellerRequestsScreen> createState() =>
      _AdminSellerRequestsScreenState();
}

class _AdminSellerRequestsScreenState
    extends State<AdminSellerRequestsScreen> {
  List<dynamic> _sellers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await SellerService.getSellerRequests();
      // Only show pending requests — approved ones are done
      if (mounted) {
        setState(() => _sellers = all
            .where((s) => (s['status'] ?? 'pending') == 'pending')
            .toList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.extractMessage(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Seller'),
        content: Text('Approve "$name" as a shopkeeper?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await SellerService.approveSeller(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller approved!'), backgroundColor: Colors.green),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.extractMessage(e)), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reject(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Request'),
        content: Text('Reject and delete "$name"\'s seller request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await SellerService.deleteSeller(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected'), backgroundColor: Colors.orange),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.extractMessage(e)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Requests'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sellers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No seller requests', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _sellers.length,
                    itemBuilder: (_, i) {
                      final s = _sellers[i];
                      final status = s['status'] ?? 'pending';
                      final isPending = status == 'pending';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? Colors.orange.withOpacity(0.15)
                                          : Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPending ? Colors.orange : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _row(Icons.email_outlined, s['email'] ?? ''),
                              _row(Icons.storefront_outlined, s['shopName'] ?? ''),
                              _row(Icons.location_on_outlined, s['shopAddress'] ?? ''),
                              _row(Icons.pin_drop_outlined, 'PIN: ${s['pinCode'] ?? ''}'),
                              if (isPending) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Approve'),
                                        onPressed: () => _approve(s['_id'], s['name'] ?? ''),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                        label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.red),
                                          minimumSize: const Size(0, 44),
                                        ),
                                        onPressed: () => _reject(s['_id'], s['name'] ?? ''),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
