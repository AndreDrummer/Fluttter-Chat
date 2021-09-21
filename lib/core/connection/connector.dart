import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

String serverURL = 'http: 1192.168.1.32';

late SocketIO _io;

void showPleaseWait() {
  debugPrint('## Connector.showPleaseWait()');

  showDialog(
    context: flutterChatModel.rootBuildContext,
    barrierDismissible: false,
    builder: (BuildContext inDialogContext) {
      return Dialog(
        child: Container(
          width: 150,
          height: 150,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            color: Colors.blue[200],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Center(
                  child: Text(
                    'Please wait, contacting server...',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

void hidePleaseWait() {
  debugPrint('## Connector.hidePleaseWait()');

  Navigator.of(flutterChatModel.rootBuildContext).pop();
}

void connectToServer(final Function inCallback) {
  _io = SocketIOManager().createSocketIO(serverURL, '/', query: '',
      socketStatusCallback: (inData) {
    if (inData == 'connect') {
      _io.subscribe('newUser', newUser);
      _io.subscribe('created', created);
      _io.subscribe('closed', closed);
      _io.subscribe('joined', joined);
      _io.subscribe('left', left);
      _io.subscribe('kicked', kicked);
      _io.subscribe('invited', invited);
      _io.subscribe('posted', posted);
      inCallback();
    }
  });
  _io.init();
  _io.connect();
}

void validate({
  required Function inCallback,
  required String inUserName,
  required String inPassword,
}) {
  showPleaseWait();
  _io.sendMessage(
      'validate', '''{ 'username': $inUserName, 'password': $inPassword }''',
      (inData) {
    Map<String, dynamic> response = json.decode(inData);
    hidePleaseWait();
    inCallback(response['status']);
  });
}

void listRooms(final Function inCallback) {
  showPleaseWait();
  _io.sendMessage('listRooms', '{}', (inData) {
    Map<String, dynamic> response = json.decode(inData);
    hidePleaseWait();
    inCallback(response['status']);
  });
}

void create({
  required String inDescription,
  required Function inCallback,
  required String inRoomName,
  required String inCreator,
  required int inMaxPeople,
  required bool inPrivate,
}) {
  showPleaseWait();
  _io.sendMessage('create',
      '''{ 'roomName': $inRoomName, 'description': $inDescription, 'maxPeople': $inMaxPeople, 'private': $inPrivate, 'creator': $inCreator }''',
      (inData) {
    Map<String, dynamic> response = json.decode(inData);
    hidePleaseWait();
    inCallback(response['status'], response['rooms']);
  });
}

void join({
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  _io.sendMessage(
      'join', '''{ 'userName': $inUserName, 'roomName': $inRoomName }''',
      (inData) {
    Map<String, dynamic> response = json.decode(inData);
    hidePleaseWait();
    inCallback(response['status'], response['room']);
  });
}

void leave({
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  _io.sendMessage(
      'leave', '''{ 'userName': $inUserName, 'roomName': $inRoomName }''',
      (inData) {
    Map<String, dynamic> response = json.decode(inData);
    debugPrint('## Connector.listUsers(): callback: response = $response');
    hidePleaseWait();
    inCallback();
  });
}

void listUsers(final Function inCallback) {
  showPleaseWait();
  _io.sendMessage('listUsers', '{}', (inData) {
    Map<String, dynamic> response = json.decode(inData);
    hidePleaseWait();
    inCallback(response);
  });
}

void invite({
  required String inInviterName,
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  _io.sendMessage('invite',
      '''{ 'userName': $inUserName, 'roomName': $inRoomName, 'inviterName': $inInviterName }''',
      (inData) {
    hidePleaseWait();
    inCallback();
  });
}

void post({
  required Function inCallback,
  required String inRoomName,
  required String inUserName,
  required String inMessage,
}) {
  showPleaseWait();
  _io.sendMessage('post',
      '''{ 'userName': $inUserName, 'roomName': $inRoomName, 'message': $inMessage }''',
      (inData) {
    Map<String, dynamic> response = json.decode(inData);
    hidePleaseWait();
    inCallback(response['status']);
  });
}

void close(final String inRoomName, final Function inCallback) {
  showPleaseWait();
  _io.sendMessage('close', '''{ 'roomName': $inRoomName }''', (inData) {
    hidePleaseWait();
    inCallback();
  });
}

void kick({
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  _io.sendMessage(
      'kick', '''{ 'userName': $inUserName', 'roomName': $inRoomName }''',
      (inData) {
    hidePleaseWait();
    inCallback();
  });
}

void newUser(inData) {
  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.newUser(): payload = $payload');

  flutterChatModel.setUserList(payload);
}

void created(inData) {
  debugPrint('## Connector.created(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.created(): payload = $payload');

  flutterChatModel.setRoomList(payload);
}

void closed(inData) {
  debugPrint('## Connector.closed(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.closed(): payload = $payload');

  flutterChatModel.setRoomList(payload);

  if (payload['roomName'] == flutterChatModel.currentRoomName) {
    flutterChatModel.removeRoomInvite(payload['roomName']);
    flutterChatModel.setCurrentRoomUserList({});
    flutterChatModel.setCurrentRoomName(FlutterChatModel.defaultRoomName);
    flutterChatModel.setCurrentRoomEnabled(false);

    flutterChatModel
        .setGreeting('The room you were in was closed by its creator.');
    Navigator.of(flutterChatModel.rootBuildContext)
        .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }
}

void joined(inData) {
  debugPrint('## Connector.joined(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.joined(): payload = $payload');

  if (flutterChatModel.currentRoomName == payload['roomName']) {
    flutterChatModel.setCurrentRoomUserList(payload['users']);
  }
}

void left(inData) {
  debugPrint('## Connector.left(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.left(): payload = $payload');

  if (flutterChatModel.currentRoomName == payload['room']['roomName']) {
    flutterChatModel.setCurrentRoomUserList(payload['room']['users']);
  }
}

void kicked(inData) {
  debugPrint('## Connector.kicked(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.kicked(): payload = $payload');

  flutterChatModel.removeRoomInvite(payload['roomName']);
  flutterChatModel.setCurrentRoomUserList({});
  flutterChatModel.setCurrentRoomName(FlutterChatModel.defaultRoomName);
  flutterChatModel.setCurrentRoomEnabled(false);

  flutterChatModel
      .setGreeting('What did you do?! You got kicked from the room! D\'oh!');

  Navigator.of(flutterChatModel.rootBuildContext).pushNamedAndRemoveUntil(
    '/',
    ModalRoute.withName('/'),
  );
}

void invited(inData) async {
  debugPrint('## Connector.invited(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.invited(): payload = $payload');

  String roomName = payload['roomName'];
  String inviterName = payload['inviterName'];

  flutterChatModel.addRoomInvite(roomName);

  ScaffoldMessenger.of(flutterChatModel.rootBuildContext).showSnackBar(
    SnackBar(
      backgroundColor: Colors.amber,
      duration: const Duration(seconds: 60),
      content: Text(
        '''You've been invited to the room '$roomName' by user '$inviterName'.\n\n'''
        '''You can enter the room from the lobby.''',
      ),
      action: SnackBarAction(
        label: 'Ok',
        onPressed: () {},
      ),
    ),
  );
}

void posted(inData) {
  debugPrint('## Connector.posted(): inData = $inData');

  Map<String, dynamic> payload = jsonDecode(inData);
  debugPrint('## Connector.posted(): payload = $payload');

  if (flutterChatModel.currentRoomName == payload['roomName']) {
    flutterChatModel.addMessage(payload['userName'], payload['message']);
  }
}
