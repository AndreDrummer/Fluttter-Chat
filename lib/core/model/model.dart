import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class FlutterChatModel extends Model {
  BuildContext? rootBuildContext;

  Directory? docsDir;

  String gretting = '';

  String userName = '';

  static const String defaultRoomName = 'Not currenctly in a room';

  String currentRoomName = defaultRoomName;

  List currenctRoomUserList = [];

  bool currentRoomEnabled = false;

  List currentRoomMessages = [];

  List roomList = [];

  List userList = [];

  bool creatorFunctionsEnabled = false;

  Map roomInvittes = {};
}
