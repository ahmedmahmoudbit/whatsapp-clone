import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/features/user_information_screen.dart';

class OTPScreen extends StatefulWidget {
  static const String routeName = '/otp-screen';
  final String verificationId;

  const OTPScreen({
    Key? key,
    required this.verificationId,
  }) : super(key: key);


  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late MainBloc cubit;

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  void verifyOTP(String userOTP) {
    cubit.verifyOTP(
      userOTP: userOTP,
      verificationId: widget.verificationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return BlocListener<MainBloc, MainState>(
      listener: (context, state) {
        if (state is VerifyOtpSuccessState) {
          navigateTo(context, const UserInformationScreen());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifying your number'),
          elevation: 0,
          backgroundColor: backgroundColor,
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('We have sent an SMS with a code.'),
              SizedBox(
                width: size.width * 0.5,
                child: TextField(
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '- - - - - -',
                    hintStyle: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    if (val.length == 6) {
                      verifyOTP(val.trim());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}