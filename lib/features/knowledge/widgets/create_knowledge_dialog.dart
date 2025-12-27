// lib/screens/knowledge/widgets/create_knowledge_dialog.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import 'knowledge_item.dart';

class CreateKnowledgeDialog extends StatefulWidget {
  // THÊM MỚI:
  final KnowledgeItem? itemToEdit; // Item để edit (nếu có)
  final List<KnowledgeItem> allItems; // Danh sách để kiểm tra trùng tên

  const CreateKnowledgeDialog({
    super.key,
    this.itemToEdit,
    required this.allItems,
  });

  @override
  State<CreateKnowledgeDialog> createState() => _CreateKnowledgeDialogState();
}

class _CreateKnowledgeDialogState extends State<CreateKnowledgeDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.itemToEdit != null; // Kiểm tra xem có phải Edit không

  @override
  void initState() {
    super.initState();
    // Nếu là Edit, điền form
    if (_isEditMode) {
      _titleController.text = widget.itemToEdit!.title;
      _descController.text = widget.itemToEdit!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Nếu là Edit
      if (_isEditMode) {
        // Cập nhật item cũ
        widget.itemToEdit!.title = _titleController.text;
        widget.itemToEdit!.description = _descController.text;
        Navigator.of(context).pop(widget.itemToEdit);
      } else {
        // Nếu là Create, tạo item mới
        final newItem = KnowledgeItem(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
        );
        Navigator.of(context).pop(newItem);
      }
    }
  }

  // Hàm kiểm tra tên
  String? _validateTitle(String? value) {
    final title = value?.trim().toLowerCase();
    if (title == null || title.isEmpty) {
      return 'Please enter a name';
    }

    // Kiểm tra tên trùng
    final isDuplicate = widget.allItems.any((item) {
      // Nếu là edit, bỏ qua chính nó khi kiểm tra
      if (_isEditMode && item.id == widget.itemToEdit!.id) {
        return false;
      }
      return item.title.toLowerCase() == title;
    });

    if (isDuplicate) {
      return 'This name already exists. Please enter a unique name.';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // SỬA: Đổi tiêu đề
                      _isEditMode ? 'Edit Knowledge Base' : 'Create a Knowledge Base',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Knowledge Base Name *', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    hintText: 'Enter a unique name for your...',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateTitle, // <-- SỬA: Dùng hàm validator
                ),
                const SizedBox(height: 16),
                Text('Description', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLength: 500,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Briefly describe the purpose of this...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      // SỬA: Đổi tên nút
                      child: Text(_isEditMode ? 'Save' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}