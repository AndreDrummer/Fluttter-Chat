import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:socket_io_client/socket_io_client.dart';

const String serverURL = 'http://192.168.100.5:3000';

late Socket socket;

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
  try {
    socket = io(serverURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });

    socket.connect();

    socket.on('newUser', newUser);
    socket.on('created', created);
    socket.on('closed', closed);
    socket.on('joined', joined);
    socket.on('left', left);
    socket.on('kicked', kicked);
    socket.on('invited', invited);
    socket.on('posted', posted);
    inCallback();
  } on Exception catch (exception) {
    debugPrint(exception.toString());
  }
}

void validate({
  required Function inCallback,
  required String inUserName,
  required String inPassword,
}) {
  showPleaseWait();
  socket.emitWithAck('validate', {
    'userName': inUserName,
    'password': inPassword,
  }, ack: (inData) {
    hidePleaseWait();
    inCallback(inData['status']);
  });
}

void listRooms(final Function inCallback) {
  showPleaseWait();
  socket.emitWithAck('listRooms', '{}', ack: (inData) {
    hidePleaseWait();
    inCallback(inData);
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
  socket.emitWithAck('create', {
    'roomName': inRoomName,
    'description': inDescription,
    'maxPeople': inMaxPeople,
    'private': inPrivate,
    'creator': inCreator
  }, ack: (inData) {
    hidePleaseWait();
    inCallback(inData['status'], inData['rooms']);
  });
}

void join({
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  socket.emitWithAck('join', {
    'userName': inUserName,
    'roomName': inRoomName,
  }, ack: (inData) {
    hidePleaseWait();
    inCallback(inData['status'], inData['room']);
  });
}

void leave({
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  socket.emitWithAck('leave', {
    'userName': inUserName,
    'roomName': inRoomName,
  }, ack: (inData) {
    debugPrint('## Connector.listUsers(): callback: response = $inData');
    hidePleaseWait();
    inCallback();
  });
}

void listUsers(final Function inCallback) {
  showPleaseWait();
  socket.emitWithAck('listUsers', '{}', ack: (inData) {
    hidePleaseWait();
    inCallback(inData);
  });
}

void invite({
  required String inInviterName,
  required Function inCallback,
  required String inUserName,
  required String inRoomName,
}) {
  showPleaseWait();
  socket.emitWithAck('invite', {
    'inviterName': inInviterName,
    'roomName': inRoomName,
    'userName': inUserName,
  }, ack: (inData) {
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
  socket.emitWithAck('post', {
    'userName': inUserName,
    'roomName': inRoomName,
    'message': inMessage
  }, ack: (inData) {
    hidePleaseWait();
    inCallback(inData['status']);
  });
}

void close(final String inRoomName, final Function inCallback) {
  showPleaseWait();
  socket.emitWithAck('close', {'roomName': inRoomName}, ack: (inData) {
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
  socket.emitWithAck('kick', {
    'userName': inUserName,
    'roomName': inRoomName,
  }, ack: (inData) {
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
