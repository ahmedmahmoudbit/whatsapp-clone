import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/enums.dart';
import 'package:whatsapp/core/models/message.dart';
import 'package:whatsapp/core/models/replay_message.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/core/widgets/loader.dart';
import 'package:whatsapp/core/widgets/my_message_card.dart';
import 'package:whatsapp/core/widgets/sender_message_card.dart';

class ChatList extends StatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;

  const ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late MainBloc cubit;
  final ScrollController messageController = ScrollController();

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  // void cubit.messageReplyProvider(
  //     String message,
  //     bool isMe,
  //     MessageEnum messageEnum,
  //     ) {
  //   MessageReply(
  //     message,
  //     isMe,
  //     messageEnum,
  //   );
  //   // messageReplyProvider.state.update(
  //   //       (state) => MessageReply(
  //   //     message,
  //   //     isMe,
  //   //     messageEnum,
  //   //   ),
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<messageModel>>(
        stream: widget.isGroupChat
            ? cubit.getGroupChatStream(widget.recieverUserId)
            : cubit.getChatStream(recieverUserId: widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController
                .jumpTo(messageController.position.maxScrollExtent);
          });

          return BlocBuilder<MainBloc, MainState>(
            builder: (context, state) {
              return ListView.builder(
                controller: messageController,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final messageData = snapshot.data![index];
                  var timeSent = DateFormat.Hm().format(messageData.timeSent);

                  if (!messageData.isSeen &&
                      messageData.recieverid ==
                          uid) {
                    cubit.setChatMessageSeen(
                      context,
                      widget.recieverUserId,
                      messageData.messageId,
                    );
                  }
                  if (messageData.senderId == uid) {
                    return MyMessageCard(
                      message: messageData.text,
                      date: timeSent,
                      type: messageData.type,
                      repliedText: messageData.repliedMessage,
                      username: messageData.repliedTo,
                      repliedMessageType: messageData.repliedMessageType,
                      onLeftSwipe: () {
                        cubit.messageReplyProvider(
                          message: messageData.text,
                          isMe: true,
                          messageEnum: messageData.type,
                        );
                      },
                      isSeen: messageData.isSeen,
                    );
                  }
                  return SenderMessageCard(
                    isGroupChat: widget.isGroupChat,
                    message: messageData.text,
                    date: timeSent,
                    name: messageData.name,
                    type: messageData.type,
                    username: messageData.repliedTo,
                    repliedMessageType: messageData.repliedMessageType,
                    onRightSwipe: () {
                      cubit.messageReplyProvider(
                        message: messageData.text,
                        isMe: false,
                        messageEnum: messageData.type,
                      );
                    },

                    repliedText: messageData.repliedMessage,
                  );
                },
              );
            },
          );
        });
  }
}