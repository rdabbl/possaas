import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/cart_item.dart';
import '../../../../core/models/customer.dart';

class CartSummary extends StatefulWidget {
  const CartSummary({
    super.key,
    required this.items,
    required this.customers,
    required this.selectedCustomer,
    required this.onCustomerChanged,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onDiscountChanged,
    required this.onShippingChanged,
    required this.onCheckout,
    required this.isProcessing,
    required this.noteController,
    required this.subTotal,
    required this.taxTotal,
    required this.shipping,
    required this.discount,
    required this.grandTotal,
    required this.currencySymbol,
    required this.errorMessage,
    required this.successMessage,
    required this.onClearMessages,
  });

  final List<CartItem> items;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer?> onCustomerChanged;
  final void Function(String cartItemId) onRemove;
  final void Function(String cartItemId, int quantity) onQuantityChanged;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<double> onShippingChanged;
  final VoidCallback onCheckout;
  final bool isProcessing;
  final TextEditingController noteController;
  final double subTotal;
  final double taxTotal;
  final double shipping;
  final double discount;
  final double grandTotal;
  final String currencySymbol;
  final String? errorMessage;
  final String? successMessage;
  final VoidCallback onClearMessages;

  @override
  State<CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<CartSummary> {
  late final TextEditingController _discountController;
  late final TextEditingController _shippingController;
  late NumberFormat _currency;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: widget.discount.toStringAsFixed(2),
    );
    _shippingController = TextEditingController(
      text: widget.shipping.toStringAsFixed(2),
    );
    _currency = NumberFormat.currency(symbol: widget.currencySymbol);
  }

  @override
  void didUpdateWidget(CartSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.discount != widget.discount) {
      _discountController.text = widget.discount.toStringAsFixed(2);
    }
    if (oldWidget.shipping != widget.shipping) {
      _shippingController.text = widget.shipping.toStringAsFixed(2);
    }
    if (oldWidget.currencySymbol != widget.currencySymbol) {
      _currency = NumberFormat.currency(symbol: widget.currencySymbol);
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _shippingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Panier',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text('${widget.items.length} article(s)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.errorMessage != null || widget.successMessage != null)
                    _StatusBanner(
                      message: widget.errorMessage ?? widget.successMessage!,
                      isError: widget.errorMessage != null,
                      onDismiss: widget.onClearMessages,
                    ),
                  const SizedBox(height: 8),
                  if (widget.items.isEmpty)
                    const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Ajoutez un produit pour démarrer la vente.'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          title: Text(
                            item.product.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            _currency.format(item.product.price),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: SizedBox(
                            width: 170,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: 'Supprimer',
                                  onPressed: () => widget.onRemove(item.id),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => widget.onQuantityChanged(
                                    item.id,
                                    item.quantity - 1,
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                IconButton(
                                  onPressed: () => widget.onQuantityChanged(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Customer>(
                    value: widget.selectedCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Client',
                    ),
                    items: widget.customers
                        .map(
                          (customer) => DropdownMenuItem(
                            value: customer,
                            child: Text(customer.name),
                          ),
                        )
                        .toList(),
                    onChanged: widget.onCustomerChanged,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          decoration: const InputDecoration(
                            labelText: 'Remise',
                            prefixIcon: Icon(Icons.percent_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              widget.onDiscountChanged(double.tryParse(value) ?? 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _shippingController,
                          decoration: const InputDecoration(
                            labelText: 'Livraison',
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              widget.onShippingChanged(double.tryParse(value) ?? 0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TotalsRow(
                    label: 'Sous-total',
                    value: _currency.format(widget.subTotal),
                  ),
                  _TotalsRow(
                    label: 'TVA',
                    value: _currency.format(widget.taxTotal),
                  ),
                  _TotalsRow(
                    label: 'Livraison',
                    value: _currency.format(widget.shipping),
                  ),
                  _TotalsRow(
                    label: 'Total',
                    value: _currency.format(widget.grandTotal),
                    emphasized: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.isProcessing ? null : widget.onCheckout,
                      icon: widget.isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        widget.isProcessing ? 'Envoi...' : 'Encaisser',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.redAccent : Colors.green,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.redAccent : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
