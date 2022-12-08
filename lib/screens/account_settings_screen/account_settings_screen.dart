import 'package:bigfamily/constants/colors.dart';
import 'package:bigfamily/constants/widgets.dart';
import 'package:bigfamily/screens/account_settings_screen/account_settings_db.dart';
import 'package:bigfamily/screens/home_screen/home_screen_db.dart';
import 'package:bigfamily/screens/user_profile_screen/user_profile_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/db.dart';
import '../user_profile_screen/picture_zoom.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({Key? key}) : super(key: key);

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final _epostaCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  final _sifreTekrarCtrl = TextEditingController();
  final _eskiSifreCtrl = TextEditingController();
  final _adsoyadCtrl = TextEditingController();

  @override
  void initState() {
    getLikesComments();
    getBlockedUserNames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _appBar(),
            const Divider(height: 20, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Column(
                children: [
                  Obx(() => GestureDetector(
                        onTap: () => pictureZoom(
                            userPhotoPath + userController.userPhoto.value,
                            userController.userPhoto.value != "yok"),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          backgroundImage: userController.userPhoto.value ==
                                  "yok"
                              ? Image.asset("assets/images/avatar.png").image
                              : NetworkImage(userPhotoPath +
                                  userController.userPhoto.value),
                        ),
                      )),
                  TextButton(
                      onPressed: () => uploadProfilePhoto(),
                      child: const Text(
                        "Profil resmini değiştir",
                        style: TextStyle(fontSize: 15),
                      )),
                  Obx(
                    () => Visibility(
                      visible: quotesController.blockedUsers.isNotEmpty,
                      child: TextButton(
                          onPressed: () => _showBlockedUsers(),
                          child: Text(
                              "Engellenenler (${quotesController.blockedUserNames.length})")),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _likesComments(),
                  const SizedBox(height: 25),
                  _optionItem(
                      text: "Ad-soyadımı değiştir",
                      color: Colors.white,
                      onTap: _adsoyadGuncelle),
                  _optionItem(
                      text: "E-posta adresimi güncelle",
                      color: Colors.white,
                      onTap: _epostaGuncelle),
                  _optionItem(
                      text: "Şifremi değiştir",
                      color: Colors.white,
                      onTap: _sifreGuncelle),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _showBlockedUsers() {
    Get.bottomSheet(Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 25),
            width: 50,
            height: 3,
            color: Colors.black87,
          ),
          const Text(
            "Engellenen Kullanıcılar",
            style: TextStyle(fontSize: 18, color: colorRed),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: Obx(
              () => ListView.builder(
                itemCount: quotesController.blockedUserNames.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.generalDialog(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AlertDialog(
                            title: const Text('Engeli Kaldır'),
                            content: const Text(
                                "Bu kullanıcının paylaşımlarını görmeye devam edeceksin."),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await blockUser(
                                      blockId: int.parse(quotesController
                                          .blockedUserNames[index]['id']),
                                      unblock: true);
                                  if (quotesController
                                      .blockedUserNames.isEmpty) {
                                    Get.back();
                                  }
                                  Get.back();
                                },
                                child: const Text('Kabul'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black45),
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        quotesController.blockedUserNames[index]['name']
                            .toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }

  Widget _likesComments() {
    return Obx(() => userController.likesComments.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const Divider(
                  color: Colors.black38,
                  height: 25,
                  thickness: 1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        userController.likesComments['quotes'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Text('Alıntı'),
                    ],
                  ),
                  Column(children: [
                    Text(
                      userController.likesComments['likes'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text('Beğeni'),
                  ]),
                  Column(
                    children: [
                      Text(
                        userController.likesComments['comments'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Text('Yorum'),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: const Divider(
                  color: Colors.black38,
                  height: 25,
                  thickness: 1,
                ),
              )
            ],
          ));
  }

  Container _snackInput(
      {required String text,
      required String hint,
      required TextEditingController controller,
      bool obscure = false,
      TextInputType? type}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: containerDecoration(),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              keyboardType: type,
              controller: controller,
              obscureText: obscure,
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: hint),
            ),
          )
        ],
      ),
    );
  }

  Padding _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 25, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Hesap Ayarları",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close,
              size: 28,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector _optionItem(
      {required String text, required Function() onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: containerDecoration(color: color),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontSize: 16)),
            const Expanded(child: SizedBox()),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }

  _adsoyadGuncelle() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      "Ad Soyad",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(
                      onPressed: () => updateName(name: _adsoyadCtrl.text),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: const Text("KAYDET"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _snackInput(
                        text: "Ad soyad",
                        hint: "Yenisini giriniz",
                        controller: _adsoyadCtrl),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _epostaGuncelle() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      "Yeni e-posta",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(
                      onPressed: () => updateMail(
                          yeniMail: _epostaCtrl.text,
                          password: _sifreCtrl.text),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: const Text("KAYDET"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _snackInput(
                        text: "E-posta",
                        hint: "Yeni e-posta girin",
                        type: TextInputType.emailAddress,
                        controller: _epostaCtrl),
                    _snackInput(
                        text: "Şifre",
                        obscure: true,
                        hint: "Mevcut şifrenizi girin",
                        controller: _sifreCtrl),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _sifreGuncelle() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      "Yeni Şifre",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(
                      onPressed: () => updatePassword(
                          oldPassword: _eskiSifreCtrl.text,
                          newPassword1: _sifreCtrl.text,
                          newPassword2: _sifreTekrarCtrl.text),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: const Text("KAYDET"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _snackInput(
                        text: "Şifre",
                        hint: "Yeni şifrenizi girin",
                        obscure: true,
                        controller: _sifreCtrl),
                    _snackInput(
                        text: "Tekrar",
                        hint: "Yeni şifrenizi girin",
                        obscure: true,
                        controller: _sifreTekrarCtrl),
                    _snackInput(
                        text: "Eski Şifre",
                        obscure: true,
                        hint: "Mevcut şifrenizi girin",
                        controller: _eskiSifreCtrl),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
