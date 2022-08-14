import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp/core/cubit/status.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp/core/enums.dart';
import 'package:whatsapp/core/models/call.dart';
import 'package:whatsapp/core/models/chat_contact.dart';
import 'package:whatsapp/core/models/group.dart';
import 'package:whatsapp/core/models/message.dart';
import 'package:whatsapp/core/models/replay_message.dart';
import 'package:whatsapp/core/models/status_model.dart';
import 'package:whatsapp/core/models/user_model.dart';
import 'package:whatsapp/core/utils.dart';


class MainBloc extends Cubit<MainState> {
  MainBloc() : super(MainStateInitial());

  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance;

  void signInWithPhone({required String phoneNumber}) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 50),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: ((String verificationId, int? resendToken) async {
          emit(SendOtpSuccessState(verificationId));
          print('code sent is $verificationId');
          // Navigator.pushNamed(
          //   context,
          //   OTPScreen.routeName,
          //   arguments: verificationId,
          // );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      emit(Error(e.toString()));
      // showSnackBar(context: context, content: e.message!);
    }
  }

  void verifyOTP({
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      emit(VerifyOtpSuccessState());
      print('OTP verified');
    } on FirebaseAuthException catch (e) {
      emit(Error(e.toString()));
      print('OTP is not verified');
    }
  }


  void saveUserDataToFirebase(String name, File? profilePic) async {

    String photoUrl = 'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

    if (profilePic != null) {
      await storeFileToFirebase(
        'profilePic/$uid',
        profilePic,
      ).then((value) {
        photoUrl = value;
      });
      print('photoUrl is $photoUrl');
    }

    var user = UserModel(
      name: name,
      uid: uid,
      profilePic: photoUrl,
      isOnline: true,
      phoneNumber: auth.currentUser!.phoneNumber!,
      groupId: [],
    );

    await fireStore.collection('users').doc(uid).set(user.toMap()).then((value) {
      emit(SaveUserDataSuccessState());
    }).catchError((onError){
      emit(Error(onError.toString()));
    });
  }

  Future<String> storeFileToFirebase(String ref, File file) async {
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  UserModel? userModel;
  Future<void> getUserData({required String uid}) async {
    await fireStore.collection('users').doc(uid).get().then((value) {
      userModel = UserModel.fromMap(value.data()!);
      emit(GetUserDataSuccessState());
    }).catchError((onError){
      emit(Error(onError.toString()));
    });
  }

  UserModel? sendUserModel;
  Future<UserModel> getUserDataById(String userId) async {
    await fireStore.collection('users').doc(userId).get().then((value){
      sendUserModel = UserModel.fromMap(value.data()!);
      print('sendUserModel is ${sendUserModel}');
      emit(GetUserOtherDataSuccessState());
    }).catchError((onError)=>
        emit(Error(onError.toString()))
      );

     return sendUserModel!;
  }

  void setUserState(bool isOnline) {
    fireStore.collection('users').doc(uid).update({
      'isOnline': isOnline,
    });
  }

  List<Contact> contacts = [];
  Future<List<Contact>> getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        print('contacts are ${contacts.length}');
      }
      emit(GetContactSuccessState());
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  Future selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await fireStore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
          ' ',
          '',
        );
        if (selectedPhoneNum == userData.phoneNumber) {
          isFound = true;
          emit(SelectContactSuccessState());
          // Navigator.pushNamed(
          //   context,
          //   MobileChatScreen.routeName,
          //   arguments: {
          //     'name': userData.name,
          //     'uid': userData.uid,
          //   },
          // );
        }
      }

      if (!isFound) {
        showSnackBar(
          context: context,
          content: 'This number does not exist on this app.',
        );
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<DocumentSnapshot> get callStream =>
      fireStore.collection('call').doc(uid).snapshots();

  void _saveDataToContactsSubcollection(
      UserModel senderUserData,
      UserModel? recieverUserData,
      String text,
      DateTime timeSent,
      String recieverUserId,
      bool isGroupChat,
      ) async {
    if (isGroupChat) {
      await fireStore.collection('groups').doc(recieverUserId).update({
        'lastMessage': text,
        'timeSent': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
// users -> reciever user id => chats -> current user id -> set data
      var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await fireStore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(uid)
          .set(
        recieverChatContact.toMap(),
      );
      // users -> current user id  => chats -> reciever user id -> set data
      var senderChatContact = ChatContact(
        name: recieverUserData!.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await fireStore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(recieverUserId)
          .set(
        senderChatContact.toMap(),
      );
    }
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String? recieverUserName,
    required bool isGroupChat,
  }) async {
    final message = messageModel(
      name: username,
      senderId: uid,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
          ? senderUsername
          : recieverUserName ?? '',
      repliedMessageType:
      messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    if (isGroupChat) {
      // groups -> group id -> chat -> message
      await fireStore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(
        message.toMap(),
      );
    } else {
      // users -> sender id -> reciever id -> messages -> message id -> store message
      await fireStore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(
        message.toMap(),
      );
      // users -> eciever id  -> sender id -> messages -> message id -> store message
      await fireStore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .doc(messageId)
          .set(
        message.toMap(),
      );
    }
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
        await fireStore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await storeFileToFirebase(
        'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
        file,
      );

      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap =
        await fireStore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;

      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }
      _saveDataToContactsSubcollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUserData.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void sendGIFMessage({
    required BuildContext context,
    required String gifUrl,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;

      if (!isGroupChat) {
        var userDataMap =
        await fireStore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      _saveDataToContactsSubcollection(
        senderUser,
        recieverUserData,
        'GIF',
        timeSent,
        recieverUserId,
        isGroupChat,
      );

      int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
      String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
      String newgifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';


      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: newgifUrl,
        timeSent: timeSent,
        messageType: MessageEnum.gif,
        messageId: messageId,
        username: senderUser.name,
        messageReply: messageReply,
        recieverUserName: recieverUserData?.name,
        senderUsername: senderUser.name,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> userData(String userId) {
    return fireStore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(
        event.data()!,
      ),
    );
  }

  Stream<List<messageModel>> getChatStream({required String recieverUserId}) {
    return fireStore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<messageModel> messages = [];
      for (var document in event.docs) {
        messages.add(messageModel.fromMap(document.data()));
      }
      return messages;
    });
  }

  List<ChatContact> contactsData = [];
  Stream<List<ChatContact>> getChatContacts() {
    return fireStore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      contactsData = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await fireStore
            .collection('users')
            .doc(chatContact.contactId.trim())
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contactsData.add(
          ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contactsData;
    });
  }

  Stream<List<groupModel>> getChatGroups() {
    return fireStore.collection('groups').snapshots().map((event) {
      List<groupModel> groups = [];
      for (var document in event.docs) {
        var group = groupModel.fromMap(document.data());
        if (group.membersUid.contains(auth.currentUser!.uid)) {
          groups.add(group);
        }
      }
      return groups;
    });
  }

  Stream<List<messageModel>> getGroupChatStream(String groudId) {
    return fireStore
        .collection('groups')
        .doc(groudId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<messageModel> messages = [];
      for (var document in event.docs) {
        messages.add(messageModel.fromMap(document.data()));
      }
      return messages;
    });
  }

  List<int> selectedContactsIndex = [];
  List<String> numberPhones = [];
  void selectContactIndex(int index) {
    numberPhones = [];
    // var search = contacts[index].phones[0].number.replaceAll(' ', '');
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.remove(index);
    } else {
      selectedContactsIndex.add(index);
    }
    for (var i in selectedContactsIndex) {
      var phone = contacts[i].phones[0].number.replaceAll(' ', '');
      if (phone.startsWith(' ')) {
        phone = phone.substring(1);
      }
      numberPhones.add(phone);
    }
    print('numberPhones:  is --- $numberPhones');
    emit(SelectContactIndexSuccessState());
  }
  void createGroup(
      BuildContext context,
      String name,
      File profilePic,
      List<String> phones,
      ) async {
    try {
      List<String> uids = [];
      for (int i = 0; i < phones.length; i++) {
        var userCollection = await fireStore
            .collection('users')
            .where(
          'phoneNumber',
          isEqualTo: phones[i],
          )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid'].toString().replaceAll(' ', ''));
        }
        print('$uids');
      }
      var groupId = const Uuid().v1();

      String profileUrl = await storeFileToFirebase(
        'group/$groupId',
        profilePic,
      );

      groupModel group = groupModel(
        senderId: uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl,
        membersUid: [uid, ...uids],
        timeSent: DateTime.now(),
      );

      await fireStore.collection('groups').
      doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
      BuildContext context,
      String recieverUserId,
      String messageId,
      ) async {
    try {
      await fireStore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await fireStore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }


  void makeCall(
      BuildContext context,
      callModel senderCallData,
      callModel receiverCallData,
      ) async {
    try {
      await fireStore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());
      await fireStore
          .collection('call')
          .doc(senderCallData.receiverId)
          .set(receiverCallData.toMap());

      emit(MakeCallSuccessState());

    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void makeGroupCall(
      callModel senderCallData,
      BuildContext context,
      callModel receiverCallData,
      ) async {
    try {
      await fireStore
          .collection('call')
          .doc(senderCallData.callerId)
          .set(senderCallData.toMap());

      var groupSnapshot = await fireStore
          .collection('groups')
          .doc(senderCallData.receiverId)
          .get();
      groupModel group = groupModel.fromMap(groupSnapshot.data()!);

      for (var id in group.membersUid) {
        await fireStore
            .collection('call')
            .doc(id)
            .set(receiverCallData.toMap());
      }
        emit(MakeGroupCallSuccessState());
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CallScreen(
      //       channelId: senderCallData.callId,
      //       call: senderCallData,
      //       isGroupChat: true,
      //     ),
      //   ),
      // );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endCall(
      String callerId,
      String receiverId,
      BuildContext context,
      ) async {
    try {
      await fireStore.collection('call').doc(callerId).delete();
      await fireStore.collection('call').doc(receiverId).delete();
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void endGroupCall(
      String callerId,
      String receiverId,
      BuildContext context,
      ) async {
    try {
      await fireStore.collection('call').doc(callerId).delete();
      var groupSnapshot =
      await fireStore.collection('groups').doc(receiverId).get();
      groupModel group = groupModel.fromMap(groupSnapshot.data()!);
      for (var id in group.membersUid) {
        await fireStore.collection('call').doc(id).delete();
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<statusModel>> getStatus(BuildContext context) async {
    List<statusModel> statusData = [];
    try {
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnapshot = await fireStore
            .collection('status')
            .where(
          'phoneNumber',
          isEqualTo: contacts[i].phones[0].number.replaceAll(
            ' ',
            '',
          ),
        )
            .where(
          'createdAt',
          isGreaterThan: DateTime.now()
              .subtract(const Duration(hours: 24))
              .millisecondsSinceEpoch,
        )
            .get();
        for (var tempData in statusesSnapshot.docs) {
          statusModel tempStatus = statusModel.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      var statusId = const Uuid().v1();
      String imageurl = await storeFileToFirebase(
        '/status/$statusId$uid',
        statusImage,
      );
      List<Contact> contacts = [];
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      List<String> uidWhoCanSee = [];

      for (int i = 0; i < contacts.length; i++) {
        var userDataFirebase = await fireStore
            .collection('users')
            .where(
          'phoneNumber',
          isEqualTo: contacts[i].phones[0].number.replaceAll(
            ' ',
            '',
          ),
        )
            .get();

        if (userDataFirebase.docs.isNotEmpty) {
          var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoCanSee.add(userData.uid);
        }
      }

      List<String> statusImageUrls = [];
      var statusesSnapshot = await fireStore
          .collection('status')
          .where(
        'uid',
        isEqualTo: uid,
      )
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        statusModel status = statusModel.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageurl);
        await fireStore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [imageurl];
      }

      statusModel status = statusModel(
        uid: uid,
        username: username,
        phoneNumber: phoneNumber,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: uidWhoCanSee,
      );

      await fireStore.collection('status').
        doc(statusId).set(status.toMap());
      print('data is done');
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    emit(UploadStoriesSuccessState());
  }

  MessageReply? reply;
  void messageReplyProvider({
    required String message,
    required bool isMe,
    required MessageEnum messageEnum,
      }) {
    reply = MessageReply(
      message,
      isMe,
      messageEnum,
    );
    emit(MessageReplySuccessState());
  }

}