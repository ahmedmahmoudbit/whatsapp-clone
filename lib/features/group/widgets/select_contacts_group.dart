import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';

class SelectContactsGroup extends StatefulWidget {
  const SelectContactsGroup({Key? key}) : super(key: key);

  @override
  State<SelectContactsGroup> createState() => _SelectContactsGroupState();
}

class _SelectContactsGroupState extends State<SelectContactsGroup> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
    cubit.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen: (previous, current) => current is SelectContactIndexSuccessState,
      builder: (context, state) {
        return Expanded(
          child: ListView.builder(
              itemCount: cubit.contacts.length,
              itemBuilder: (context, index) {
                final contact = cubit.contacts[index];
                return InkWell(
                  onTap: () => cubit.selectContactIndex(index),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: cubit.selectedContactsIndex.contains(index)
                          ? IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.done),) : null,
                    ),
                  ),
                );
              }),
        );
      },
    );
  }
}