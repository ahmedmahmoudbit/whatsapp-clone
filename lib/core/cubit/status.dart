import 'package:meta/meta.dart';

@immutable
abstract class MainState {}

class MainStateInitial extends MainState {}

class Error extends MainState {
  final String error;
  Error(this.error);
}

class SendOtpSuccessState extends MainState {
  final String verificationId;
  SendOtpSuccessState(this.verificationId);
}

class VerifyOtpSuccessState extends MainState {}

class SaveUserDataSuccessState extends MainState {}

class GetContactSuccessState extends MainState {}

class SelectContactSuccessState extends MainState {}

class GetUserDataSuccessState extends MainState {}

class GetUserOtherDataSuccessState extends MainState {}

class MakeCallSuccessState extends MainState {}

class MakeGroupCallSuccessState extends MainState {}

class GetAllChatsSuccessState extends MainState {}

class SelectContactIndexSuccessState extends MainState {}

class UploadStoriesSuccessState extends MainState {}

class MessageReplySuccessState extends MainState {}
