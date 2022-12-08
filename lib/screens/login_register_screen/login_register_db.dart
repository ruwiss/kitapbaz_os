import 'package:bigfamily/constants/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';

Future<String> loginRegister(
    {required String mail,
    required String password,
    String? password2,
    required String durum}) async {
  if (password2 != null && password != password2) {
    return "Şifreler eşleşmiyor";
  }
  mail = mail.replaceAll(" ", "");
  EasyLoading.show(
    status: 'Bekleyiniz',
  );
  Dio dio = Dio();
  var box = await Hive.openBox('user');
  var response = await dio.post(loginRegisterUrl,
      data: FormData.fromMap(
          {'mail': mail, 'password': password, 'durum': durum}));
  if (response.statusCode == 200) {
    await box.put('mail', mail);
    await box.put('sifre', password);
    EasyLoading.dismiss();
    return response.data;
  } else {
    EasyLoading.dismiss();
    return "Bir sorun oluştu.";
  }
}

Future otomatikDoldur(
    {required TextEditingController mail,
    required TextEditingController pass}) async {
  var box = await Hive.openBox('user');
  if (box.containsKey('mail')) {
    mail.text = box.get('mail');
    pass.text = box.get('sifre');
  }
}

Future otomatikGiris() async {
  var box = await Hive.openBox('user');
  box.put("auto_login", true);
}
