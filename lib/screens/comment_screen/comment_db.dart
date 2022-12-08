import 'package:bigfamily/constants/db.dart';
import 'package:bigfamily/screens/comment_screen/comment_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:get/get.dart' as gt;

import '../../msg.dart';

Dio _dio = Dio();
final commentController = gt.Get.put(CommentController());
bool _isLoading = false;
bool endComment = false;

Future addComment(
    {required int postId, required TextEditingController commentCtrl}) async {
  var box = await Hive.openBox('user');

  String msg = await sifreliTokenOlustur();

  var response = await _dio.post(addCommentPath,
      data: FormData.fromMap({
        'mail': box.get('mail'),
        'post_id': postId,
        'comment': commentCtrl.text,
        'msg': msg
      }));
  _isLoading = false;
  endComment = false;
  await getComments(postId: postId, limit: 0);
  String message = "";
  if (response.statusCode == 200) {
    message = 'Yorumunuz paylaşıldı';
    commentCtrl.clear();
  } else {
    message = 'Bir sorun oluştu';
  }
  gt.Get.snackbar('Bilgi', message, margin: const EdgeInsets.all(8));
}

Future getComments({required int postId, required int limit}) async {
  if (!_isLoading && !endComment) {
    _isLoading = true;
    var response = await _dio.post(getCommentPath(limit),
        data: FormData.fromMap({'post_id': postId, 'limit': limit}));
    if (response.statusCode == 200) {
      var list = response.data;
      if (list is List) {
        if (list.isEmpty) {
          if (limit == 0) {
            commentController.setComment([]);
          }

          endComment = true;
        } else {
          if (limit == 0) {
            commentController.setComment(list);
          } else {
            commentController.addComment(list);
          }
        }
      }
    } else {
      endComment = true;
    }

    if (endComment) {
      EasyLoading.showToast('Yorum Mevcut Değil',
          toastPosition: EasyLoadingToastPosition.bottom);
    }
    _isLoading = false;
  }
}

Future removeComment({required int id, required postId}) async {
  var box = await Hive.openBox('user');
  String msg = await sifreliTokenOlustur();
  var response = await _dio.post(removeCommentPath,
      data: FormData.fromMap({'id': id, "mail": box.get('mail'), "msg": msg}));
  if (response.data == "Başarılı") {
    _isLoading = false;
    endComment = false;
    await getComments(postId: postId, limit: 0);
  } else {
    EasyLoading.showToast('Bir sorun oluştu',
        toastPosition: EasyLoadingToastPosition.center);
  }
}
