import 'package:bigfamily/screens/comment_screen/comment_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../constants/colors.dart';
import '../../constants/db.dart';
import '../account_settings_screen/account_settings_db.dart';
import '../home_screen/home_screen_db.dart';
import '../user_profile_screen/picture_zoom.dart';

class CommentScreen extends StatefulWidget {
  final Map args;
  const CommentScreen({Key? key, required this.args}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentCtrl = TextEditingController();
  String zamanCevir(DateTime input, {bool kisalt = false}) {
    Duration diff = DateTime.now().difference(input);

    String saat = kisalt ? "sa" : "saat önce";
    String dakika = kisalt ? "d" : "dakika önce";
    String saniye = kisalt ? "sn" : "saniye önce";
    String simdi = kisalt ? "yeni" : "şimdi";

    if (diff.inDays >= 1) {
      return '${diff.inDays} gün önce';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} $saat';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} $dakika';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} $saniye';
    } else {
      return simdi;
    }
  }

  late AnimationController _animationCtrl;
  late Map _alinti;
  late Map _kullanici;
  late String _userMail;
  int _likeVisible = -1;
  bool _paylasVisible = false;

  String _zaman() => zamanCevir(DateTime.parse(_alinti['zaman']));

  @override
  void initState() {
    commentController.setComment([]);
    _alinti = widget.args['alinti'];
    _kullanici = widget.args['kullanici'];
    _userMail = widget.args['userMail'];
    endComment = false;
    getComments(postId: _alinti['id'], limit: 0);
    _animationCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeVisible = -1;
        _animationCtrl.reset();
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topBar(),
                  _quote(),
                  _addComment(),
                  const Divider(height: 0, thickness: 1),
                  const SizedBox(height: 10),
                  Obx(
                    () => ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: commentController.comments.length,
                      itemBuilder: (context, index) {
                        Map item = commentController.comments[index];
                        String date = zamanCevir(DateTime.parse(item['date']),
                            kisalt: true);
                        return InkWell(
                          onLongPress: () => removeDialog(
                              commentId: item['id'], postId: _alinti['id']),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => pictureZoom(
                                          userPhotoPath + item['photo'],
                                          item['photo'] != ""),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white,
                                        backgroundImage: item['photo'] == ""
                                            ? Image.asset(
                                                    "assets/images/avatar.png")
                                                .image
                                            : NetworkImage(
                                                userPhotoPath + item['photo']),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(item['user_name'].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  )),
                                              Text(
                                                date,
                                                style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Flexible(
                                            child: Text(
                                              item['comment'].toString(),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 0, thickness: 0.7),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: commentController.comments.isNotEmpty,
                      child: TextButton(
                          onPressed: () {
                            getComments(
                                postId: _alinti['id'],
                                limit: commentController.comments.length);
                          },
                          child: const Text(
                            "Daha Fazla Göster",
                            textAlign: TextAlign.center,
                          )),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void removeDialog({required int commentId, required int postId}) {
    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: const Text('Yorumu Sil'),
          content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: const Text('Kabul'),
              onPressed: () {
                Get.back();
                removeComment(id: commentId, postId: postId);
              },
            ),
          ],
        );
      },
    );
  }

  Container _quote() {
    return Container(
      color: colorBg3,
      child: Column(
        children: [
          const Divider(height: 0, thickness: 1),
          // alıntı bölümü üst bar
          Padding(
            padding:
                const EdgeInsets.only(top: 15, bottom: 5, left: 15, right: 15),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => pictureZoom(userPhotoPath + _kullanici['photo'],
                      _kullanici['photo'] != ""),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    backgroundImage: _kullanici['photo'] != ""
                        ? NetworkImage(userPhotoPath + _kullanici['photo'])
                        : Image.asset('assets/images/avatar.png').image,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kullanici['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _zaman(),
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12),
                    )
                  ],
                ),
                const Expanded(child: SizedBox()),
                PopupMenuButton(
                  onSelected: (value) async {
                    if (value == 1) {
                      await Clipboard.setData(
                          ClipboardData(text: _alinti['alinti']));
                      EasyLoading.showToast("Alıntı kopyalandı",
                          toastPosition: EasyLoadingToastPosition.center);
                    } else if (value == 2) {
                      deleteQuote(id: _alinti['id'], navIndex: 2);
                    }
                  },
                  child: const Icon(Icons.more_horiz),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(
                            Icons.copy,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text("Gönderiyi Kopyala")
                        ],
                      ),
                      value: 1,
                    ),
                    if (_kullanici['mail'] == _userMail)
                      PopupMenuItem(
                        child: Row(
                          children: const [
                            Icon(
                              Icons.delete_outline,
                              size: 23,
                            ),
                            SizedBox(width: 8),
                            Text("İçeriği Kaldır")
                          ],
                        ),
                        value: 2,
                      ),
                  ],
                )
              ],
            ),
          ),
          // alinti metin bölümü
          GestureDetector(
            onDoubleTap: () async {
              bool isLiked =
                  quotesController.likedQuotes["${_alinti['id']}-begeni"] ==
                      true;

              if (!isLiked) {
                _likeVisible = _alinti['id'];
                _animationCtrl.forward();
                setState(() {});
              }
              await likeQuote(
                  id: _alinti['id'], islem: isLiked ? "unlike" : "like");
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Text(
                    _alinti['alinti'],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Positioned.fill(
                  child: Visibility(
                    visible: _likeVisible == _alinti['id'],
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Lottie.asset(
                          'assets/lotties/like.json',
                          repeat: false,
                          controller: _animationCtrl,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          _alinti['isim'].isEmpty
              ? const SizedBox()
              // alıntı yazar kitap bilgisi
              : Padding(
                  padding: const EdgeInsets.only(left: 13, bottom: 10),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        _alinti['resim'],
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _alinti['isim'].length > 40
                              ? _alinti['isim'].substring(0, 39) + ".."
                              : _alinti['isim'],
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          _alinti['yazar'].length > 40
                              ? _alinti['yazar'].substring(0, 39) + ".."
                              : _alinti['yazar'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        )
                      ],
                    ),
                  ]),
                ),
          // alıntı alt bar (beğeni / favori)
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    likeQuote(
                        id: _alinti['id'],
                        islem: quotesController
                                    .likedQuotes["${_alinti['id']}-begeni"] ==
                                true
                            ? "unlike"
                            : "like");
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Row(
                          children: [
                            Icon(
                              quotesController.likedQuotes[
                                          "${_alinti['id']}-begeni"] ==
                                      true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: quotesController.likedQuotes[
                                          "${_alinti['id']}-begeni"] ==
                                      true
                                  ? Colors.red
                                  : null,
                            ),
                            const Text(
                              "  |  ",
                              style: TextStyle(color: Colors.black38),
                            ),
                            Text(
                              quotesController.likedQuotes[_alinti['id']]
                                  .toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )),
                  ),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    favoriteQuote(
                        id: _alinti['id'],
                        islem:
                            quotesController.favorites.contains(_alinti['id'])
                                ? 'unfavorite'
                                : 'favorite');
                  },
                  child: Obx(() => Icon(
                        quotesController.favorites.contains(_alinti['id'])
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.blueGrey[800],
                      )),
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 1),
        ],
      ),
    );
  }

  Container _addComment() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage: userController.userPhoto.value == "yok"
                ? Image.asset("assets/images/avatar.png").image
                : NetworkImage(userPhotoPath + userController.userPhoto.value),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 15),
                Flexible(
                  child: TextField(
                    controller: _commentCtrl,
                    onChanged: (value) {
                      _paylasVisible = value.isNotEmpty;
                      setState(() {});
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      hintText: "Yanıt Ekle",
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Visibility(
                    visible: _paylasVisible,
                    child: TextButton(
                        onPressed: () => addComment(
                            postId: _alinti['id'], commentCtrl: _commentCtrl),
                        child: const Text("Paylaş")))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _topBar() {
    return Container(
      margin: const EdgeInsets.only(left: 13, bottom: 15, top: 10),
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Row(
          children: const [
            Icon(
              Icons.arrow_back,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              "Ana Sayfa",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
