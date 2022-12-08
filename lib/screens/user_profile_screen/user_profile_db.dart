import 'package:bigfamily/constants/db.dart';
import 'package:bigfamily/screens/home_screen/home_screen_db.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/adapters.dart';

Dio _dio = Dio();

Future blockUser({bool? unblock, required int blockId}) async {
  var box = await Hive.openBox('user');

  FormData data = unblock == null
      ? FormData.fromMap({'mail': box.get('mail'), 'block_id': blockId})
      : FormData.fromMap(
          {'mail': box.get('mail'), 'block_id': blockId, 'unblock': 1});

  if (unblock == null) {
    quotesController.setBlockedUsers([blockId]);
  } else {
    quotesController.removeBlockedUser(blockId);
    quotesController.blockedUserNames
        .removeWhere((element) => element['id'] == blockId.toString());
  }
  await _dio.post(blockUserPath, data: data);
}
