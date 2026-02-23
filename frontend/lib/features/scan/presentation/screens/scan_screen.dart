// I-Fridge — Scan Screen
// =======================
// Camera-based ingredient scanning with AI recognition.
// Captures an image, sends to the backend vision API,
// and displays results in 3 confidence tiers: auto-add, confirm, or correct.

import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/services/api_service.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/core/utils/category_images.dart';
import 'package:ifridge_app/features/scan/presentation/screens/audit_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final ApiService _api = ApiService();

  bool _scanning = false;
  // 0 = Receipt, 1 = Photo, 2 = Barcode
  int _scanMode = 0;
  Map<String, dynamic>? _results;
  String? _error;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _scanning = true;
        _error = null;
        _results = null;
      });

      final Uint8List bytes = await image.readAsBytes();

      // Send to FastAPI -> Gemini Vision Endpoint
      final result = await _api.parseReceipt(
        imageBytes: bytes,
        filename: image.name,
      );

      setState(() {
        _results = result;
        _scanning = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _scanning = false;
      });
    }
  }

  /// Capture a photo for ingredient detection (not receipts)
  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _scanning = true;
        _error = null;
        _results = null;
      });

      final Uint8List bytes = await image.readAsBytes();

      final result = await _api.detectIngredients(
        imageBytes: bytes,
        filename: image.name,
      );

      setState(() {
        _results = result;
        _scanning = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Scan Food',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.surface,
        centerTitle: true,
      ),
      body: _scanning
          ? _buildScanningState()
          : _results != null
              ? _buildResults()
              : _buildCaptureState(),
    );
  }

  // ── Capture State (initial) ──────────────────────────────────────

  Widget _buildCaptureState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated scan icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.08,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accent.withValues(alpha: 0.3),
                          AppTheme.accent.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      size: 56,
                      color: AppTheme.accent,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Scan Your Ingredients',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo of food items to add them\nto your shelf automatically',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ── Mode Toggle ──────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    icon: Icons.receipt_long,
                    label: 'Receipt',
                    isActive: _scanMode == 0,
                    activeColor: AppTheme.accent,
                    onTap: () => setState(() => _scanMode = 0),
                  ),
                  _ModeTab(
                    icon: Icons.photo_camera,
                    label: 'Photo',
                    isActive: _scanMode == 1,
                    activeColor: IFridgeTheme.primary,
                    onTap: () => setState(() => _scanMode = 1),
                  ),
                  _ModeTab(
                    icon: Icons.qr_code_scanner,
                    label: 'Barcode',
                    isActive: _scanMode == 2,
                    activeColor: IFridgeTheme.secondary,
                    onTap: () => setState(() => _scanMode = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Camera button
            if (_scanMode != 2) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => _scanMode == 0
                      ? _captureImage(ImageSource.camera)
                      : _capturePhoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, size: 22),
                  label: const Text(
                    'Take Photo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],

            // Barcode scan button
            if (_scanMode == 2) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _openBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner, size: 22),
                  label: const Text(
                    'Scan Barcode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: IFridgeTheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Gallery button
            if (_scanMode != 2) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _scanMode == 0
                      ? _captureImage(ImageSource.gallery)
                      : _capturePhoto(ImageSource.gallery),
                  icon: Icon(Icons.photo_library,
                      size: 22, color: Colors.white.withValues(alpha: 0.7)),
                  label: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Manual Entry Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: _showManualEntryForm,
                icon: const Icon(Icons.edit_note, size: 22, color: IFridgeTheme.primary),
                label: const Text(
                  'Add Manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: IFridgeTheme.primary,
                  ),
                ),
              ),
            ),

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recognition failed. Try again.',
                        style: TextStyle(
                            color: Colors.red.withValues(alpha: 0.8),
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Scanning State (loading) ─────────────────────────────────────

  Widget _buildScanningState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 3,
              backgroundColor: AppTheme.accent.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your food...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is identifying ingredients',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Results State (Parsed Receipt) ───────────────────────────────

  Widget _buildResults() {
    final data = _results;
    if (data == null) return _buildCaptureState();

    final store = data['store'] as String? ?? 'Unknown Store';
    final date = data['date'] as String? ?? 'Unknown Date';
    final items = (data['items'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Header
          if (_scanMode == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.15),
                    AppTheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppTheme.accent,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    store,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.freshGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length} Items Detected',
                      style: const TextStyle(
                        color: AppTheme.freshGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    IFridgeTheme.primary.withValues(alpha: 0.15),
                    AppTheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: IFridgeTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                   const Icon(
                    Icons.image_search,
                    color: IFridgeTheme.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Photo Analysis Selected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.freshGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length} Ingredients Detected',
                      style: const TextStyle(
                        color: AppTheme.freshGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Parsed Items List
          if (items.isNotEmpty) ...[
            _sectionHeader(
              '📦 Parsed Ingredients',
              'Review and add to shelf',
              Colors.white,
            ),
            ...items.map((item) {
              final i = item as Map<String, dynamic>;
              final canonicalName = i['canonical_name'] ?? i['item_name'] ?? 'Unknown';
              final qty = i['quantity']?.toString() ?? '1';
              final unit = i['unit'] ?? '';
              final category = i['category'] ?? '';
              final expiry = i['expiry_date'] != null 
                  ? DateTime.parse(i['expiry_date']).toString().split(' ')[0] 
                  : 'Unknown';

              return _resultTile(
                icon: Icons.check_circle_outline,
                title: canonicalName,
                subtitle: '$qty $unit • $category\nExp: $expiry',
                color: AppTheme.freshGreen,
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: AppTheme.accent),
                  onPressed: () async {
                    try {
                      final client = Supabase.instance.client;
                      final userId = currentUserId();

                      // 1. Find or create ingredient
                      final existing = await client
                          .from('ingredients')
                          .select('id')
                          .ilike('display_name_en', canonicalName)
                          .maybeSingle();

                      String ingredientId;
                      if (existing != null) {
                        ingredientId = existing['id'];
                      } else {
                        final inserted = await client.from('ingredients').insert({
                          'display_name_en': canonicalName,
                          'category': category.isNotEmpty ? category : 'Pantry',
                        }).select('id').single();
                        ingredientId = inserted['id'];
                      }

                      // 2. Insert into inventory_items
                      final qtyNum = double.tryParse(qty) ?? 1.0;
                      await client.from('inventory_items').insert({
                        'user_id': userId,
                        'ingredient_id': ingredientId,
                        'quantity': qtyNum,
                        'unit': unit.isEmpty ? 'pcs' : unit,
                        'location': 'Fridge', // Default location
                        'expiry_date': i['expiry_date'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                      });

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $canonicalName!'),
                          backgroundColor: AppTheme.freshGreen,
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error adding to shelf: $e');
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add $canonicalName'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ],

          const SizedBox(height: 32),

          // Scan again button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _results = null;
                _error = null;
              }),
              icon: Icon(Icons.refresh, color: Colors.white.withValues(alpha: 0.7)),
              label: Text('Scan Another', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Audit Items Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                final itemsList = (_results?['items'] as List?) ?? [];
                if (itemsList.isEmpty) return;
                
                final auditItems = itemsList.map((i) {
                  final name = i['canonical_name'] ?? i['item_name'] ?? 'Unknown';
                  return AuditItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(1000).toString(),
                    title: name,
                    description: '${i['quantity'] ?? 1} ${i['unit'] ?? "pcs"} • Exp: ${i['expiry_date'] != null ? DateTime.parse(i['expiry_date']).toString().split(' ')[0] : 'Unknown'}',
                    category: i['category'] ?? 'Pantry',
                    rawDetect: name,
                  );
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AuditScreen(initialItems: auditItems)),
                );
              },
              icon: const Icon(Icons.style),
              label: const Text('Start Visual Audit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(subtitle,
              style: TextStyle(
                  color: color.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _resultTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onConfirm,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: trailing ?? (onConfirm != null
            ? IconButton(
                icon: const Icon(Icons.check, color: AppTheme.freshGreen),
                onPressed: onConfirm,
              )
            : null),
      ),
    );
  }

  // ── Manual Entry Form ────────────────────────────────────────────

  void _showManualEntryForm({String? prefillName, String? prefillCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManualEntryBottomSheet(
        prefillName: prefillName,
        prefillCategory: prefillCategory,
      ),
    );
  }

  // ── Barcode Scanner ─────────────────────────────────────────────

  Future<void> _openBarcodeScanner() async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Enter Barcode',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g., 8801234567890',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: IFridgeTheme.secondary,
              ),
              child: const Text('Look Up'),
            ),
          ],
        );
      },
    );

    if (barcode == null || barcode.isEmpty) return;

    setState(() {
      _scanning = true;
      _error = null;
    });

    try {
      final result = await _api.lookupBarcode(barcode);
      if (!mounted) return;

      setState(() => _scanning = false);

      if (result != null && result['product'] != null) {
        final product = result['product'] as Map<String, dynamic>;
        _showManualEntryForm(
          prefillName: product['product_name'] as String? ?? barcode,
          prefillCategory: product['categories'] as String?,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found for barcode $barcode'),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        _showManualEntryForm(prefillName: barcode);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = 'Barcode lookup failed: $e';
      });
    }
  }
}

