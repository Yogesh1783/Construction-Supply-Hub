import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  String _paymentMethod = 'COD';
  bool _placing = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final cart = context.read<CartProvider>();
    final shippingInfo = ShippingInfo(
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      phoneNo: _phoneCtrl.text.trim(),
      zipCode: _zipCtrl.text.trim(),
      country: 'India',
    );

    // Group items by shopkeeper
    final shopkeeperId = cart.items.isNotEmpty
        ? cart.items.first.shopkeeperId
        : '';

    final orderData = {
      'shippingInfo': shippingInfo.toJson(),
      'shopKeeperId': shopkeeperId,
      'orderItems': cart.items
          .map((i) => {
                'name': i.name,
                'quantity': i.quantity,
                'image': i.image,
                'price': i.price,
                'product': i.productId,
              })
          .toList(),
      'paymentMethod': _paymentMethod,
      'paymentInfo': {'id': 'COD_${DateTime.now().millisecondsSinceEpoch}', 'status': 'Not Paid'},
      'itemsPrice': cart.subtotal,
      'taxAmount': cart.taxAmount,
      'shippingAmount': cart.shippingAmount,
      'totalAmount': cart.totalAmount,
    };

    try {
      await OrderService.createOrder(orderData);
      cart.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/my-orders');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shipping Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                    labelText: 'Address', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Address required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                    labelText: 'City', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'City required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Phone required';
                  if (v.length < 10) return 'Enter valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _zipCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'ZIP / PIN Code', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'ZIP code required' : null,
              ),
              const SizedBox(height: 20),
              const Text('Payment Method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('Cash on Delivery (COD)'),
                value: 'COD',
                groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              RadioListTile<String>(
                title: const Text('QR Code / UPI'),
                value: 'QR',
                groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('${item.name} x${item.quantity}')),
                        Text(
                            '₹${(item.price * item.quantity).toStringAsFixed(0)}'),
                      ],
                    ),
                  )),
              const Divider(),
              _summaryRow('Subtotal', cart.subtotal),
              _summaryRow('Tax (18%)', cart.taxAmount),
              _summaryRow('Shipping', cart.shippingAmount),
              const Divider(),
              _summaryRow('Total', cart.totalAmount, bold: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  child: _placing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Place Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
          Text('₹${value.toStringAsFixed(0)}',
              style: bold
                  ? const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFFfa9c23))
                  : null),
        ],
      ),
    );
  }
}
