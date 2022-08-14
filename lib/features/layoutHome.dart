import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/core/widgets/contacts_list.dart';
import 'package:whatsapp/features/group/page/create_group_screen.dart';
import 'package:whatsapp/features/select_contacts.dart';
import 'package:whatsapp/features/status/page/status_contacts_screen.dart';
import 'package:whatsapp/features/status/widgets/confirm_status_screen.dart';

class MobileLayoutScreen extends StatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends State<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        cubit.setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        cubit.setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: appBarColor,
              centerTitle: false,
              title: const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  onPressed: () {
                    navigateTo(context, CreateGroupScreen());
                  },
                ),
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text(
                        'Create Group',
                      ),
                      onTap: () {
                        navigateTo(context, CreateGroupScreen());
                        print('null');
                      },
                    )
                  ],
                ),
              ],
              bottom: TabBar(
                controller: tabBarController,
                indicatorColor: tabColor,
                indicatorWeight: 4,
                labelColor: tabColor,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(
                    text: 'CHATS',
                  ),
                  Tab(
                    text: 'STATUS',
                  ),
                  Tab(
                    text: 'CALLS',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: tabBarController,
              children: const [
                ContactsList(),
                StatusContactsScreen(),
                Text('Calls')
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (tabBarController.index == 0) {
                  navigateTo(context, SelectContactsScreen());
                } else {
                  File? pickedImage = await pickImageFromGallery(context);
                  if (pickedImage != null) {
                    navigateTo(context, ConfirmStatusScreen(file: pickedImage));
                  }
                }
              },
              backgroundColor: tabColor,
              child: const Icon(
                Icons.comment,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
