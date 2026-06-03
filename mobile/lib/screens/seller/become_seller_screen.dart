import 'package:flutter/material.dart';
import '../../services/seller_service.dart';
import '../../services/api_service.dart';

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameCtrl = TextEditingController();
  final _shopAddressCtrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _shopAddressCtrl.dispose();
    _pinCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await SellerService.registerSeller(
        shopName: _shopNameCtrl.text.trim(),
        shopAddress: _shopAddressCtrl.text.trim(),
        pinCode: _pinCodeCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted! Admin will review and approve it.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiService.extractMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Seller')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.store_outlined, size: 64, color: Color(0xFFfa9c23)),
              const SizedBox(height: 12),
              const Text(
                'Start selling on CSH',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your shop details below. Our team will review your application.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _shopNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: Icon(Icons.storefront_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Shop name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopAddressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Shop Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Shop address is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinCodeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'PIN Code',
                  prefixIcon: Icon(Icons.pin_drop_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'PIN code is required';
                  if (v.length != 6) return 'Enter a valid 6-digit PIN code';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_loading ? 'Submitting...' : 'Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
