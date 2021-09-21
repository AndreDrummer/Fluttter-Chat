import 'package:flutter/material.dart';
import 'package:flutter_chat/core/connection/connector.dart' as connector;
import 'package:flutter_chat/core/model/model.dart';
import 'package:scoped_model/scoped_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return Drawer(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/drawback01.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 15),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Center(
                          child: Text(
                            '${flutterChatModel.userName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      subtitle: Center(
                        child: Text(
                          flutterChatModel.currentRoomName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Lobby'),
                    onTap: () {
                      Navigator.of(inContext).pushNamedAndRemoveUntil(
                        '/Lobby',
                        ModalRoute.withName('/'),
                      );
                      connector.listRooms(
                        (inRoomList) {
                          flutterChatModel.setRoomList(inRoomList);
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  enabled: flutterChatModel.currentRoomEnabled,
                  leading: const Icon(Icons.forum),
                  title: const Text('Current Room'),
                  onTap: () {
                    Navigator.of(inContext).pushNamedAndRemoveUntil(
                      '/Room',
                      ModalRoute.withName('/'),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.face),
                  title: const Text('User List'),
                  onTap: () {
                    Navigator.of(inContext).pushNamedAndRemoveUntil(
                      '/UserList',
                      ModalRoute.withName('/'),
                    );
                    connector.listUsers(
                      (inUserList) {
                        flutterChatModel.setUserList(inUserList);
                      },
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
