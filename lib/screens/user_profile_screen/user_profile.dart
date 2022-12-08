import 'package:bigfamily/screens/home_screen/home_screen_db.dart';
import 'package:bigfamily/screens/user_profile_screen/user_profile_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/db.dart';
import '../account_settings_screen/account_settings_db.dart';
import 'picture_zoom.dart';

class UserProfile extends StatefulWidget {
  final Map user;
  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  void initState() {
    userController.removeLikesComments();
    getLikesComments(mail: widget.user['mail']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    final DateTime date = DateTime.parse(widget.user['date']);
    return Scaffold(
      body: Column(
        children: [
          _appBar(),
          const Divider(height: 20, thickness: 1),
          const Expanded(child: SizedBox()),
          GestureDetector(
            onTap: () => pictureZoom(
                widget.user['photo'] == ""
                    ? ""
                    : userPhotoPath + widget.user['photo'],
                widget.user['photo'] != ""),
            child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: widget.user['photo'] == ""
                    ? Image.asset("assets/images/avatar.png").image
                    : NetworkImage(userPhotoPath + widget.user['photo'])),
          ),
          const SizedBox(height: 35),
          Text(
              "${date.day} ${months[date.month - 1]} ${date.year} Tarihinde Kayıt Oldu."),
          const SizedBox(height: 15),
          _likesComments(),
          const SizedBox(height: 35),
          Obx(() => Container(
                child: quotesController.blockedUsers
                            .contains(widget.user['id'].toString()) ||
                        quotesController.blockedUsers
                            .contains(widget.user['id'])
                    ? ElevatedButton(
                        onPressed: () => blockUser(
                            blockId: widget.user['id'], unblock: true),
                        child: const Text('Engeli Kaldır'),
                        style: ElevatedButton.styleFrom(primary: Colors.grey),
                      )
                    : ElevatedButton(
                        onPressed: () => blockUser(blockId: widget.user['id']),
                        child: const Text('Kullanıcıyı Engelle'),
                        style:
                            ElevatedButton.styleFrom(primary: Colors.red[400]),
                      ),
              )),
          const SizedBox(height: 35),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
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

  Padding _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 25, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.user['name'],
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
}
