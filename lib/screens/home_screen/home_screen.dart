import 'package:bigfamily/components/native_ad_widget.dart';
import 'package:bigfamily/constants/admob_id.dart';
import 'package:bigfamily/constants/colors.dart';
import 'package:bigfamily/screens/account_settings_screen/account_settings_screen.dart';
import 'package:bigfamily/screens/add_quote_screen/add_quote_screen.dart';
import 'package:bigfamily/screens/comment_screen/comment_screen.dart';
import 'package:bigfamily/screens/home_screen/home_screen_db.dart';
import 'package:bigfamily/screens/user_profile_screen/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import '../../constants/db.dart';
import '../account_settings_screen/account_settings_db.dart';
import 'appOpenAd/app_life_cycle_reactor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

late AnimationController _animationCtrl;
final _homeScrollController = ScrollController();
bool _onBottom = false;
int _topNavBarIndex = 0;
String _userMail = "";
int _likeVisible = -1;

String zamanCevir(DateTime input) {
  Duration diff = DateTime.now().difference(input);

  if (diff.inDays >= 1) {
    return '${diff.inDays} gün önce';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours} saat önce';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} dakika önce';
  } else if (diff.inSeconds >= 1) {
    return '${diff.inSeconds} saniye önce';
  } else {
    return 'şimdi';
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late InterstitialAd _interstitialAd;
  bool _adShowed = false;
  bool _isAdloaded = false;

  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    getBlockedUsers(); // with get quotes
    getFavorites();
    getProfilePhoto();
    _getUserInfo();
    _loadInterstitialAd();
    _setAppOpenAd();
    _homeScrollController.addListener(_scrollListener);
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
    _homeScrollController.removeListener(_scrollListener);
    _animationCtrl.dispose();
    super.dispose();
  }

  Future _getUserInfo() async {
    _userMail = await getUserMail();
    setState(() {});
  }

  void _loadInterstitialAd() {
    void loadEvents() {
      _interstitialAd.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdloaded = false;
      }, onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _isAdloaded = false;
      });
    }

    InterstitialAd.load(
        adUnitId: AdUnitId.interstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _isAdloaded = true;
            _interstitialAd = ad;
            loadEvents();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print(
                'InterstitialAd Error: ${error.message} | Error Code : ${error.code}');
          },
        ));
  }

  void _setAppOpenAd() {
    _appLifecycleReactor = AppLifecycleReactor();
    _appLifecycleReactor.loadAppOpenAd();
  }

  void _scrollListener() async {
    if (!_onBottom) {
      if (_homeScrollController.position.extentAfter < 10) {
        _onBottom = true;
        if (!_adShowed && _isAdloaded) {
          _adShowed = true;
          _interstitialAd.show();
        }

        if (_topNavBarIndex == 0) {
          await getQuotes(quotesController.quotes.length);
        } else if (_topNavBarIndex == 1) {
          await getQuotes(quotesController.quotes.length, like: true);
        }
        _onBottom = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorBg2,
        body: Column(
          children: [
            _appBar(),
            Flexible(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_topNavBarIndex == 0) {
                    await getQuotes(0);
                  } else if (_topNavBarIndex == 1) {
                    await getQuotes(0, like: true);
                  }
                },
                child: Obx(
                  () => quotesController.quotes.isEmpty
                      ? Column(
                          children: [
                            _topMenu(),
                            const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: CircularProgressIndicator(
                                color: colorRed,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _homeScrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: quotesController.quotes.length,
                          itemBuilder: (context, index) {
                            Map alinti =
                                quotesController.quotes[index]['veri1'];
                            Map kullanici =
                                quotesController.quotes[index]['veri2'];
                            String zaman =
                                zamanCevir(DateTime.parse(alinti['zaman']));

                            return Column(
                              children: [
                                // top navigation bar
                                index == 0
                                    ? _topMenu()
                                    : index % 4 == 0
                                        ? const NativeAdWidget()
                                        : const SizedBox(),
                                Obx(
                                  () => Container(
                                    color: zaman.contains('saat') ||
                                            zaman.contains('gün')
                                        ? Colors.white
                                        : index < 2
                                            ? colorCream
                                            : Colors.white,
                                    margin: EdgeInsets.symmetric(
                                        vertical: index == 0 ? 0 : 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Divider(height: 1, thickness: 1),
                                        // alıntı bölümü üst bar
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              bottom: 5,
                                              left: 15,
                                              right: 15),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (kullanici['mail'] !=
                                                      _userMail) {
                                                    Get.to(
                                                        () => UserProfile(
                                                            user: kullanici),
                                                        transition: Transition
                                                            .rightToLeft);
                                                  } else {
                                                    Get.to(
                                                        () =>
                                                            const AccountSettings(),
                                                        transition: Transition
                                                            .rightToLeft);
                                                  }
                                                },
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 22,
                                                  backgroundImage: kullanici[
                                                              'photo'] !=
                                                          ""
                                                      ? NetworkImage(
                                                          userPhotoPath +
                                                              kullanici[
                                                                  'photo'])
                                                      : Image.asset(
                                                              'assets/images/avatar.png')
                                                          .image,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (kullanici['mail'] !=
                                                          _userMail) {
                                                        Get.to(
                                                            () => UserProfile(
                                                                user:
                                                                    kullanici),
                                                            transition: Transition
                                                                .rightToLeft);
                                                      } else {
                                                        Get.to(
                                                            () =>
                                                                const AccountSettings(),
                                                            transition: Transition
                                                                .rightToLeft);
                                                      }
                                                    },
                                                    child: Text(
                                                      kullanici['name']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Text(
                                                    zaman,
                                                    style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              ),
                                              const Expanded(child: SizedBox()),
                                              PopupMenuButton(
                                                onSelected: (value) async {
                                                  if (value == 1) {
                                                    await Clipboard.setData(
                                                        ClipboardData(
                                                            text: alinti[
                                                                'alinti']));
                                                    EasyLoading.showToast(
                                                        "Alıntı kopyalandı",
                                                        toastPosition:
                                                            EasyLoadingToastPosition
                                                                .center);
                                                  } else if (value == 2) {
                                                    _reportQuote(
                                                        info: alinti,
                                                        reportType: "içerik");
                                                  } else if (value == 3) {
                                                    deleteQuote(
                                                        id: alinti['id'],
                                                        navIndex:
                                                            _topNavBarIndex);
                                                  } else if (value == 4) {
                                                    _reportQuote(
                                                        info: alinti,
                                                        reportType:
                                                            "kullanici");
                                                  }
                                                },
                                                child: const Icon(
                                                    Icons.more_horiz),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.copy,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                            "Gönderiyi Kopyala")
                                                      ],
                                                    ),
                                                    value: 1,
                                                  ),
                                                  PopupMenuItem(
                                                    child: Row(
                                                      children: const [
                                                        Icon(Icons
                                                            .flag_outlined),
                                                        SizedBox(width: 8),
                                                        Text("Gönderiyi Bildir")
                                                      ],
                                                    ),
                                                    value: 2,
                                                  ),
                                                  if (kullanici['mail'] ==
                                                      _userMail)
                                                    PopupMenuItem(
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 23,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text("İçeriği Kaldır")
                                                        ],
                                                      ),
                                                      value: 3,
                                                    ),
                                                  if (kullanici['mail'] !=
                                                      _userMail)
                                                    PopupMenuItem(
                                                      child: Row(
                                                        children: const [
                                                          Icon(
                                                            Icons
                                                                .person_outlined,
                                                            size: 23,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              "Kullanıcıyı Bildir")
                                                        ],
                                                      ),
                                                      value: 4,
                                                    ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        // alinti metin bölümü
                                        GestureDetector(
                                          onDoubleTap: () async {
                                            bool isLiked = quotesController
                                                        .likedQuotes[
                                                    "${alinti['id']}-begeni"] ==
                                                true;

                                            if (!isLiked) {
                                              _likeVisible = alinti['id'];
                                              _animationCtrl.forward();
                                              setState(() {});
                                            }
                                            await likeQuote(
                                                id: alinti['id'],
                                                islem: isLiked
                                                    ? "unlike"
                                                    : "like");
                                          },
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(13),
                                                child: Text(
                                                  alinti['alinti'].toString(),
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Visibility(
                                                  visible: _likeVisible ==
                                                      alinti['id'],
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: SizedBox(
                                                      width: 150,
                                                      height: 150,
                                                      child: Lottie.asset(
                                                        'assets/lotties/like.json',
                                                        repeat: false,
                                                        controller:
                                                            _animationCtrl,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        alinti['isim'].isEmpty
                                            ? const SizedBox()
                                            // alıntı yazar kitap bilgisi
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 13, bottom: 10),
                                                child: Row(children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Image.network(
                                                      alinti['resim'],
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        alinti['isim'].length >
                                                                40
                                                            ? alinti['isim']
                                                                    .substring(
                                                                        0, 39) +
                                                                ".."
                                                            : alinti['isim'],
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            fontSize: 13),
                                                      ),
                                                      Text(
                                                        alinti['yazar'].length >
                                                                40
                                                            ? alinti['yazar']
                                                                    .substring(
                                                                        0, 39) +
                                                                ".."
                                                            : alinti['yazar'],
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.black54),
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
                                                      id: alinti['id'],
                                                      islem: quotesController
                                                                      .likedQuotes[
                                                                  "${alinti['id']}-begeni"] ==
                                                              true
                                                          ? "unlike"
                                                          : "like");
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 3,
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        quotesController.likedQuotes[
                                                                    "${alinti['id']}-begeni"] ==
                                                                true
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        size: 18,
                                                        color: quotesController
                                                                        .likedQuotes[
                                                                    "${alinti['id']}-begeni"] ==
                                                                true
                                                            ? Colors.red
                                                            : null,
                                                      ),
                                                      const Text(
                                                        "  |  ",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black38),
                                                      ),
                                                      Text(
                                                        quotesController
                                                            .likedQuotes[
                                                                alinti['id']]
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Expanded(child: SizedBox()),

                                              // YORUM ICONU
                                              TextButton(
                                                child: Text(
                                                    alinti['yorum_sayisi'] == 0
                                                        ? "Yorum Yap"
                                                        : "${alinti['yorum_sayisi']} Yorum",
                                                    style: const TextStyle(
                                                        color: colorRed)),
                                                onPressed: () {
                                                  Get.to(
                                                      () =>
                                                          CommentScreen(args: {
                                                            "alinti": alinti,
                                                            "kullanici":
                                                                kullanici,
                                                            "userMail":
                                                                _userMail
                                                          }),
                                                      transition:
                                                          Transition.downToUp);
                                                },
                                              ),
                                              const SizedBox(width: 15),
                                              GestureDetector(
                                                onTap: () {
                                                  favoriteQuote(
                                                      id: alinti['id'],
                                                      islem: quotesController
                                                              .favorites
                                                              .contains(
                                                                  alinti['id'])
                                                          ? 'unfavorite'
                                                          : 'favorite');
                                                },
                                                child: Icon(
                                                  quotesController.favorites
                                                          .contains(
                                                              alinti['id'])
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: Colors.blueGrey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const Divider(height: 1, thickness: 1),
                                        // scroll bottom loading
                                        Container(
                                          child: quotesController
                                                          .isLoading.value ==
                                                      true &&
                                                  quotesController
                                                              .quotes.length -
                                                          1 ==
                                                      index
                                              ? Column(
                                                  children: const [
                                                    SizedBox(height: 15),
                                                    CircularProgressIndicator(
                                                      color: colorOrange,
                                                    ),
                                                    SizedBox(height: 15),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topMenu() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 6),
      child: DefaultTabController(
        length: 3,
        initialIndex: _topNavBarIndex,
        child: TabBar(
          labelColor: colorSoftBlack,
          indicatorColor: colorRed,
          tabs: const [
            Tab(text: 'En yeniler'),
            Tab(
              text: 'Beğenilenler',
            ),
            Tab(text: 'Favorilerim'),
          ],
          onTap: (index) async {
            var result = await onNavigationSelect(index);
            if (result is bool) {
              EasyLoading.showToast('Favoriniz bulunmamaktadır');
            } else {
              _topNavBarIndex = index;
            }
          },
        ),
      ),
    );
  }

  Future _reportQuote({required Map info, required String reportType}) async {
    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        var messageController = TextEditingController();
        return AlertDialog(
          title: Text(
              reportType == "içerik" ? 'İçerik Bildir' : 'Kullanıcı Bildir'),
          content: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: messageController,
                decoration: const InputDecoration(hintText: 'Bildirme nedeni'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                if (messageController.text.isNotEmpty) {
                  await reportQuote(
                    info: reportType == "içerik" ? info['id'] : info['mail'],
                    message: messageController.text,
                    reportType: reportType,
                  );
                  Get.back();
                  EasyLoading.showToast(
                      reportType == "içerik"
                          ? 'Gönderi bildirildi'
                          : 'Kullanıcı bildirildi',
                      toastPosition: EasyLoadingToastPosition.center);
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  Column _appBar() {
    return Column(children: [
      Container(
        color: Colors.white,
        child: Container(
          margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/kitapbaz.png',
                    scale: 7.5,
                  ),
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: () => Get.to(() => const AddQuote(),
                        transition: Transition.rightToLeft),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 2.2, color: colorSoftBlack),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () => Get.to(() => const AccountSettings(),
                        transition: Transition.rightToLeft),
                    icon: const Icon(Icons.person,
                        size: 30, color: colorSoftBlack),
                  )
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
      const Divider(
        height: 0,
        thickness: 1,
      ),
    ]);
  }
}
