import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/enums.dart';
import 'package:whatsapp/core/widgets/display_text_image_gif.dart';

class MyMessageCard extends StatefulWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onLeftSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final bool isSeen;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
    required this.isSeen,
  }) : super(key: key);

  @override
  State<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends State<MyMessageCard> {
  late MainBloc cubit;
  @override
  void initState() {
    super.initState();
    cubit  = BlocProvider.of<MainBloc>(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final isReplying = widget.repliedText.isNotEmpty;

    return BlocBuilder<MainBloc, MainState>(
  builder: (context, state) {
    return SwipeTo(
      onLeftSwipe: widget.onLeftSwipe,
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: widget.type == MessageEnum.text
                      ? const EdgeInsets.only(
                    left: 10,
                    right: 45,
                    top: 5,
                    bottom: 25,
                  )
                      : const EdgeInsets.only(
                    left: 10,
                    top: 10,
                    right: 10,
                    bottom: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isReplying) ...[
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: backgroundColor.withOpacity(.5),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  DisplayTextImageGIF(
                                    message: widget.repliedText,
                                    type: widget.repliedMessageType,
                                  )
                                ],
                              ),
                            ),
                            Container(color: Colors.blue,width: 3,height: 40,),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      DisplayTextImageGIF(
                        message: widget.message,
                        type: widget.type,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 0,
                  child: Row(
                    children: [
                      Text(
                        widget.date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Icon(
                        widget.isSeen ? Icons.done_all : Icons.done,
                        size: 20,
                        color: widget.isSeen ? Colors.blue : Colors.white60,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }
}
