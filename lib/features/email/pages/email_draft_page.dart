import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/AppDrawer.dart';
import '../models/email_action_type.dart';
import '../widgets/email_header_card.dart';
import '../widgets/received_email_card.dart';
import '../widgets/ai_reply_card.dart';
import '../widgets/email_action_button.dart';

class EmailDraftPage extends StatefulWidget {
  const EmailDraftPage({super.key});

  @override
  State<EmailDraftPage> createState() => _EmailDraftPageState();
}

class _EmailDraftPageState extends State<EmailDraftPage> {
  final TextEditingController _receivedEmailController = TextEditingController();
  final TextEditingController _customInstructionController = TextEditingController();
  
  String _aiReply = '';
  bool _isLoading = false;
  EmailActionType? _selectedAction;

  @override
  void initState() {
    super.initState();
    // Mock received email for demo
    _receivedEmailController.text = '''Kính gửi [Tên người nhận],

Tôi tên là [Họ và tên], tôi xin phép được ứng tuyển vào vị trí [Tên vị trí] tại [Tên công ty]. Qua tìm hiểu, tôi nhận thấy đây là một cơ hội tốt để phát triển sự nghiệp và đồng thời đóng góp vào sự phát triển của công ty.

Tôi đã tốt nghiệp chuyên ngành [Tên chuyên ngành] tại [Tên trường đại học] và có kinh nghiệm làm việc tại [Tên công ty cũ]. Trong quá trình làm việc, tôi đã tích lũy được những kỹ năng cần thiết như [liệt kê các kỹ năng quan trọng].

Tôi tin rằng với những kiến thức và kinh nghiệm của mình, tôi có thể hoàn thành tốt các nhiệm vụ tại vị trí này và đóng góp tích cực vào sự thành công của công ty.

Rất mong sớm nhận được phản hồi từ quý công ty.

Trân trọng,
[Họ và tên]
[Số điện thoại]
[Email]''';
  }

  @override
  void dispose() {
    _receivedEmailController.dispose();
    _customInstructionController.dispose();
    super.dispose();
  }

