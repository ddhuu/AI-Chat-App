import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/api_service.dart';
import '../models/ai_agent_model.dart';
import '../services/ai_agent_service.dart';
import '../widgets/typing_animation_text.dart';

class WeatherAgentChatPage extends StatefulWidget {
  final AiAgent agent;

  const WeatherAgentChatPage({super.key, required this.agent});

  @override
  State<WeatherAgentChatPage> createState() => _WeatherAgentChatPageState();
}

class _WeatherAgentChatPageState extends State<WeatherAgentChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late AiAgentService _agentService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Use ApiService from context for proper backend integration
    final apiService = context.read<ApiService>();
    _agentService = AiAgentService(apiService);
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'Xin chào! Tôi là Weather Agent. Hãy hỏi tôi về thời tiết của bất kỳ thành phố nào.\n\nVí dụ: "Thời tiết hiện tại của Hồ Chí Minh"',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isProcessing) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isProcessing = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Show single processing message
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Đang thực thi flow',
            isUser: false,
            timestamp: DateTime.now(),
            isProcessing: true,
          ),
        );
      });
      _scrollToBottom();

      // Step 1: Extract city from message
      final city = await _agentService.extractCityFromMessage(message);

      // Step 2: Call weather agent with extracted city
      final response = await _agentService.callWeatherAgent(
        webhookUrl: widget.agent.webhookUrl,
        city: city,
      );

      // Step 3: Format response using AI
      String formattedMessage;
      if (response.isSuccess && response.data != null) {
        formattedMessage = await _agentService.formatWeatherResponse(
          response.data!,
        );
      } else {
        formattedMessage =
            'Xin lỗi, không thể lấy thông tin thời tiết. ${response.error ?? "Vui lòng thử lại."}';
      }

      // Remove processing message and show final result with typing animation
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(
            text: formattedMessage,
            isUser: false,
            timestamp: DateTime.now(),
            isTyping:
                response.isSuccess, // Enable typing animation only for success
            isError: !response.isSuccess,
          ),
        );
      });
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && _messages.last.isProcessing) {
          _messages.removeLast();
        }
        _messages.add(
          ChatMessage(
            text: 'Đã xảy ra lỗi: $e',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(widget.agent.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.agent.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'AI Agent',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.agent.icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            widget.agent.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.agent.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  widget.agent.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primary
                    : message.isError
                    ? Colors.red.shade50
                    : message.isProcessing
                    ? Colors.blue.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: message.isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: message.isProcessing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const TypingIndicator(),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            message.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    )
                  : message.isTyping
                  ? TypingAnimationText(
                      text: message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: message.isUser
                            ? Colors.white
                            : message.isError
                            ? Colors.red.shade700
                            : AppColors.textPrimary,
                        height: 1.4,
                      ),
                      onComplete: () {
                        setState(() {
                          final index = _messages.indexOf(message);
                          if (index != -1) {
                            _messages[index] = ChatMessage(
                              text: message.text,
                              isUser: message.isUser,
                              timestamp: message.timestamp,
                              isTyping: false,
                            );
                          }
                        });
                      },
                    )
                  : Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: message.isUser
                            ? Colors.white
                            : message.isError
                            ? Colors.red.shade700
                            : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.person, size: 18, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                hintText: 'Hỏi về thời tiết...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _isProcessing ? Colors.grey.shade300 : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isProcessing ? null : _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isProcessing;
  final bool isError;
  final bool isTyping;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isProcessing = false,
    this.isError = false,
    this.isTyping = false,
  });
}