class _ManualEntryBottomSheet extends StatefulWidget {
  final String? prefillName;
  final String? prefillCategory;
  const _ManualEntryBottomSheet({this.prefillName, this.prefillCategory});

  @override
  State<_ManualEntryBottomSheet> createState() => _ManualEntryBottomSheetState();
}

class _ManualEntryBottomSheetState extends State<_ManualEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIngredientId;
  String _ingredientName = '';
  double _quantity = 1.0;
  String _unit = 'pcs';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  
  // Category to bind the state of the dropdown
  String _category = 'Produce';
  
  final List<String> _categories = [
    'Produce', 'Vegetable', 'Fruit', 'Meat', 'Poultry', 'Seafood',
    'Dairy', 'Milk', 'Cheese', 'Yogurt', 'Eggs',
    'Bakery', 'Bread', 'Grain', 'Pasta',
    'Pantry', 'Canned', 'Frozen',
    'Beverage', 'Juice', 'Snack',
    'Condiment', 'Spice', 'Oil', 'Sauce',
    'Nuts', 'Legumes', 'Tofu', 'Protein',
  ];

  final List<String> _units = [
    // Count
    'pcs', 'pack', 'bunch',
    // Mass
    'g', 'kg', 'oz', 'lb',
    // Volume
    'ml', 'L', 'cup', 'tbsp', 'tsp'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefillName != null) {
      _ingredientName = widget.prefillName!;
    }
    if (widget.prefillCategory != null && _categories.contains(widget.prefillCategory)) {
      _category = widget.prefillCategory!;
    }
    _updateExpiryByCategory(_category);
  }

  void _updateExpiryByCategory(String cat) {
    final lc = cat.toLowerCase();
    int days;
    switch (lc) {
      case 'produce':
      case 'vegetable': days = 7; break;
      case 'fruit': days = 5; break;
      case 'meat':
      case 'poultry': days = 3; break;
      case 'seafood': days = 2; break;
      case 'dairy': days = 10; break;
      case 'milk': days = 7; break;
      case 'cheese': days = 30; break;
      case 'yogurt': days = 14; break;
      case 'eggs': days = 21; break;
      case 'bakery':
      case 'bread': days = 5; break;
      case 'grain':
      case 'pasta': days = 365; break;
      case 'pantry':
      case 'canned': days = 365; break;
      case 'frozen': days = 90; break;
      case 'beverage':
      case 'juice': days = 30; break;
      case 'snack': days = 60; break;
      case 'condiment':
      case 'sauce': days = 180; break;
      case 'spice': days = 730; break; // 2 years
      case 'oil': days = 365; break;
      case 'nuts': days = 180; break;
      case 'legumes': days = 365; break;
      case 'tofu': days = 7; break;
      case 'protein': days = 3; break;
      default: days = 14;
    }
    setState(() {
      _expiryDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Insert into Supabase inventory_items
      try {
        final client = Supabase.instance.client;
        final userId = currentUserId();

        // 1. Upsert into ingredients table (find or create)
        final existingIngredient = await client
            .from('ingredients')
            .select('id')
            .ilike('display_name_en', _ingredientName)
            .maybeSingle();

        String ingredientId;
        if (existingIngredient != null) {
          ingredientId = existingIngredient['id'];
        } else {
          final inserted = await client.from('ingredients').insert({
            'display_name_en': _ingredientName,
            'category': _category,
            'default_unit': _unit,
          }).select('id').single();
          ingredientId = inserted['id'];
        }

        // 2. Insert into inventory_items
        await client.from('inventory_items').insert({
          'user_id': userId,
          'ingredient_id': ingredientId,
          'quantity': _quantity,
          'unit': _unit,
          'location': 'Fridge',
          'expiry_date': _expiryDate.toIso8601String(),
        });

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $_ingredientName to shelf!'),
            backgroundColor: IFridgeTheme.freshGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle keyboard pushing up the sheet
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset > 0 ? bottomInset + 24 : 48,
      ),
      decoration: BoxDecoration(
        color: IFridgeTheme.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const Text(
              'Add Ingredient',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Autocomplete Field
            LayoutBuilder(
              builder: (context, constraints) => Autocomplete<Map<String, dynamic>>(
                displayStringForOption: (opt) => opt['display_name_en'] as String,
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  try {
                    final res = await Supabase.instance.client
                        .from('ingredients')
                        .select('*')
                        .ilike('display_name_en', '%${textEditingValue.text}%')
                        .limit(5);
                    return (res as List).map((e) => e as Map<String, dynamic>);
                  } catch (e) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                },
                onSelected: (Map<String, dynamic> selection) {
                  setState(() {
                    _ingredientName = selection['display_name_en'];
                    if (selection['category'] != null && _categories.contains(selection['category'])) {
                      _category = selection['category'];
                    }
                    if (selection['default_unit'] != null && _units.contains(selection['default_unit'])) {
                      _unit = selection['default_unit'];
                    }
                    _updateExpiryByCategory(_category);
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  // Ensure ingredient name is captured if user types without selecting
                  textEditingController.addListener(() {
                    _ingredientName = textEditingController.text;
                  });
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Ingredient Name',
                      hintText: 'e.g. Apples, Bread, Milk',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.surface,
                      child: Container(
                        width: constraints.maxWidth,
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            final cat = option['category'] as String? ?? '';
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  categoryImageUrl(cat),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 40, height: 40,
                                    color: IFridgeTheme.bgElevated,
                                    child: Center(child: Text(categoryEmoji(cat), style: const TextStyle(fontSize: 20))),
                                  ),
                                ),
                              ),
                              title: Text(option['display_name_en'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              subtitle: Text(cat, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _category = v;
                    _updateExpiryByCategory(v);
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Quantity & Unit Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: '1',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSaved: (v) => _quantity = double.tryParse(v!) ?? 1.0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: InputDecoration(
                      labelText: 'Metric Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setState(() => _unit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expiry Date Picker (Mocked Action)
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (date != null) setState(() => _expiryDate = date);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Estimated Expiry',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_expiryDate.month}/${_expiryDate.day}/${_expiryDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: IFridgeTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Add to Shelf', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mode Tab Widget ─────────────────────────────────────────────────

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: isActive ? activeColor : Colors.white38, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: isActive ? activeColor : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
