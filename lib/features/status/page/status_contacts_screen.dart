import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/models/status_model.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/core/widgets/loader.dart';
import 'package:whatsapp/features/status/widgets/status_screen.dart';

class StatusContactsScreen extends StatefulWidget {
  const StatusContactsScreen({Key? key}) : super(key: key);


  @override
  State<StatusContactsScreen> createState() => _StatusContactsScreentate();
}

class _StatusContactsScreentate extends State<StatusContactsScreen> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return FutureBuilder<List<statusModel>>(
          future: cubit.getStatus(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var statusData = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          navigateTo(context, StatusScreen(status: statusData));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(
                              statusData.username,
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                statusData.profilePic,
                              ),
                              radius: 30,
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: dividerColor, indent: 85),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
