import 'dart:math';
import 'package:bigfamily/screens/first_screen.dart';
import 'package:bigfamily/screens/home_screen/home_screen_db.dart';
import 'package:bigfamily/user_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as gt;
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bigfamily/constants/db.dart';

import '../../constants/db.dart';

final userController = gt.Get.put(UserController());
Dio dio = Dio();
final ImagePicker _picker = ImagePicker();

Future getMail() async {
  var box = await Hive.openBox('user');
  return box.get('mail');
}

Future getProfilePhoto() async {
  var response = await dio.post(getPhotoUrl,
      data: FormData.fromMap({"mail": await getMail()}));
  if (response.statusCode == 200) {
    userController.setUserPhoto(response.data);
  } else {
    userController.setUserPhoto("yok");
  }
}

Future uploadProfilePhoto() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    EasyLoading.show(status: 'Resim Yükleniyor...');
    var response = await dio.post(updatePhotoUrl,
        data: FormData.fromMap({
          "photo": await MultipartFile.fromFile(image.path),
          "mail": await getMail(),
        }));
    if (response.data.toString().contains('@')) {
      Random random = Random();
      userController
          .setUserPhoto(response.data + '?v=' + random.nextInt(99).toString());
      gt.Get.snackbar("Başarılı", "Profil fotoğrafınız güncellendi");
    }

    EasyLoading.dismiss();
  }
}

Future updateName({required String name}) async {
  if (name.isEmpty) {
    return;
  }

  var response = await dio.post(updateNamePath,
      data: FormData.fromMap({'name': name, 'mail': await getMail()}));

  if (response.statusCode == 200) {
    gt.Get.back();
    gt.Get.snackbar("Başarılı", "Yeni isminiz $name olarak güncellendi!");
  }
}

Future updateMail({required String yeniMail, required String password}) async {
  if (!yeniMail.isEmail || password.isEmpty) {
    return;
  }
  var box = await Hive.openBox('user');
  var response = await dio.post(updateMailPath,
      data: FormData.fromMap({
        'mail': box.get('mail'),
        'yeniMail': yeniMail.replaceAll(' ', ''),
        'password': password
      }));
  if (response.data == "200") {
    await box.put('mail', yeniMail);
    await box.put('auto_login', false);
    gt.Get.offAll(() => const FirstScreen());
    gt.Get.snackbar('Bilgi', "E-mail adresiniz güncellendi.");
  }
}

Future updatePassword(
    {required String oldPassword,
    required String newPassword1,
    required String newPassword2}) async {
  if (newPassword1.isEmpty || newPassword1 != newPassword2) {
    gt.Get.snackbar("Hata", "Şifreleri kontrol edin");
    return;
  }
  var box = await Hive.openBox('user');

  var response = await dio.post(updatePasswordPath,
      data: FormData.fromMap({
        'mail': box.get('mail'),
        'password': oldPassword,
        'newPassword': newPassword1
      }));

  if (response.statusCode == 200) {
    await box.put('sifre', newPassword1);
    gt.Get.back();
    gt.Get.snackbar("Bilgi", response.data);
  }
}

Future getLikesComments({String? mail}) async {
  var box = await Hive.openBox('user');
  var response = await dio.post(getLikesCommentsPath,
      data: FormData.fromMap({'mail': mail ?? box.get('mail')}));
  userController.setLikesComments(response.data);
}

Future getBlockedUserNames() async {
  var box = await Hive.openBox('user');
  var response =
      await dio.get(blockUserPath + "?mail=${box.get('mail')}&getNames=1");
  var data = response.data;
  if (data is List) {
    if (data.isNotEmpty) {
      quotesController.setBlockedUserNames(data);
    }
  }
}
