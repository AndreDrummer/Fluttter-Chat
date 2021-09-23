import 'package:flutter/material.dart';
import 'package:flutter_chat/features/rooms/create_room.dart';
import 'package:flutter_chat/features/rooms/lobby.dart';
import 'package:flutter_chat/features/rooms/room.dart';
import 'package:flutter_chat/features/users/user_list.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/CreateRoom': (ctx) => const CreateRoom(),
    '/UserList': (ctx) => const UserList(),
    '/Lobby': (ctx) => const Lobby(),
    '/Room': (ctx) => const Room(),
  };
}
