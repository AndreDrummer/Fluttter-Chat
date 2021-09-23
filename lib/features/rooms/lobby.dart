import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_chat/core/widgets/app_drawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_chat/core/connection/connector.dart' as connector;

class Lobby extends StatelessWidget {
  const Lobby({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Lobby'),
            ),
            drawer: const AppDrawer(),
            floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(inContext, '/CreateRoom');
                }),
            body: flutterChatModel.roomList.isEmpty
                ? const Center(
                    child: Text(
                      'There are no rooms yet. Why not add one?',
                    ),
                  )
                : ListView.builder(
                    itemCount: flutterChatModel.roomList.length,
                    itemBuilder: (BuildContext inBuildContext, int inIndex) {
                      Map room = flutterChatModel.roomList[inIndex];
                      String roomName = room['roomName'];
                      return Column(
                        children: [
                          ListTile(
                            leading: room['private']
                                ? Image.asset('assets/private.png')
                                : Image.asset('assets/public.png'),
                            title: Text(roomName),
                            subtitle: Text(
                              room['description'],
                            ),
                            onTap: () {
                              if (room['private'] &&
                                  !flutterChatModel.roomInvites
                                      .containsKey(roomName) &&
                                  room['creator'] !=
                                      flutterChatModel.userName) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                      'Sorry, you can\'t enter a private room without an invite',
                                    ),
                                  ),
                                );
                              } else {
                                connector.join(
                                  inUserName: '${flutterChatModel.userName}',
                                  inRoomName: roomName,
                                  inCallback: (inStatus, inRoomDescriptor) {
                                    if (inStatus == 'Joined') {
                                      flutterChatModel.setCurrentRoomName(
                                        inRoomDescriptor['roomName'],
                                      );
                                      flutterChatModel.setCurrentRoomUserList(
                                          inRoomDescriptor['users']);
                                      flutterChatModel
                                          .setCurrentRoomEnabled(true);
                                      flutterChatModel
                                          .clearCurrentRoomMessages();
                                      if (inRoomDescriptor['creator'] ==
                                          flutterChatModel.userName) {
                                        flutterChatModel
                                            .setCreatorFunctionsEnabled(true);
                                      } else {
                                        flutterChatModel
                                            .setCreatorFunctionsEnabled(false);
                                      }
                                      Navigator.pushNamed(inContext, '/Room');
                                    } else if (inStatus == 'full') {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 2),
                                          content: Text(
                                            'Sorry, that room is full',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                          const Divider()
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
