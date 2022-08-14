import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/models/call.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/features/call_screen.dart';

class CallPickupScreen extends StatefulWidget {
  final Widget scaffold;

  const CallPickupScreen({
    Key? key,
    required this.scaffold,
  }) : super(key: key);

  @override
  State<CallPickupScreen> createState() => _CallPickupScreenState();
}

class _CallPickupScreenState extends State<CallPickupScreen> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
        if (state is MakeCallSuccessState) {
          // navigateTo(context, CallScreen());


          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CallScreen(
          //       channelId: senderCallData.callId,
          //       call: senderCallData,
          //       isGroupChat: false,
          //     ),
          //   ),
          // );

        }
      },
      builder: (context, state) {
        return StreamBuilder<DocumentSnapshot>(
          stream: cubit.callStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.data() != null) {
              callModel call =
              callModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              if (!call.hasDialled) {
                return Scaffold(
                  body: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Incoming Call',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 50),
                        CircleAvatar(
                          backgroundImage: NetworkImage(call.callerPic),
                          radius: 60,
                        ),
                        const SizedBox(height: 50),
                        Text(
                          call.callerName,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 75),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.call_end,
                                  color: Colors.redAccent),
                            ),
                            const SizedBox(width: 25),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CallScreen(
                                          channelId: call.callId,
                                          call: call,
                                          isGroupChat: false,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return widget.scaffold;
          },
        );
      },
    );
  }
}
