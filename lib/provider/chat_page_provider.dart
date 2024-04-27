import 'dart:async';
import 'package:chat_app/Services/cloud_storage_service.dart';
import 'package:chat_app/Services/database_service.dart';
import 'package:chat_app/Services/media_service.dart';
import 'package:chat_app/Services/navigation_service.dart';
import 'package:chat_app/provider/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';

import '../models/chat_message.dart';

class ChatPageProvider extends ChangeNotifier {
  late DatabaseService _db;
  late CloudStorageService _storage;
  late MediaService _media;
  late NavigationService _navigation;

  AuthenticationProvider _auth;
  ScrollController _messagesListViewController;

  String _chatId;

  List<ChatMessage>? messages;

  late StreamSubscription _messageStream;
  String? _message;

  String get message {
    return message;
  }

  void set message(String _value) {
    _message = _value;
  }

  ChatPageProvider(this._chatId, this._auth, this._messagesListViewController) {
    _db = GetIt.instance.get<DatabaseService>();
    _storage = GetIt.instance.get<CloudStorageService>();
    _media = GetIt.instance.get<MediaService>();
    _navigation = GetIt.instance.get<NavigationService>();
    listenToMessages();
  }

  @override
  void dispose() {
    _messageStream.cancel();
    super.dispose();
  }

  void listenToMessages() {
    try {
      _messageStream = _db.streamMessagesForChat(_chatId).listen((_snapshot) {
        List<ChatMessage> _messages = _snapshot.docs.map(
          (_m) {
            Map<String, dynamic> _messageData =
                _m.data() as Map<String, dynamic>;
            return ChatMessage.fromJSON(_messageData);
          },
        ).toList();
        messages = _messages;
        notifyListeners();

        // add Scroll to bottom call;
      });
    } catch (e) {
      print("error Getting messages ");
      print(e);
    }
  }

  void sendTextMessage() {
    if (_message != null) {
      ChatMessage _messageToSent = ChatMessage(
          content: _message!,
          type: MessageType.TEXT,
          senderID: _auth.user.uid,
          sentTime: DateTime.now());

      _db.addMessageToChat(_chatId, _messageToSent);
      print("===================================================");
      print('The Message was sent');
    }

  }

  void sendImageMessage() async {
    try {
      PlatformFile? _file = await _media.pickImageFromLibrary();
      if (_file != null) {
        String? _downloadURL = await _storage.saveChatImageToStorage(
            _chatId, _auth.user.uid, _file);

        ChatMessage _messageToSent = ChatMessage(
            content: _downloadURL!,
            type: MessageType.IMAGE,
            senderID: _auth.user.uid,
            sentTime: DateTime.now()
        );
        _db.addMessageToChat(_chatId, _messageToSent);

      }
    } catch (e) {
      print(e);
    }
  }

  void deleteChat() {
    goBack();
    _db.deleteChat(_chatId);
  }

  void goBack() {
    _navigation.goBack();
  }
}