  Future<void> _generateEmailReply(EmailActionType actionType) async {
    setState(() {
      _isLoading = true;
      _selectedAction = actionType;
      _aiReply = '';
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock AI-generated replies based on action type
    String generatedReply = _getMockReply(actionType);

    if (mounted) {
      setState(() {
        _aiReply = generatedReply;
        _isLoading = false;
      });
    }
  }

  String _getMockReply(EmailActionType actionType) {
    switch (actionType) {
      case EmailActionType.thanks:
        return '''Kính gửi [Họ và tên ứng viên],

Cảm ơn bạn đã quan tâm và gửi đơn ứng tuyển vào vị trí [Tên vị trí] tại [Tên công ty]. Chúng tôi đã nhận được hồ sơ của bạn và đang trong quá trình xem xét.

Chúng tôi rất ấn tượng với kinh nghiệm và kỹ năng của bạn. Bộ phận nhân sự sẽ liên hệ với bạn trong vòng 5-7 ngày làm việc để thông báo kết quả và sắp xếp buổi phỏng vấn nếu phù hợp.

Một lần nữa xin cảm ơn bạn đã dành thời gian ứng tuyển vào công ty chúng tôi.

Trân trọng,
[Tên người gửi]
[Chức vụ]
[Tên công ty]
[Email]
[Số điện thoại]''';

      case EmailActionType.sorry:
        return '''Kính gửi [Họ và tên ứng viên],

Cảm ơn bạn đã quan tâm và gửi đơn ứng tuyển vào vị trí [Tên vị trí] tại [Tên công ty]. Sau khi xem xét kỹ lưỡng hồ sơ của bạn, chúng tôi rất tiếc phải thông báo rằng hiện tại chúng tôi đã tìm được ứng viên phù hợp hơn cho vị trí này.

Chúng tôi đánh giá cao những kinh nghiệm và kỹ năng của bạn, và hy vọng bạn sẽ tiếp tục thành công trong sự nghiệp. Nếu có cơ hội phù hợp trong tương lai, chúng tôi rất mong có thể xem xét hồ sơ của bạn một lần nữa.

Một lần nữa xin cảm ơn bạn đã dành thời gian ứng tuyển và chúc bạn nhiều thành công trong các cơ hội tiếp theo.

Trân trọng,
[Tên người gửi]
[Chức vụ]
[Tên công ty]
[Email]
[Số điện thoại]''';

      case EmailActionType.yes:
        return '''Kính gửi [Họ và tên ứng viên],

Chúng tôi rất vui mừng thông báo rằng bạn đã được chọn cho vị trí [Tên vị trí] tại [Tên công ty]. Chúng tôi ấn tượng với trình độ chuyên môn và kinh nghiệm của bạn.

Chúng tôi muốn mời bạn tham gia buổi phỏng vấn vào [Ngày giờ] tại [Địa điểm]. Vui lòng xác nhận sự tham dự của bạn trước ngày [Ngày].

Nếu bạn có bất kỳ câu hỏi nào, xin đừng ngần ngại liên hệ với chúng tôi.

Rất mong được gặp bạn!

Trân trọng,
[Tên người gửi]
[Chức vụ]
[Tên công ty]
[Email]
[Số điện thoại]''';

      case EmailActionType.no:
        return '''Kính gửi [Họ và tên ứng viên],

Cảm ơn bạn đã quan tâm đến vị trí [Tên vị trí] tại [Tên công ty]. Sau khi xem xét cẩn thận, chúng tôi nhận thấy rằng hiện tại hồ sơ của bạn chưa phù hợp với yêu cầu của vị trí này.

Tuy nhiên, chúng tôi rất trân trọng sự quan tâm của bạn và khuyến khích bạn tiếp tục theo dõi các cơ hội nghề nghiệp khác tại công ty chúng tôi trong tương lai.

Chúc bạn thành công trong việc tìm kiếm công việc phù hợp.

Trân trọng,
[Tên người gửi]
[Chức vụ]
[Tên công ty]
[Email]
[Số điện thoại]''';

      case EmailActionType.followUp:
        return '''Kính gửi [Họ và tên ứng viên],

Tôi viết email này để theo dõi đơn ứng tuyển của bạn cho vị trí [Tên vị trí] mà bạn đã gửi vào ngày [Ngày].

Chúng tôi đang trong quá trình xem xét các ứng viên và dự kiến sẽ có quyết định trong vòng [Số ngày] tới. Chúng tôi sẽ liên hệ với bạn ngay khi có kết quả.

Cảm ơn bạn đã kiên nhẫn chờ đợi và quan tâm đến công ty chúng tôi.

Trân trọng,
[Tên người gửi]
[Chức vụ]
[Tên công ty]
[Email]
[Số điện thoại]''';

      case EmailActionType.requestInfo:
        return '''Kính gửi [Họ và tên ứng viên],

Cảm ơn bạn đã ứng tuyển vào vị trí [Tên vị trí] tại [Tên công ty]. Chúng tôi đã xem xét hồ sơ của bạn và rất quan tâm đến ứng viên của bạn.

Để có thể đánh giá tốt hơn, chúng tôi cần một số thông tin bổ sung:

1. [Thông tin cần thiết 1]
2. [Thông tin cần thiết 2]
3. [Thông tin cần thiết 3]

Vui lòng gửi thông tin này cho chúng tôi trước ngày [Ngày]. Nếu bạn có bất kỳ câu hỏi nào, xin đừng ngần ngại liên hệ.

Cảm ơn sự hợp tác của bạn.

Trân trọng,
[Tên người gửi]
[Chức vụ]
[Tên công ty]
[Email]
[Số điện thoại]''';
    }
  }

  Future<void> _generateCustomReply() async {
    if (_customInstructionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your instructions'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedAction = null;
      _aiReply = '';
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _aiReply = '''Kính gửi [Người nhận],

[AI sẽ tạo nội dung email dựa trên yêu cầu: "${_customInstructionController.text}"]

Đây là email được tạo tự động dựa trên hướng dẫn của bạn. Vui lòng xem xét và chỉnh sửa nếu cần thiết.

Trân trọng,
[Tên của bạn]
[Chức vụ]
[Công ty]
[Thông tin liên hệ]''';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
          title: const Text(
            'Email Draft',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        drawer: const SafeArea(child: AppDrawer()),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header
                  const EmailHeaderCard(),
                  const SizedBox(height: 24),

                  // Received Email
                  ReceivedEmailCard(controller: _receivedEmailController),
                  const SizedBox(height: 24),

                  // AI Reply
                  AiReplyCard(
                    replyText: _aiReply,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Action Suggestions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: EmailActionType.values.map((actionType) {
                      return EmailActionButton(
                        actionType: actionType,
                        onPressed: () => _generateEmailReply(actionType),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100), // Space for input box
                ],
              ),
            ),

            // Custom instruction input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customInstructionController,
                        decoration: InputDecoration(
                          hintText: 'Tell AI how you want to reply...',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            onPressed: _generateCustomReply,
                            icon: Icon(
                              Icons.send,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
