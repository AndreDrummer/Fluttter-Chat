import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_chat/core/connection/connector.dart' as connector;
import 'package:flutter_chat/core/widgets/app_drawer.dart';
import 'package:scoped_model/scoped_model.dart';

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  final TextEditingController _postEditingController = TextEditingController();
  final ScrollController _controller = ScrollController();
  late String _postMessage;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(flutterChatModel.currentRoomName),
              actions: [
                PopupMenuButton(
                  onSelected: (inValue) {
                    if (inValue == 'invite') {
                      _inviteOrKick(inContext, 'invite');
                    } else if (inValue == 'leave') {
                      connector.leave(
                        inUserName: '${flutterChatModel.userName}',
                        inRoomName: flutterChatModel.currentRoomName,
                        inCallback: () {
                          flutterChatModel.removeRoomInvite(
                            flutterChatModel.currentRoomName,
                          );
                          flutterChatModel.setCurrentRoomUserList({});
                          flutterChatModel.setCurrentRoomName(
                            FlutterChatModel.defaultRoomName,
                          );
                          flutterChatModel.setCurrentRoomEnabled(false);
                          Navigator.of(inContext).pushNamedAndRemoveUntil(
                            '/',
                            ModalRoute.withName('/'),
                          );
                        },
                      );
                    } else if (inValue == 'close') {
                      connector.close(
                        flutterChatModel.currentRoomName,
                        () {
                          Navigator.of(inContext).pushNamedAndRemoveUntil(
                            '/',
                            ModalRoute.withName('/'),
                          );
                        },
                      );
                    } else if (inValue == 'kick') {
                      _inviteOrKick(inContext, 'kick');
                    }
                  },
                  itemBuilder: (BuildContext inPMBContext) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem(
                        value: 'leave',
                        child: Text('Leave Room'),
                      ),
                      const PopupMenuItem(
                        value: 'invite',
                        child: Text('Invite A User'),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'close',
                        child: const Text('Close Room'),
                        enabled: flutterChatModel.creatorFunctionsEnabled,
                      ),
                      PopupMenuItem(
                        value: 'kick',
                        child: const Text('Kick User'),
                        enabled: flutterChatModel.creatorFunctionsEnabled,
                      )
                    ];
                  },
                )
              ],
            ),
            drawer: const AppDrawer(),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
              child: Column(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (inIndex, inExpanded) => setState(
                      () {
                        _expanded = !_expanded;
                      },
                    ),
                    children: [
                      ExpansionPanel(
                        isExpanded: _expanded,
                        headerBuilder:
                            (BuildContext context, bool isExpanded) =>
                                const Text('  Users In Room'),
                        body: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Builder(
                            builder: (inBuilderContext) {
                              List<Widget> userList = [];
                              for (var user
                                  in flutterChatModel.currentRoomUserList) {
                                userList.add(Text(user['userName']));
                              }
                              return Column(children: userList);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: flutterChatModel.currentRoomMessages.length,
                      itemBuilder: (inContext, inIndex) {
                        Map message =
                            flutterChatModel.currentRoomMessages[inIndex];
                        return ListTile(
                          subtitle: Text(
                            message['userName'],
                          ),
                          title: Text(
                            message['message'],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _postEditingController,
                          onChanged: (String inText) => setState(
                            () {
                              _postMessage = inText;
                            },
                          ),
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Enter message',
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: IconButton(
                          icon: const Icon(Icons.send),
                          color: Colors.blue,
                          onPressed: () {
                            connector.post(
                              inUserName: '${flutterChatModel.userName}',
                              inRoomName: flutterChatModel.currentRoomName,
                              inMessage: _postMessage,
                              inCallback: (inStatus) {
                                debugPrint(
                                    'Room.post callback: inStatus = $inStatus');
                                if (inStatus == 'OK') {
                                  flutterChatModel.addMessage(
                                    '${flutterChatModel.userName}',
                                    _postMessage,
                                  );
                                  _controller.jumpTo(
                                    _controller.position.maxScrollExtent,
                                  );
                                  _postEditingController.clear();
                                }
                              },
                            );
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _inviteOrKick(
      final BuildContext inContext, final String inInviteOrKick) {
    connector.listUsers(
      (inUserList) {
        flutterChatModel.setUserList(inUserList);

        showDialog(
          context: inContext,
          builder: (BuildContext inDialogContext) {
            return ScopedModel<FlutterChatModel>(
              model: flutterChatModel,
              child: ScopedModelDescendant<FlutterChatModel>(
                builder: (inContext, inChild, inModel) {
                  return AlertDialog(
                    title: Text('Select user to $inInviteOrKick'),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite / 2,
                      child: ListView.builder(
                        itemCount: inInviteOrKick == 'invite'
                            ? flutterChatModel.userList.length
                            : flutterChatModel.currentRoomUserList.length,
                        itemBuilder:
                            (BuildContext inBuildContext, int inIndex) {
                          Map user;
                          if (inInviteOrKick == 'invite') {
                            user = flutterChatModel.userList[inIndex];
                          } else {
                            user =
                                flutterChatModel.currentRoomUserList[inIndex];
                          }
                          if (user['userName'] == flutterChatModel.userName) {
                            return Container();
                          }
                          return Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              border: Border(
                                bottom: BorderSide(),
                                top: BorderSide(),
                                left: BorderSide(),
                                right: BorderSide(),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                stops: [.1, .2, .3, .4, .5, .6, .7, .8, .9],
                                colors: [
                                  Color.fromRGBO(250, 250, 0, .75),
                                  Color.fromRGBO(250, 220, 0, .75),
                                  Color.fromRGBO(250, 190, 0, .75),
                                  Color.fromRGBO(250, 160, 0, .75),
                                  Color.fromRGBO(250, 130, 0, .75),
                                  Color.fromRGBO(250, 110, 0, .75),
                                  Color.fromRGBO(250, 80, 0, .75),
                                  Color.fromRGBO(250, 50, 0, .75),
                                  Color.fromRGBO(250, 0, 0, .75)
                                ],
                              ),
                            ),
                            margin: const EdgeInsets.only(top: 10.0),
                            child: ListTile(
                              title: Text(user['userName']),
                              onTap: () {
                                if (inInviteOrKick == 'invite') {
                                  connector.invite(
                                    inInviterName: user['userName'],
                                    inRoomName:
                                        flutterChatModel.currentRoomName,
                                    inUserName: '${flutterChatModel.userName}',
                                    inCallback: () {
                                      Navigator.of(inContext).pop();
                                    },
                                  );
                                } else {
                                  connector.kick(
                                    inUserName: user['userName'],
                                    inRoomName:
                                        flutterChatModel.currentRoomName,
                                    inCallback: () {
                                      Navigator.of(inContext).pop();
                                    },
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
