import 'package:buildcondition/buildcondition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/core/widgets/errorScreen.dart';
import 'package:whatsapp/core/widgets/loader.dart';
import 'package:whatsapp/features/chat_page.dart';

class SelectContactsScreen extends StatefulWidget {

  const SelectContactsScreen({Key? key}) : super(key: key);


  @override
  State<SelectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<SelectContactsScreen> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
    cubit.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
       if (state is SelectContactSuccessState) {
         // navigateTo(context, ChatPage(
         //     name: c,
         //     uid: uid,
         //     isGroupChat: isGroupChat,
         //     profilePic: profilePic
         // ));
       }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select contact'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                ),
              ),
            ],
          ),
          body: buildBuildCondition(),
        );
      },
    );
  }

  BuildCondition buildBuildCondition() {
    return BuildCondition(
      condition: cubit.contacts.isNotEmpty,
      builder: (BuildContext context) =>
          ListView.builder(
              itemCount: cubit.contacts.length,
              itemBuilder: (context, index) {
                final contact = cubit.contacts[index];
                return InkWell(
                  onTap: () {
                    cubit.selectContact(contact, context).then((value) {
                      navigateTo(context, ChatPage(
                              name: contact.displayName.toString(),
                              id: uidSec,
                              isGroupChat: false,
                              profilePic: 'https://www.seekpng.com/png/detail/847-8474751_download-empty-profile.png',
                          ));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: contact.photo == null
                          ? null
                          : CircleAvatar(
                        backgroundImage: MemoryImage(contact.photo!),
                        radius: 30,
                      ),
                    ),
                  ),
                );
              }),
      fallback: (BuildContext context) => const Loader(),
    );
  }
}
