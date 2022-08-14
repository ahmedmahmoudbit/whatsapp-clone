import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/enums.dart';
import 'package:whatsapp/core/models/replay_message.dart';
import 'package:whatsapp/core/widgets/display_text_image_gif.dart';

class MessageReplyPreview extends StatefulWidget {
  const MessageReplyPreview({
    Key? key,
    required this.message}) : super(key: key);

  final MessageReply message;

  @override
  State<MessageReplyPreview> createState() => _SMessageReplyPreviewState();
}

class _SMessageReplyPreviewState extends State<MessageReplyPreview> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  void cancelReply() {
    // print('object');
    cubit.messageReplyProvider(
      messageEnum: MessageEnum.text,
      message: '',
      isMe: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 350,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.message.isMe ? 'Me' : 'Opposite',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
                onTap: () => cancelReply(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DisplayTextImageGIF(
            message: widget.message.message,
            type: widget.message.messageEnum,
          ),
        ],
      ),
    );
  }
}
