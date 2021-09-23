import 'dart:io';
import 'package:flutter_chat/core/model/model.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_chat/core/connection/connector.dart' as connector;

class LoginDialog extends StatelessWidget {
  LoginDialog({Key? key}) : super(key: key);

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  late String _userName;
  late String _password;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: flutterChatModel,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (inContext, inChild, inModel) {
          return AlertDialog(
            content: SizedBox(
              height: 220,
              child: Form(
                key: _loginFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Enter a username and password to register with the server',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(flutterChatModel.rootBuildContext)
                              .primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (inValue) {
                          if (inValue != null && inValue.isEmpty ||
                              inValue!.length > 10) {
                            return 'Please enter a username no more than 10 characters long';
                          }
                          return null;
                        },
                        onSaved: (inValue) {
                          _userName = inValue!;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          labelText: 'Username',
                        ),
                      ),
                      TextFormField(
                        obscureText: true,
                        validator: (inValue) {
                          if (inValue != null && inValue.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        onSaved: (inValue) {
                          _password = inValue!;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          labelText: 'Password',
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Log In'),
                onPressed: () {
                  if (_loginFormKey.currentState!.validate()) {
                    _loginFormKey.currentState!.save();
                    connector.connectToServer(
                      () {
                        connector.validate(
                          inUserName: _userName,
                          inPassword: _password,
                          inCallback: (inStatus) async {
                            if (inStatus == 'OK') {
                              flutterChatModel.setUserName(_userName);
                              Navigator.of(flutterChatModel.rootBuildContext)
                                  .pop();
                              flutterChatModel
                                  .setGreeting('Welcome back, $_userName!');
                            } else if (inStatus == 'Fail') {
                              ScaffoldMessenger.of(
                                      flutterChatModel.rootBuildContext)
                                  .showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  content: Text(
                                      'Sorry, that username is already taken'),
                                ),
                              );
                            } else if (inStatus == 'Created') {
                              var credentialsFile = File(
                                join(
                                  flutterChatModel.docsDir!.path,
                                  'credentials',
                                ),
                              );
                              await credentialsFile.writeAsString(
                                  '$_userName============$_password');
                              flutterChatModel.setUserName(_userName);
                              Navigator.of(flutterChatModel.rootBuildContext)
                                  .pop();
                              flutterChatModel.setGreeting(
                                  'Welcome to the server, $_userName!');
                            }
                          },
                        );
                      },
                    );
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }

  void validateWithStoredCredentials(
    final String inUserName,
    final String inPassword,
  ) {
    connector.connectToServer(
      () {
        connector.validate(
          inUserName: inUserName,
          inPassword: inPassword,
          inCallback: (inStatus) {
            if (inStatus == 'OK' || inStatus == 'created') {
              flutterChatModel.setUserName(inUserName);
              flutterChatModel.setGreeting('Welcome back, $inUserName!');
            } else if (inStatus == 'Fail') {
              showDialog(
                context: flutterChatModel.rootBuildContext,
                barrierDismissible: false,
                builder: (final BuildContext inDialogContext) => AlertDialog(
                  title: const Text('Validation failed'),
                  content: const Text(
                    'It appears that the server has restarted and the username you last used was '
                    'subsequently taken by someone else.\n\nPlease re-start FlutterChat and choose a different username.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        var credentialsFile = File(
                          join(
                            flutterChatModel.docsDir!.path,
                            'credentials',
                          ),
                        );
                        credentialsFile.deleteSync();
                        exit(0);
                      },
                    )
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}
