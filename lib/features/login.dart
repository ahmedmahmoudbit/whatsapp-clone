import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/core/colors.dart';
import 'package:whatsapp/core/cubit/cubit.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'package:whatsapp/core/utils.dart';
import 'package:whatsapp/core/widgets/customButton.dart';
import 'package:whatsapp/features/otp.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final phoneController = TextEditingController();
  Country? country;
  late MainBloc cubit;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MainBloc>(context);
  }

  void pickCountry() {
    showCountryPicker(
        context: context,
        onSelect: (Country _country) {
          setState(() {
            country = _country;
          });
        });
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      cubit.signInWithPhone(phoneNumber: '+${country!.phoneCode}$phoneNumber');
    } else {
      showSnackBar(context: context, content: 'Fill out all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
        if (state is SendOtpSuccessState) {
          navigateTo(context, OTPScreen(verificationId: state.verificationId));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Enter your phone number'),
            elevation: 0,
            backgroundColor: backgroundColor,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('WhatsApp will need to verify your phone number.'),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: pickCountry,
                    child: const Text('Pick Country'),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (country != null) Text('+${country!.phoneCode}'),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: size.width * 0.7,
                        child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            hintText: 'phone number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.6),
                  SizedBox(
                    width: 90,
                    child: CustomButton(
                      onPressed: sendPhoneNumber,
                      text: 'NEXT',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
