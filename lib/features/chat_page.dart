import 'package:buildcondition/buildcondition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/models/call.dart';
import 'package:whatsapp/core/models/user_model.dart';
import 'package:whatsapp/core/widgets/bottom_chat_field.dart';
import 'package:whatsapp/core/widgets/callPickupScreen.dart';
import 'package:whatsapp/core/widgets/chat_list.dart';
import 'package:whatsapp/core/widgets/loader.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String id;
  final bool isGroupChat;
  final String profilePic;

  const ChatPage({
    Key? key,
    required this.name,
    required this.id,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);

    if (!widget.isGroupChat) {
      cubit.getUserDataById(widget.id).then((event) {
        getReceiverCallData(event);
        getSenderCallData(event);
        print('event: dats is =>  $event');
      });
    }

  }



  String callId = const Uuid().v1();
  callModel? receiverCallData;
  Future<callModel> getReceiverCallData(UserModel model) async {
    receiverCallData = callModel(
      callerId: model.uid,
      callerName: model.name,
      callerPic: model.profilePic,
      receiverId: cubit.userModel!.uid,
      receiverName: cubit.userModel!.name,
      receiverPic: cubit.userModel!.profilePic,
      callId: callId,
      hasDialled: false,
    );
    return receiverCallData!;
  }

  callModel? senderCallData;
  Future<callModel> getSenderCallData(UserModel model) async{
    senderCallData = callModel(
      callerId: widget.id,
      callerName: widget.name,
      callerPic: widget.profilePic,
      receiverId: model.uid,
      receiverName: model.name,
      receiverPic: model.profilePic,
      callId: callId,
      hasDialled: true,
    );
    return senderCallData!;
  }

  void makeCall(BuildContext context,
      callModel senderCallData,
      callModel recieverCallData) {
        cubit.makeCall(
      context,
      senderCallData,
      recieverCallData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return BuildCondition(
          condition: widget.isGroupChat ? true : cubit.sendUserModel != null,
          builder: (context)=> CallPickupScreen(
            scaffold: Scaffold(
              appBar: AppBar(
                backgroundColor: appBarColor,
                title: widget.isGroupChat ? Text(widget.name) :
                StreamBuilder<UserModel>(
                    stream: cubit.userData(widget.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Loader();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.name),
                          Text(
                            snapshot.data!.isOnline ? 'online' : 'offline',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: snapshot.data!.isOnline ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      );
                    }),
                centerTitle: false,
                actions: [
                  IconButton(
                    onPressed: () =>
                        cubit.makeCall(
                            context,
                            senderCallData!,
                            receiverCallData!),

                    icon: const Icon(Icons.video_call),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ChatList(
                      recieverUserId: widget.id,
                      isGroupChat: widget.isGroupChat,
                    ),
                  ),
                  BottomChatField(
                    recieverUserId: widget.id,
                    isGroupChat: widget.isGroupChat,
                  ),
                ],
              ),
            ),
          ),
          fallback: (context)=> const Loader(),
        );
      },
    );
  }
}
