import 'package:bigfamily/constants/colors.dart';
import 'package:bigfamily/screens/home_screen/home_screen.dart';
import 'package:bigfamily/screens/login_register_screen/login_screen.dart';
import 'package:bigfamily/screens/login_register_screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:new_version/new_version.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  Future<String> _isLogged() async {
    var box = await Hive.openBox('user');
    if (box.get('auto_login') == true) {
      return 'auto_login';
    } else if (box.containsKey('mail')) {
      return 'auto_fill';
    } else {
      return 'first_screen';
    }
  }

  Future _showVersionChecker(BuildContext context) async {
    try {
      final newVersion = NewVersion(
        androidId: 'com.gunlukalintilar.bigfamily',
      );

      final VersionStatus? status = await newVersion.getVersionStatus();
      if (status!.localVersion != status.storeVersion) {
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'Güncelleme Mevcut',
          dialogText:
              'Herhangi bir sorun yaşamamak için uygulamanızı güncellemeniz gerekmektedir.',
          updateButtonText: 'Güncelle',
          dismissButtonText: 'Vazgeç',
          dismissAction: () => Get.back(),
        );
      }
    } catch (e) {
      debugPrint("Version Check ERROR : =====>${e.toString()}");
    }
  }

  @override
  void initState() {
    OneSignal.shared.setAppId("5cf6089f-83f8-4b56-b62e-0b9c57785c2e");
    super.initState();
    _showVersionChecker(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<String>(
          future: _isLogged(),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const Scaffold(
                    body: Center(child: Text('Yükleniyor..')),
                  )
                : snapshot.data == "auto_fill"
                    ? LoginScreen(arg: snapshot.data.toString())
                    : snapshot.data == "auto_login"
                        ? const HomeScreen()
                        : Scaffold(
                            backgroundColor: colorBg,
                            body: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/images/vector.png",
                                      scale: 3,
                                    ),
                                    const Text(
                                      "Uygulamaya Hoşgeldin",
                                      style: TextStyle(
                                          fontSize: 23, color: colorGray),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.all(20),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              alignment: Alignment.bottomLeft,
                                              child: const Icon(
                                                Icons.format_quote_rounded,
                                                size: 35,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const Text(
                                              "Kitaplar zamanın büyük denizinde dikilmiş deniz fenerleridir.",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _menuButton(
                                            onTap: () => Get.to(
                                                () =>
                                                    const LoginScreen(arg: ""),
                                                transition: Transition.fade),
                                            text: "Giriş yap",
                                            theme: "light"),
                                        _menuButton(
                                            onTap: () => Get.to(
                                                () => RegisterScreen(),
                                                transition: Transition.fade),
                                            text: "Kayıt ol",
                                            theme: "dark"),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
          }),
    );
  }

  GestureDetector _menuButton(
      {required Function() onTap,
      required String text,
      required String theme}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: theme == "dark" ? colorGray : colorOrange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme == "dark" ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
