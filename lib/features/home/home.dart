import 'package:flutter/material.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_chat/core/widgets/app_drawer.dart';
import 'package:scoped_model/scoped_model.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('FlutterChat'),
            ),
            drawer: const AppDrawer(),
            body: Center(
              child: Text(
                flutterChatModel.greeting,
              ),
            ),
          );
        },
      ),
    );
  }
}
