import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedAddress;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _newAddressController = TextEditingController();
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.addresses.isNotEmpty) {
      _selectedAddress = auth.addresses.first.fullDisplayAddress;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _newAddressController.dispose();
    super.dispose();
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Delivery Address'),
        content: TextField(
          controller: _newAddressController,
          decoration: const InputDecoration(
            hintText: 'Enter Flat, Building, Street, City...',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newAddressController.text.trim().isNotEmpty) {
                final addrText = _newAddressController.text.trim();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.addAddress(addrText);
                if (mounted) {
                  setState(() {
                    _selectedAddress = addrText;
                    _errorMessage = null;
                  });
                  _newAddressController.clear();
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (_selectedAddress == null || _selectedAddress!.isEmpty) {
      setState(() {
        _errorMessage = 'Add address then only you can proceed to pay.';
      });
      return;
    }

    final enteredAmount = double.tryParse(_amountController.text.trim());
    final targetAmount = double.parse(cart.grandTotal.toStringAsFixed(2));

    if (enteredAmount == null || (enteredAmount - targetAmount).abs() > 0.01) {
      setState(() {
        _errorMessage = 'Incorrect amount. Please enter exactly \$${targetAmount.toStringAsFixed(2)}';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final user = auth.user!;
      final placedOrder = await orderProvider.placeOrder(
        userId: user.id,
        items: cart.items,
        totalPrice: cart.grandTotal,
        address: _selectedAddress!,
      );

      cart.clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: placedOrder),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process order. Please try again.';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final etaTime = DateFormat('hh:mm a').format(DateTime.now().add(const Duration(minutes: 35)));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment & Delivery'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error banner
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Delivery Address Section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Delivery Address',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddAddressDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (auth.addresses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('No saved address. Tap "Add New" above to add your delivery address.'),
                      )
                    else
                      ...auth.addresses.map((addr) {
                        final fullAddr = addr.fullDisplayAddress;
                        return RadioListTile<String>(
                          value: fullAddr,
                          groupValue: _selectedAddress,
                          onChanged: (val) {
                            setState(() {
                              _selectedAddress = val;
                              _errorMessage = null;
                            });
                          },
                          title: Text(addr.address, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('${addr.city}, ${addr.pincode}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          activeColor: AppTheme.primaryColor,
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estimated Delivery Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled, color: AppTheme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Delivery Time',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '30 - 45 minutes (Arriving around $etaTime)',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount Confirmation Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Confirmation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount Payable', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          '\$${cart.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Enter exact amount to confirm',
                        hintText: cart.grandTotal.toStringAsFixed(2),
                        prefixText: '\$ ',
                        suffixIcon: TextButton(
                          onPressed: () {
                            _amountController.text = cart.grandTotal.toStringAsFixed(2);
                          },
                          child: const Text('Auto-fill'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handlePayment,
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text('Pay \$${cart.grandTotal.toStringAsFixed(2)} & Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SSL Badge
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Secure SSL Encrypted Payment',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
