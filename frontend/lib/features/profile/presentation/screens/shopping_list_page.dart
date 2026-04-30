// I-Fridge — Shopping List Deep Page
// ====================================
// Full shopping list with categories, check-off, swipe delete.
// Uses shopping_list table: id, user_id, ingredient_name, quantity, unit, is_purchased

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});
  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final uid = currentUserId();
      final data = await Supabase.instance.client
          .from('shopping_list')
          .select()
          .eq('user_id', uid)
          .order('is_purchased')
          .order('created_at', ascending: false);
      setState(() { _items = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addItem() async {
    final nameC = TextEditingController();
    final qtyC = TextEditingController(text: '1');
    String unit = 'pcs';
    final units = ['pcs', 'g', 'kg', 'ml', 'L', 'cup', 'tbsp', 'tsp'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Add Item', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC, autofocus: true,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Item name', hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                  filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyC,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Qty', hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                        filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: unit,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setDlg(() => unit = v ?? unit))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, {
                'name': nameC.text.trim(),
                'qty': double.tryParse(qtyC.text) ?? 1,
                'unit': unit,
              }),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text('Add')),
          ],
        ),
      ),
    );
    if (result == null || (result['name'] as String).isEmpty) return;
    try {
      final uid = currentUserId();
      await Supabase.instance.client.from('shopping_list').insert({
        'user_id': uid,
        'ingredient_name': result['name'],
        'quantity': result['qty'],
        'unit': result['unit'],
      });
      _load();
    } catch (_) {}
  }

  Future<void> _toggleCheck(Map<String, dynamic> item) async {
    final newVal = !(item['is_purchased'] == true);
    setState(() => item['is_purchased'] = newVal);
    try {
      await Supabase.instance.client.from('shopping_list')
          .update({'is_purchased': newVal}).eq('id', item['id']);
    } catch (_) {}
  }

  Future<void> _deleteItem(String id) async {
    setState(() => _items.removeWhere((i) => i['id'] == id));
    try {
      await Supabase.instance.client.from('shopping_list').delete().eq('id', id);
    } catch (_) {}
  }

  Future<void> _clearChecked() async {
    final checkedIds = _items.where((i) => i['is_purchased'] == true).map((i) => i['id']).toList();
    if (checkedIds.isEmpty) return;
    setState(() => _items.removeWhere((i) => i['is_purchased'] == true));
    try {
      for (final id in checkedIds) {
        await Supabase.instance.client.from('shopping_list').delete().eq('id', id);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final checked = _items.where((i) => i['is_purchased'] == true).toList();
    final unchecked = _items.where((i) => i['is_purchased'] != true).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Shopping List (${unchecked.length})',
          style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (checked.isNotEmpty)
            TextButton.icon(
              onPressed: _clearChecked,
              icon: Icon(Icons.delete_sweep, size: 18),
              label: Text('Clear ${checked.length}',
                style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, size: 28)),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
                      SizedBox(height: 12),
                      Text('Your shopping list is empty',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Tap + to add items',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25), fontSize: 13)),
                    ],
                  ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
                  children: [
                    // Active items
                    if (unchecked.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text('To Buy (${unchecked.length})',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      ...unchecked.map((item) => _ItemTile(
                        item: item,
                        onToggle: () => _toggleCheck(item),
                        onDelete: () => _deleteItem(item['id']),
                      )),
                    ],
                    // Purchased items
                    if (checked.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 6),
                        child: Text('Purchased (${checked.length})',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      ...checked.map((item) => _ItemTile(
                        item: item,
                        onToggle: () => _toggleCheck(item),
                        onDelete: () => _deleteItem(item['id']),
                      )),
                    ],
                  ],
                ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _ItemTile({required this.item, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final purchased = item['is_purchased'] == true;
    final qty = item['quantity'];
    final unit = item['unit'] ?? '';
    final qtyStr = qty != null ? '${(qty is num && qty == qty.toInt()) ? qty.toInt() : qty} $unit' : '';

    return Dismissible(
      key: Key(item['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.delete, color: Colors.red)),
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04))),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          leading: GestureDetector(
            onTap: onToggle,
            child: Icon(
              purchased ? Icons.check_circle : Icons.radio_button_unchecked,
              color: purchased ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 22)),
          title: Text(item['ingredient_name'] ?? '',
            style: TextStyle(
              color: purchased ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38) : Theme.of(context).colorScheme.onSurface,
              decoration: purchased ? TextDecoration.lineThrough : null,
              fontSize: 14)),
          trailing: qtyStr.isNotEmpty ? Text(qtyStr,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)) : null,
        ),
      ),
    );
  }
}
