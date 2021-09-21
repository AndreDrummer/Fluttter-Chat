import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_chat/core/widgets/app_drawer.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_chat/core/connection/connector.dart' as connector;

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  late double _maxPeople = 25;
  late bool _private = false;
  late String _description;
  late String _title;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, FlutterChatModel inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text('Create Room')),
            drawer: const AppDrawer(),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          FocusScope.of(inContext).requestFocus(FocusNode());
                          Navigator.of(inContext).pop();
                        }),
                    const Spacer(),
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        int maxPeople = _maxPeople.truncate();
                        connector.create(
                          inRoomName: _title,
                          inDescription: _description,
                          inMaxPeople: maxPeople,
                          inPrivate: _private,
                          inCreator: '${flutterChatModel.userName}',
                          inCallback: (inStatus, inRoomList) {
                            if (inStatus == 'created') {
                              flutterChatModel.setRoomList(inRoomList);
                              FocusScope.of(inContext)
                                  .requestFocus(FocusNode());
                              Navigator.of(inContext).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                    'Sorry, that room already exists',
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.subject),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      validator: (inValue) {
                        if (inValue != null &&
                            (inValue.isEmpty || inValue.length > 14)) {
                          return 'Please enter a name no more than 14 characters long';
                        }
                        return null;
                      },
                      onSaved: (inValue) {
                        setState(() {
                          _title = inValue!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: TextFormField(
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                      onSaved: (inValue) {
                        setState(() {
                          _description = inValue!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        const Text('Max\nPeople'),
                        Slider(
                          min: 0,
                          max: 99,
                          value: _maxPeople,
                          onChanged: (double inValue) {
                            setState(
                              () {
                                _maxPeople = inValue;
                              },
                            );
                          },
                        )
                      ],
                    ),
                    trailing: Text(
                      _maxPeople.toStringAsFixed(0),
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        const Text('Private'),
                        Switch(
                          value: _private,
                          onChanged: (inValue) {
                            setState(() {
                              _private = inValue;
                            });
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
