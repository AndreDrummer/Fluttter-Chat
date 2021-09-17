import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class FlutterChatModel extends Model {
  late BuildContext rootBuildContext;

  Directory? docsDir;

  String greeting = '';

  String userName = '';

  static const String defaultRoomName = 'Not currenctly in a room';

  String currentRoomName = defaultRoomName;

  List currentRoomUserList = [];

  bool currentRoomEnabled = false;

  List currentRoomMessages = [];

  List roomList = [];

  List userList = [];

  bool creatorFunctionsEnabled = false;

  Map roomInvites = {};

  void setGreeting(final String inGreeting) {
    debugPrint('## FlutterChatModel.setGreeting(): inGreeting = $inGreeting');

    greeting = inGreeting;
    notifyListeners();
  }

  void setUserName(final String inUserName) {
    debugPrint('## FlutterChatModel.setUserName(): inUserName = $inUserName');

    userName = inUserName;
    notifyListeners();
  }

  void setCurrentRoomName(final String inRoomName) {
    debugPrint(
        '## FlutterChatModel.setCurrentRoomName(): inRoomName = $inRoomName');

    currentRoomName = inRoomName;
    notifyListeners();
  }

  void setCreatorFunctionsEnabled(final bool inEnabled) {
    debugPrint(
        '## FlutterChatModel.setCreatorFunctionsEnabled(): inEnabled = $inEnabled');

    creatorFunctionsEnabled = inEnabled;
    notifyListeners();
  }

  void setCurrentRoomEnabled(final bool inEnabled) {
    debugPrint(
        '## FlutterChatModel.setCurrentRoomEnabled(): inEnabled = $inEnabled');

    currentRoomEnabled = inEnabled;
    notifyListeners();
  }

  void addMessage(final String inUsername, final String inMessage) {
    currentRoomMessages.add({
      'userName': inUsername,
      'message': inMessage,
    });

    notifyListeners();
  }

  void setRoomList(final Map inRoomList) {
    List rooms = [];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }

    roomList = rooms;
    notifyListeners();
  }

  void setUserList(final Map inUserList) {
    debugPrint('## FlutterChatModel.setUserList(): inUserList = $inUserList');

    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }

    userList = users;
    notifyListeners();
  }

  void setCurrentRoomUserList(final Map inUserList) {
    debugPrint(
        '## FlutterChatModel.setCurrentRoomUserList(): inUserList = $inUserList');

    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }

    currentRoomUserList = users;
    notifyListeners();
  }

  void addRoomInvite(final String inRoomName) {
    roomInvites[inRoomName] = true;
  }

  void removeRoomInvite(final String inRoomName) {
    roomInvites.remove(inRoomName);
  }

  void clearCurrentRoomMessages() {
    currentRoomMessages.clear();
  }
}

FlutterChatModel flutterChatModel = FlutterChatModel();
