import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_chat/core/widgets/app_drawer.dart';
import 'package:scoped_model/scoped_model.dart';

class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, FlutterChatModel inModel) {
          return Scaffold(
            appBar: AppBar(title: const Text('User List')),
            drawer: const AppDrawer(),
            body: GridView.builder(
              itemCount: flutterChatModel.userList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext inContext, int inIndex) {
                Map user = flutterChatModel.userList[inIndex];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: GridTile(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Image.asset(
                              'assets/user.png',
                            ),
                          ),
                        ),
                        footer: Text(
                          user['userName'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
