import 'package:flutter/material.dart';
import 'package:sugenix/utils/responsive_layout.dart';
import 'package:sugenix/services/chat_history_service.dart';
import 'package:intl/intl.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatHistoryService _chatService = ChatHistoryService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      _chatService.getChatHistory(limit: 50).listen((firestoreMessages) {
        if (mounted && _isLoading) {
          setState(() {
            _messages.clear();
            if (firestoreMessages.isEmpty) {
              _addWelcomeMessage();
            } else {
              for (var msg in firestoreMessages) {
                _messages.add(ChatMessage(
                  text: msg['text'] as String? ?? '',
                  isUser: msg['isUser'] as bool? ?? false,
                  timestamp: msg['timestamp'] is DateTime 
                      ? msg['timestamp'] as DateTime 
                      : DateTime.now(),
                ));
              }
            }
            _isLoading = false;
          });
          _scrollToBottom();
        }
      });
    } catch (e) {
      setState(() {
        _addWelcomeMessage();
        _isLoading = false;
      });
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text: "Hello! I'm your AI health assistant. I can help you with diabetes-related questions, medication information, dietary advice, and general health guidance. How can I assist you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    
    // Save user message to Firebase
    await _chatService.saveMessage(text: userMessage, isUser: true);
    
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Generate and save AI response (UI only - no actual AI implementation)
    final aiResponse = _getAIResponse(userMessage);
    
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        // Save AI response to Firebase
        await _chatService.saveMessage(text: aiResponse, isUser: false);
        
        setState(() {
          _messages.add(ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('glucose') || lowerMessage.contains('sugar') || lowerMessage.contains('blood')) {
      return "For glucose management, monitor your levels regularly. Normal fasting glucose should be 70-100 mg/dL, and post-meal should be below 180 mg/dL. Make sure to take your medications as prescribed and maintain a balanced diet.";
    } else if (lowerMessage.contains('medication') || lowerMessage.contains('medicine') || lowerMessage.contains('drug')) {
      return "It's important to take your medications as prescribed by your doctor. Never skip doses and always check with your healthcare provider before making any changes. You can scan your medicine using the medicine scanner for detailed information.";
    } else if (lowerMessage.contains('diet') || lowerMessage.contains('food') || lowerMessage.contains('eat')) {
      return "A balanced diet is crucial for diabetes management. Focus on whole grains, lean proteins, plenty of vegetables, and limit processed foods and sugars. Consider consulting the wellness recommendations section for personalized meal plans.";
    } else if (lowerMessage.contains('exercise') || lowerMessage.contains('workout') || lowerMessage.contains('activity')) {
      return "Regular physical activity helps control blood sugar levels. Aim for at least 150 minutes of moderate exercise per week, such as brisk walking. Always check your glucose before and after exercise, and stay hydrated.";
    } else if (lowerMessage.contains('emergency') || lowerMessage.contains('help') || lowerMessage.contains('urgent')) {
      return "If you're experiencing a medical emergency, please use the Emergency SOS feature in the app or call your local emergency services immediately. The app can share your health data with paramedics for better care.";
    } else {
      return "Thank you for your question. I'm here to help with diabetes management, medication information, dietary advice, and general health guidance. Would you like more specific information about any of these topics?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C4556).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.psychology,
                color: Color(0xFF0C4556),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "AI Assistant",
              style: TextStyle(
                color: Color(0xFF0C4556),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: ResponsiveHelper.getResponsivePadding(context),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
            ),
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
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF0C4556).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 60,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "AI Health Assistant",
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Ask me anything about diabetes management, medications, diet, exercise, or general health.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: const Color(0xFF0C4556),
                borderRadius: BorderRadius.circular(17.5),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF0C4556)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      color: message.isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isUser
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(17.5),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              decoration: InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0C4556),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
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

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

