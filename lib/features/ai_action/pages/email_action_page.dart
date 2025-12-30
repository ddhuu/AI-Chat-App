import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/api_service.dart';
import '../../../shared/providers/token_usage_provider.dart';
import '../providers/email_provider.dart';
import '../providers/email_style_provider.dart';
import '../services/email_service.dart';
import '../widgets/email/received_email_section.dart';
import '../widgets/email/email_metadata_section.dart';
import '../widgets/email/email_style_section.dart';
import '../widgets/email/suggest_ideas_section.dart';
import '../widgets/email/generated_email_section.dart';
import '../widgets/email/main_idea_input.dart';

class EmailActionPage extends StatefulWidget {
  const EmailActionPage({super.key});

  @override
  State<EmailActionPage> createState() => _EmailActionPageState();
}

class _EmailActionPageState extends State<EmailActionPage> {
  final TextEditingController _receivedEmailController =
      TextEditingController();
  final TextEditingController _mainIdeaController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('✅ [EmailActionPage] Page initialized');
  }

  @override
  void dispose() {
    print('❌ [EmailActionPage] Page disposed');
    _receivedEmailController.dispose();
    _mainIdeaController.dispose();
    _subjectController.dispose();
    _senderController.dispose();
    _receiverController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _handleGenerateEmail(BuildContext context) async {
    print('🚀 [EmailActionPage] Generate email button clicked');

    final receivedEmail = _receivedEmailController.text.trim();
    final mainIdea = _mainIdeaController.text.trim();

    print(
      '🚀 [EmailActionPage] Received email: ${receivedEmail.substring(0, receivedEmail.length > 50 ? 50 : receivedEmail.length)}...',
    );
    print('🚀 [EmailActionPage] Main idea: $mainIdea');

    if (receivedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập email đã nhận'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mainIdea.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ý chính muốn trả lời'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emailProvider = context.read<EmailProvider>();
    final styleProvider = context.read<EmailStyleProvider>();

    try {
      await emailProvider.replyEmail(
        email: receivedEmail,
        mainIdea: mainIdea,
        subject: _subjectController.text.trim().isEmpty
            ? 'Re: Email Reply'
            : _subjectController.text.trim(),
        sender: _senderController.text.trim().isEmpty
            ? 'User'
            : _senderController.text.trim(),
        receiver: _receiverController.text.trim().isEmpty
            ? 'Recipient'
            : _receiverController.text.trim(),
        length: styleProvider.length,
        formality: styleProvider.formality,
        tone: styleProvider.tone,
        language: 'vietnamese',
      );

      // Clear main idea input after successful reply
      if (mounted) {
        _mainIdeaController.clear();
      }

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmailStyleProvider()),
        ChangeNotifierProvider(
          create: (context) => EmailProvider(
            EmailService(context.read<ApiService>()),
            context.read<TokenUsageProvider>(),
          ),
        ),
      ],
      builder: (context, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      ReceivedEmailSection(
                        controller: _receivedEmailController,
                      ),
                      const SizedBox(height: 16),
                      EmailMetadataSection(
                        subjectController: _subjectController,
                        senderController: _senderController,
                        receiverController: _receiverController,
                      ),
                      const SizedBox(height: 16),
                      SuggestIdeasSection(
                        receivedEmailController: _receivedEmailController,
                        mainIdeaController: _mainIdeaController,
                      ),
                      const SizedBox(height: 16),
                      const EmailStyleSection(),
                      const SizedBox(height: 24),
                      const GeneratedEmailSection(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                MainIdeaInput(
                  controller: _mainIdeaController,
                  onSend: () => _handleGenerateEmail(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
      ),
      title: const Text(
        'AI Email Assistant',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email Reply Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI sẽ giúp bạn soạn email trả lời chuyên nghiệp',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
