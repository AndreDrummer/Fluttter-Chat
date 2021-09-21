import 'package:flutter/material.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/CreateRoom': (ctx) => const Text('CreateRoom()'),
    '/UserList': (ctx) => const Text('UserList()'),
    '/Lobby': (ctx) => const Text('Lobby()'),
    '/Room': (ctx) => const Text('Room()'),
  };
}
