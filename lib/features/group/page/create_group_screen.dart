import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/features/group/widgets/select_contacts_group.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late MainBloc cubit;
  final TextEditingController groupNameController = TextEditingController();
  File? image;


  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }


  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text
        .trim()
        .isNotEmpty && image != null) {
      cubit.createGroup(
        context,
        groupNameController.text.trim(),
        image!,
        cubit.numberPhones,
        );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    groupNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Group'),
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Stack(
                  children: [
                    image == null
                        ? const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                      ),
                      radius: 64,
                    )
                        : CircleAvatar(
                      backgroundImage: FileImage(
                        image!,
                      ),
                      radius: 64,
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(
                          Icons.add_a_photo,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: groupNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Group Name',
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    'Select Contacts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SelectContactsGroup(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: createGroup,
            backgroundColor: tabColor,
            child: const Icon(
              Icons.done,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}