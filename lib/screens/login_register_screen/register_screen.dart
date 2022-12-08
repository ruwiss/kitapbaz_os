import 'package:bigfamily/constants/colors.dart';
import 'package:bigfamily/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_register_db.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);

  final _mailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorBg,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _appBar(),
              const Padding(
                padding: EdgeInsets.only(left: 35, bottom: 30),
                child: Text(
                  "Aramıza Hoşgeldin!",
                  style: TextStyle(
                      color: colorBrown,
                      fontWeight: FontWeight.w600,
                      fontSize: 27),
                ),
              ),
              _inputText(
                  title: "Mail",
                  hint: "ornekmail123@gmail.com",
                  controller: _mailCtrl),
              _inputText(
                  title: "Şifre",
                  hint: "Güçlü bir şifre oluştur",
                  controller: _passwordCtrl),
              _inputText(
                  title: "Şifre",
                  hint: "Şifreni tekrar gir",
                  controller: _password2Ctrl),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Kayıt ol",
                      style: TextStyle(
                          color: colorBrown,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () async {
                        String result = await loginRegister(
                            mail: _mailCtrl.text,
                            password: _passwordCtrl.text,
                            password2: _password2Ctrl.text,
                            durum: "kayıt");
                        if (result == 'Kayıt Başarılı') {
                          otomatikGiris();
                          Get.to(() => const HomeScreen(),
                              transition: Transition.fade);
                        }
                        Get.snackbar("Bilgi", result,
                            margin: const EdgeInsets.all(8));
                      },
                      child: const CircleAvatar(
                          backgroundColor: colorPink,
                          radius: 30,
                          child: Icon(
                            Icons.double_arrow,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding _inputText(
      {required String title,
      required String hint,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
          TextField(
            obscureText: title == "Şifre" ? true : false,
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          )
        ],
      ),
    );
  }

  Container _appBar() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, bottom: 30),
      alignment: Alignment.centerLeft,
      child: IconButton(
          onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
    );
  }
}
