// lib/screens/knowledge/knowledge_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/core/constants/assets.dart';
import '/core/constants/colors.dart';
import './knowledge_item.dart'; // Đã sửa đường dẫn import
import './create_knowledge_dialog.dart'; // Đã sửa đường dẫn import
import './knowledge_item_card.dart'; // Đã sửa đường dẫn import
import './delete_confirmation_dialog.dart'; // Đã sửa đường dẫn import
import './add_knowledge_unit_dialog.dart';

class KnowledgeListScreen extends StatefulWidget {
  const KnowledgeListScreen({super.key});

  @override
  State<KnowledgeListScreen> createState() => _KnowledgeListScreenState();
}

class _KnowledgeListScreenState extends State<KnowledgeListScreen> {
  // --- STATE (Trạng thái) ---
  final _searchController = TextEditingController();
  
  final List<KnowledgeItem> _items = [
    KnowledgeItem(title: 'Knowledge Name', description: 'Knowledge description'),
    KnowledgeItem(title: 'binh nguyen', description: 'hihi'),
    KnowledgeItem(title: 'tan duc', description: 'mo ta'),
    KnowledgeItem(title: 'Tan Hung', description: 'Toi la nguyen tan hung'),
  ];
  
  List<KnowledgeItem> _filteredItems = [];
  KnowledgeItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterList);
    _filteredItems = _items;
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC (Giữ nguyên) ---
  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        return item.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showCreateDialog() async {
    final newItem = await showDialog<KnowledgeItem>(
      context: context,
      builder: (context) => CreateKnowledgeDialog(allItems: _items),
    );
    if (newItem != null) {
      setState(() {
        _items.add(newItem);
        _filterList();
        _selectedItem = newItem;
      });
      _showSuccessToast('Knowledge base created successfully');
    }
  }

  void _showEditDialog(KnowledgeItem itemToEdit) async {
    final updatedItem = await showDialog<KnowledgeItem>(
      context: context,
      builder: (context) => CreateKnowledgeDialog(
        allItems: _items,
        itemToEdit: itemToEdit,
      ),
    );
    if (updatedItem != null) {
      setState(() {
        final index = _items.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) _items[index] = updatedItem;
        _filterList();
        if (_selectedItem?.id == updatedItem.id) _selectedItem = updatedItem;
      });
      _showSuccessToast('Knowledge base updated successfully');
    }
  }

  void _showDeleteDialog(KnowledgeItem itemToDelete) async {
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        knowledgeName: itemToDelete.title,
      ),
    ) ?? false;
    if (didConfirm) {
      setState(() {
        _items.removeWhere((item) => item.id == itemToDelete.id);
        _filterList();
        if (_selectedItem?.id == itemToDelete.id) _selectedItem = null;
      });
      _showSuccessToast('Knowledge base deleted successfully');
    }
  }

  void _showSuccessToast(String message) {
    // (Hàm này giữ nguyên)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  // --- BUILD UI (Giữ nguyên) ---

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return IndexedStack(
        index: _selectedItem == null ? 0 : 1,
        children: [
          _buildMasterPanel(context, isMobile), // Index 0
          if (_selectedItem != null) 
            _buildDetailPanel( // Index 1
              context, 
              _selectedItem!, 
              isMobile,
              onClose: () => setState(() { _selectedItem = null; }),
            ),
        ],
      );
    } else {
      return Row(
        children: [
          Flexible(
            flex: 1,
            child: _buildMasterPanel(context, isMobile),
          ),
          if (_selectedItem != null) ...[
            const VerticalDivider(width: 1, color: AppColors.border),
            Flexible(
              flex: 1,
              child: _buildDetailPanel(
                context, 
                _selectedItem!, 
                isMobile,
                onClose: () => setState(() { _selectedItem = null; }),
              ),
            ),
          ]
        ],
      );
    }
  }

  // HÀM BUILD MASTER (Giữ nguyên)
  Widget _buildMasterPanel(BuildContext context, bool isMobile) {
    // (Hàm này giữ nguyên)
    final searchBar = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search knowledge base...',
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => _searchController.clear(),
              )
            : null,
        filled: true,
        fillColor: AppColors.sidebarBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final createButton = ElevatedButton.icon(
      onPressed: _showCreateDialog,
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Create Knowledge'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: isMobile ? const Size(double.infinity, 56) : null,
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            Text(
              'Knowledge Base',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (isMobile) ...[
            createButton,
            const SizedBox(height: 16),
            searchBar,
          ] else ...[
            Row(
              children: [
                Expanded(child: searchBar),
                const SizedBox(width: 16),
                createButton,
              ],
            ),
          ],
          const SizedBox(height: 32),
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyStateMaster()
                : _buildKnowledgeList(),
          ),
        ],
      ),
    );
  }

  // --- SỬA LỖI TRÀN MÀN HÌNH TẠI ĐÂY ---
  // HÀM BUILD CHO CỘT DETAIL (CHI TIẾT UNIT)
  Widget _buildDetailPanel(BuildContext context, KnowledgeItem item, bool isMobile, {VoidCallback? onClose}) {
    final List<dynamic> _units = []; // Tạm thời trống

    void _showAddUnitDialog() {
      showDialog(
        context: context,
        builder: (context) => const AddKnowledgeUnitDialog(),
      );
    }

    final searchBar = TextField(
      decoration: InputDecoration(
        hintText: 'Search knowledge units...',
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.sidebarBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final addButton = ElevatedButton.icon(
      onPressed: _showAddUnitDialog,
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Add Knowledge Unit'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: isMobile ? const Size(double.infinity, 56) : null,
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 24,
      ),
      // SỬA: Bọc Column trong SingleChildScrollView
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onClose,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (!isMobile)
                        Text(
                          item.description,
                          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (!isMobile)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (isMobile) ...[
              addButton,
              const SizedBox(height: 16),
              searchBar,
            ] else ...[
              Row(
                children: [
                  Expanded(child: searchBar),
                  const SizedBox(width: 16),
                  addButton,
                ],
              ),
            ],
            const SizedBox(height: 32),
            
            // SỬA: Xóa 'Expanded'
            _units.isEmpty
                ? _buildEmptyStateDetail(_showAddUnitDialog)
                : ListView(
                    // Thêm 2 dòng này khi lồng ListView trong Column/SingleChildScrollView
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [Text('Unit list... (TODO)')]
                  ),
          ],
        ),
      ),
    );
  }

  // (Hàm này giữ nguyên)
  Widget _buildEmptyStateMaster() {
    if (_searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.knowledgeEmpty, height: 150),
            const SizedBox(height: 24),
            const Text('No knowledge found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.knowledgeEmpty, height: 150),
          const SizedBox(height: 24),
          const Text('No knowledge found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _showCreateDialog,
            child: const Text('Create your own knowledge', style: TextStyle(color: AppColors.textLink, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // (Hàm này giữ nguyên)
  Widget _buildEmptyStateDetail(VoidCallback onAddPressed) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.knowledgeEmpty, height: 150),
          const SizedBox(height: 24),
          const Text('No knowledge units found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onAddPressed,
            child: const Text('Click here to add new knowledge', style: TextStyle(color: AppColors.textLink, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // (Hàm này giữ nguyên)
  Widget _buildKnowledgeList() {
    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: KnowledgeItemCard(
            item: item,
            onTap: () => setState(() { _selectedItem = item; }),
            onEdit: () => _showEditDialog(item),
            onDelete: () => _showDeleteDialog(item),
          ),
        );
      },
    );
  }
}