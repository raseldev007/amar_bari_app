import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/invoice_model.dart';
import '../../flats/data/flat_repository.dart';
import '../../tenants/data/lease_repository.dart';
import '../data/invoice_repository.dart';
import '../../../../core/theme/app_gradients.dart';

class AddInvoiceScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String flatId;

  const AddInvoiceScreen({super.key, required this.propertyId, required this.flatId});

  @override
  ConsumerState<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends ConsumerState<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _residentId;
  String? _leaseId;
  
  // Form Fields
  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 5));
  final Map<String, TextEditingController> _controllers = {};
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Fetch Flat
      final flat = await ref.read(flatRepositoryProvider).getFlat(widget.flatId);
      if (flat == null) throw 'Flat not found';

      // 2. Fetch Active Lease
      // We don't have a direct "getLeaseByFlat" in repository easily accessible maybe?
      // Let's check flat.currentLeaseId.
      final lease = await ref.read(leaseRepositoryProvider).getActiveLease(widget.flatId);
      if (lease == null) throw 'No active lease found for this flat';

      _residentId = lease.residentId;
      _leaseId = lease.id;

      // 3. Pre-fill Controllers
      _controllers['Rent'] = TextEditingController(text: flat.rentBase.toStringAsFixed(0));
      flat.utilities.forEach((key, value) {
        _controllers[key] = TextEditingController(text: value.toStringAsFixed(0));
      });
      
      _calculateTotal();
      
      if (mounted) setState(() => _isLoading = false);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  void _calculateTotal() {
    double total = 0;
    _controllers.forEach((_, controller) {
      total += double.tryParse(controller.text) ?? 0;
    });
    setState(() => _totalAmount = total);
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Invoice', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Billing Period'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Billing Month',
                      value: _selectedDate, // We use this for Month Key
                      onTap: () async {
                         // Simple date picker for now, ideally strictly month picker
                         final picked = await showDatePicker(
                           context: context, 
                           initialDate: _selectedDate, 
                           firstDate: DateTime(2020), 
                           lastDate: DateTime(2030)
                         );
                         if (picked != null) setState(() => _selectedDate = picked);
                      }
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Due Date',
                      value: _dueDate,
                      onTap: () async {
                         final picked = await showDatePicker(
                           context: context, 
                           initialDate: _dueDate, 
                           firstDate: DateTime.now(), 
                           lastDate: DateTime(2030)
                         );
                         if (picked != null) setState(() => _dueDate = picked);
                      }
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Charges Breakdown'),
              const SizedBox(height: 12),
              
              ..._controllers.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: e.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: e.key,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixText: '৳ ',
                  ),
                  onChanged: (_) => _calculateTotal(),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              )),
              
              // Add Item Button (Optional for MVP, maybe later)

              const Divider(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(
                    '৳${_totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2575FC)),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text('Create & Send Invoice', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
    );
  }

  Widget _buildDatePicker({required String label, required DateTime value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  label == 'Billing Month' ? DateFormat('MMMM yyyy').format(value) : DateFormat.yMMMd().format(value), 
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final items = _controllers.entries.map((e) => InvoiceItem(
        key: e.key,
        amount: double.parse(e.value.text),
      )).toList();

      final invoice = InvoiceModel(
        id: const Uuid().v4(),
        ownerId: '', // Should be fetched or passed? Repository might not strictly need it OR we get from user. 
        // We need auth user ID.
        // But wait, the repository doesn't auto-fill ownerId. We can get it from ref.read(authRepositoryProvider).currentUser.uid
        // OR better: Property ownerId. We passed propertyId.
        propertyId: widget.propertyId,
        flatId: widget.flatId,
        residentId: _residentId!,
        leaseId: _leaseId!,
        items: items,
        totalAmount: _totalAmount,
        monthKey: DateFormat('yyyy-MM').format(_selectedDate),
        dueDate: _dueDate,
        status: 'due',
        createdAt: DateTime.now(), // ownerId handled below via copyWith
      );

      // We need ownerId.
      final flat = await ref.read(flatRepositoryProvider).getFlat(widget.flatId);
      final ownerId = flat!.ownerId; // Flat has ownerId
      
      final finalInvoice = invoice.copyWith(ownerId: ownerId);

      await ref.read(invoiceRepositoryProvider).createInvoice(finalInvoice);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice Sent Successfully!')));
      }

    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
         setState(() => _isLoading = false);
       }
    }
  }
}
