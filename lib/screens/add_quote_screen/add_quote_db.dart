import 'package:bigfamily/constants/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:get/get.dart' as gt;

import '../../msg.dart';

Dio dio = Dio();

Future addQuote({
  required String? isim,
  required String? yazar,
  required String alinti,
  required String? resim,
}) async {
  EasyLoading.show(status: 'Ekleniyor');
  var box = await Hive.openBox('user');

  String msg = await sifreliTokenOlustur();

  var response = await dio.post(addQuotePath,
      data: FormData.fromMap({
        'mail': box.get('mail'),
        'isim': isim ?? "",
        'yazar': yazar ?? "",
        'alinti': alinti,
        'resim': resim ?? "",
        'msg': msg
      }));
  if (response.data == "Alıntınız paylaşıldı") {
    gt.Get.back();
    gt.Get.snackbar("Başarılı", "Alıntın yayınlandı!",
        margin: const EdgeInsets.all(5), backgroundColor: Colors.green[100]);
  } else {
    gt.Get.snackbar("Bilgi", "Beklenmeyen bir sorun oluştu");
  }
  EasyLoading.dismiss();
}
