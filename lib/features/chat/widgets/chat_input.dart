import 'package:flutter/material.dart';

class ChatInputBox extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onUpload;

  // === THAM SỐ MỚI ===
  final String? attachedImagePath;
  final VoidCallback onRemoveImage;
  // ===================

  const ChatInputBox({
    super.key,
    required this.onSend,
    required this.onUpload,
    // === YÊU CẦU THAM SỐ MỚI ===
    this.attachedImagePath,
    required this.onRemoveImage,
    // ===========================
  });

  // Widget MỚI: Hiển thị hình ảnh đính kèm
  Widget _buildAttachedImage() {
    if (attachedImagePath == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8),
      padding: const EdgeInsets.only(left: 4, right: 2, top: 4, bottom: 4),
      decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade700)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo, size: 20, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            'Image attached ($attachedImagePath)', // Hiển thị tên mô phỏng
            style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
          ),
          // Nút Xóa
          GestureDetector(
            onTap: onRemoveImage,
            child: Padding(
              padding: const EdgeInsets.only(left: 6, right: 4),
              child: Icon(Icons.close, size: 16, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Xác định nút Gửi có nên bật/tô màu xanh hay không (nếu có hình ảnh HOẶC text)
    final bool isReadyToSend = attachedImagePath != null; // Cần thêm check text controller.

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade800, width: 0.6),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Để tag hình ảnh căn trái
        children: [
          // === HIỂN THỊ HÌNH ẢNH ĐÍNH KÈM ===
          _buildAttachedImage(),

          const TextField(
            decoration: InputDecoration(
              hintText: "Ask me anything, press '/' for prompts...",
              hintStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(4, 2, 2, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onUpload,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blueGrey,
                  ),
                ),
                IconButton(
                  onPressed: onSend,
                  // Đổi màu để mô phỏng "sẵn sàng gửi" khi có hình ảnh đính kèm
                  icon: Icon(
                    Icons.send,
                    color: isReadyToSend ? Colors.blue.shade700 : Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}