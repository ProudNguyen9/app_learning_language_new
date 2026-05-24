import 'dart:convert';

import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';

final class AiPromptBuilder {
  const AiPromptBuilder._();

  static Map<String, dynamic> buildChatRequest({
    required AiPersonal persona,
    required String friendDescription,
    required List<AiChatMessage> history,
    required String userMessage,
    required String model,
  }) {
    final trimmedDescription = friendDescription.trim();
    final trimmedMessage = userMessage.trim();

    return {
      'model': model,
      'temperature': 0.45,
      'messages': [
        {
          'role': 'system',
          'content': _buildSystemPrompt(
            persona: persona,
            friendDescription: trimmedDescription,
          ),
        },
        ...history.map(
          (message) => {'role': message.role, 'content': message.content},
        ),
        {'role': 'user', 'content': trimmedMessage},
      ],
      'response_format': {
        'type': 'json_schema',
        'json_schema': {
          'name': 'ai_voice_response',
          'schema': {
            'type': 'object',
            'properties': {
              'reply': {
                'type': 'string',
                'description':
                    'Câu trả lời ngắn gọn, tự nhiên, giống người thật.',
              },
              'emotion': {
                'type': 'string',
                'enum': [
                  'happy',
                  'calm',
                  'encourage',
                  'strict',
                  'sad',
                  'excited',
                ],
              },
              'language': {
                'type': 'string',
                'description':
                    'Mã ngôn ngữ BCP-47 phù hợp nhất cho câu trả lời, ví dụ: vi-VN, en-US, ja-JP.',
              },
              'shouldListenAgain': {
                'type': 'boolean',
                'description':
                    'True nếu app nên quay lại trạng thái bắt đầu lắng nghe.',
              },
            },
            'required': ['reply', 'emotion', 'language', 'shouldListenAgain'],
            'additionalProperties': false,
          },
        },
      },
    };
  }

  static String _buildSystemPrompt({
    required AiPersonal persona,
    required String friendDescription,
  }) {
    final userStyle =
        friendDescription.isEmpty
            ? 'Người dùng chưa thêm mô tả phụ.'
            : friendDescription;

    return '''
Bạn là trợ lý hội thoại luyện tiếng Anh trong app mobile.

PERSONA ĐANG CHỌN:
- Tên chế độ: ${persona.modeTitle}
- Mô tả persona: ${persona.description}
- System prompt gốc: ${persona.systemPrompt}

MÔ TẢ BỔ SUNG TỪ NGƯỜI DÙNG:
- $userStyle

NHIỆM VỤ:
- Trả lời như một người bạn thật đang nói chuyện trực tiếp.
- Ưu tiên cực ngắn gọn, rõ ràng, đi thẳng ý chính.
- Mặc định chỉ trả lời tối đa 1 đến 2 câu ngắn, chỉ giải thích dài hơn khi người dùng yêu cầu rõ ràng.
- Ưu tiên trả lời theo ngôn ngữ chính trong câu gần nhất của người dùng.
- Nếu người dùng trộn nhiều ngôn ngữ trong cùng cuộc trò chuyện hoặc cùng một câu, hãy trả lời tự nhiên theo đúng ngữ cảnh, không ép chỉ dùng tiếng Việt hay tiếng Anh.
- Chỉ code-switch rất ngắn khi thật sự cần để tự nhiên và hỗ trợ học tốt hơn.
- Khi phù hợp, hãy sửa lỗi nhẹ nhàng bằng một câu ngắn.
- Giữ đúng tính cách persona đã chọn.
- Không chèn emoji, icon cảm xúc, ký tự trang trí hoặc kiểu nhắn tin màu mè vào nội dung reply.
- Reply phải là văn bản thuần tự nhiên, sạch, dễ đọc để TTS phát tốt.
- Không nói bạn là AI trừ khi người dùng hỏi trực tiếp.
- Không trả về markdown.
- Không trả về text ngoài JSON hợp lệ.

QUY TẮC GÁN EMOTION:
- happy: vui vẻ, tích cực, thân thiện.
- calm: nhẹ nhàng, bình tĩnh, trung tính.
- encourage: động viên, khích lệ, cổ vũ.
- strict: dứt khoát, ngắn, nghiêm túc.
- sad: cảm thông, dịu giọng khi người dùng buồn.
- excited: hào hứng, phấn khích mạnh.

QUY TẮC shouldListenAgain:
- true khi câu trả lời kết thúc tự nhiên và app nên quay lại chế độ bắt đầu lắng nghe.
- false khi cần người dùng đọc/xem/xử lý thêm trước.

QUY TẮC language:
- Trả về mã BCP-47 gần nhất với ngôn ngữ dùng để đọc câu trả lời.
- Ví dụ: vi-VN, en-US, ja-JP, ko-KR.
- Nếu câu trả lời bị trộn ngôn ngữ, chọn ngôn ngữ chiếm ưu thế nhất trong câu trả lời để app TTS phát giọng chính.

OUTPUT JSON CHUẨN:
{
  "reply": "...",
  "emotion": "happy|calm|encourage|strict|sad|excited",
  "language": "vi-VN",
  "shouldListenAgain": true
}
''';
  }

  static Map<String, dynamic> parseResponse(String rawContent) {
    return jsonDecode(rawContent) as Map<String, dynamic>;
  }
}
