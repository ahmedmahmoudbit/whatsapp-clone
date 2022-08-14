import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';

class ConfirmStatusScreen extends StatefulWidget {
  static const String routeName = '/confirm-status-screen';
  final File file;
  const ConfirmStatusScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<ConfirmStatusScreen> createState() => _ConfirmStatusScreenState();
}

class _ConfirmStatusScreenState extends State<ConfirmStatusScreen> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  void addStatus(BuildContext context) {
    cubit.uploadStatus(
        username: cubit.userModel!.name,
        profilePic: cubit.userModel!.profilePic,
        phoneNumber: cubit.userModel!.phoneNumber,
        statusImage: widget.file,
        context: context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(widget.file),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () => addStatus(context),
        backgroundColor: tabColor,
      ),
    );
  }
}
