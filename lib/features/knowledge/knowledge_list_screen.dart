// lib/screens/knowledge/knowledge_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/core/constants/assets.dart';
import '/core/constants/colors.dart';
import './knowledge_item.dart';
import './create_knowledge_dialog.dart';
import './knowledge_item_card.dart';
import './delete_confirmation_dialog.dart'; // <-- THÊM MỚI

// SỬA: Chuyển thành StatefulWidget
class KnowledgeListScreen extends StatefulWidget {
  const KnowledgeListScreen({super.key});

  @override
  State<KnowledgeListScreen> createState() => _KnowledgeListScreenState();
}

class _KnowledgeListScreenState extends State<KnowledgeListScreen> {
  // --- STATE (Trạng thái) ---
  final _searchController = TextEditingController();
  
  // Danh sách gốc (nguồn)
  final List<KnowledgeItem> _items = [
    // Bạn có thể thêm dữ liệu giả ở đây để test
    // KnowledgeItem(title: 'Demo 1', description: 'Mô tả 1'),
    // KnowledgeItem(title: 'Demo 2', description: 'Mô tả 2'),
  ];
  
  // Danh sách đã lọc (để hiển thị)
  List<KnowledgeItem> _filteredItems = [];

  // --- LIFECYCLE (Vòng đời) ---
  @override
  void initState() {
    super.initState();
    // Gắn listener cho thanh search
    _searchController.addListener(_filterList);
    // Khởi tạo, danh sách lọc = danh sách gốc
    _filteredItems = _items;
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterList);
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  // Hàm lọc danh sách
  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        return item.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Hàm gọi dialog TẠO MỚI
  void _showCreateDialog() async {
    final newItem = await showDialog<KnowledgeItem>(
      context: context,
      builder: (context) => CreateKnowledgeDialog(allItems: _items),
    );

    if (newItem != null) {
      setState(() {
        _items.add(newItem); // Thêm vào list gốc
        _filterList(); // Cập nhật list lọc
      });
      _showSuccessToast('Knowledge base created successfully');
    }
  }

  // Hàm gọi dialog CHỈNH SỬA
  void _showEditDialog(KnowledgeItem itemToEdit) async {
    final updatedItem = await showDialog<KnowledgeItem>(
      context: context,
      builder: (context) => CreateKnowledgeDialog(
        allItems: _items,
        itemToEdit: itemToEdit, // Truyền item vào
      ),
    );

    if (updatedItem != null) {
      setState(() {
        // Tìm và thay thế item trong list gốc
        final index = _items.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          _items[index] = updatedItem;
        }
        _filterList(); // Cập nhật list lọc
      });
      _showSuccessToast('Knowledge base updated successfully');
    }
  }

  // Hàm gọi dialog XÓA
  void _showDeleteDialog(KnowledgeItem itemToDelete) async {
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        knowledgeName: itemToDelete.title,
      ),
    ) ?? false; // Nếu đóng dialog, coi như là false

    if (didConfirm) {
      setState(() {
        _items.removeWhere((item) => item.id == itemToDelete.id); // Xóa khỏi list gốc
        _filterList(); // Cập nhật list lọc
      });
      _showSuccessToast('Knowledge base deleted successfully');
    }
  }

  // Hàm hiển thị toast
  void _showSuccessToast(String message) {
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

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final searchBar = TextField(
      controller: _searchController, // <-- SỬA: Gắn controller
      decoration: InputDecoration(
        hintText: 'Search knowledge base...',
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        // Thêm nút 'x' để xóa search
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );

    final createButton = ElevatedButton.icon(
      onPressed: _showCreateDialog, // <-- SỬA: Gắn hàm
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
          
          // SỬA: Hiển thị có điều kiện
          Expanded(
            // Nếu list LỌC trống, build EmptyState.
            // Nếu không, build List.
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : _buildKnowledgeList(),
          ),
        ],
      ),
    );
  }

  // Widget con cho Trạng thái rỗng
  Widget _buildEmptyState() {
    // Nếu có query (đang search) mà không thấy
    if (_searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.knowledgeEmpty,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'No knowledge found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
             // Không hiển thị link "Create" khi search
          ],
        ),
      );
    }
    
    // Nếu không search, và list gốc trống
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            Assets.knowledgeEmpty,
            height: 150,
          ),
          const SizedBox(height: 24),
          const Text(
            'No knowledge found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _showCreateDialog, // <-- SỬA: Gắn hàm
            child: const Text(
              'Create your own knowledge',
              style: TextStyle(color: AppColors.textLink, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con cho Danh sách
  Widget _buildKnowledgeList() {
    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: KnowledgeItemCard(
            item: item,
            onEdit: () => _showEditDialog(item),     // <-- SỬA: Gắn hàm
            onDelete: () => _showDeleteDialog(item), // <-- SỬA: Gắn hàm
          ),
        );
      },
    );
  }
}