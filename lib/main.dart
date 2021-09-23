import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat/core/model/model.dart';
import 'package:flutter_chat/core/routes/app_routes.dart';
import 'package:flutter_chat/core/utils/ui_utils/login_dialog.dart';
import 'package:flutter_chat/features/home/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';

dynamic exists;
dynamic credentials;
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    flutterChatModel.docsDir = docsDir;

    var credentialsFile = File(
      join(flutterChatModel.docsDir!.path, "credentials"),
    );

    exists = await credentialsFile.exists();

    if (exists) {
      credentials = await credentialsFile.readAsString();
    }

    runApp(const FlutterChat());
  }

  startMeUp();
}

class FlutterChat extends StatelessWidget {
  const FlutterChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: FlutterChatMain(),
      ),
    );
  }
}

class FlutterChatMain extends StatelessWidget {
  const FlutterChatMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    flutterChatModel.rootBuildContext = context;

    WidgetsBinding.instance!.addPostFrameCallback((_) => executeAfterBuild());

    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, child, model) {
          return MaterialApp(
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false,
            home: const Home(),
          );
        },
      ),
    );
  }

  Future<void> executeAfterBuild() async {
    if (exists) {
      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(
        context: flutterChatModel.rootBuildContext,
        barrierDismissible: false,
        builder: (BuildContext inDialogContext) {
          return LoginDialog();
        },
      );
    }
  }
}
