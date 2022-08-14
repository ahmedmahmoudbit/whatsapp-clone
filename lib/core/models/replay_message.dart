import 'package:whatsapp/core/enums.dart';

class MessageReply {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReply(this.message, this.isMe, this.messageEnum);
}

// final messageReplyProvider = StateProvider<MessageReply?>((ref) => null);
final messageReplyProvider = null;
