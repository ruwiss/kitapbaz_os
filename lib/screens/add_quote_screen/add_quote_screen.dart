import 'package:bigfamily/constants/admob_id.dart';
import 'package:bigfamily/constants/colors.dart';
import 'package:bigfamily/screens/add_quote_screen/add_quote_controller.dart';
import 'package:bigfamily/screens/add_quote_screen/add_quote_db.dart';
import 'package:bigfamily/screens/add_quote_screen/search_book_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../constants/widgets.dart';

class AddQuote extends StatefulWidget {
  const AddQuote({Key? key}) : super(key: key);

  @override
  State<AddQuote> createState() => _AddQuoteState();
}

class _AddQuoteState extends State<AddQuote> {
  final _alintiCtrl = TextEditingController();
  final _sayfaCtrl = TextEditingController();
  final _kitapCtrl = TextEditingController();
  final _addQuoteController = Get.put(AddQuoteController());
  String secilenSayfa = "";

  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    _loadBannerAd();
    getSearchItems("");
    super.initState();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdUnitId.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    _bannerAd.load();
  }

  secilenYazar() => _addQuoteController.secilenKitap.isEmpty
      ? ""
      : secilenSayfa + _addQuoteController.secilenKitap['yazarlar'][0]['adi'];

  Future getSearchItems(String text) async =>
      _addQuoteController.setKitapList(await searchBook(text: text));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _appBar(),
                  Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Center(
                                  child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 70),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      color: colorBg,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () => Get.back(),
                                                icon: const Icon(Icons.close),
                                              ),
                                              const Text(
                                                '  Kitap Seç',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          const Divider(
                                            color: Colors.black12,
                                            thickness: 1,
                                            height: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black26,
                                          ),
                                        ),
                                        child: TextField(
                                          onChanged: (value) {
                                            getSearchItems(value);
                                          },
                                          controller: _kitapCtrl,
                                          decoration: InputDecoration(
                                              prefixIcon: const Icon(
                                                  Icons.search,
                                                  size: 20),
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  getSearchItems("");
                                                  _kitapCtrl.clear();
                                                },
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                ),
                                              ),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Obx(
                                        () => Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _addQuoteController
                                                .kitapList.length,
                                            itemBuilder: (context, index) {
                                              Map item = _addQuoteController
                                                  .kitapList[index]['icerik'];

                                              String yazarlar = "";
                                              for (Map m in item['yazarlar']) {
                                                if (yazarlar.isNotEmpty) {
                                                  yazarlar += ", ";
                                                }
                                                yazarlar += m['adi'];
                                              }
                                              return GestureDetector(
                                                onTap: () {
                                                  _addQuoteController
                                                      .setSecilenKitap(item);
                                                  _kitapCtrl.clear();
                                                  Get.back();
                                                  setState(() {
                                                    secilenSayfa = "";
                                                    _sayfaCtrl.clear();
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10),
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                          item['resimB'],
                                                          width: 35),
                                                      const SizedBox(width: 10),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 200,
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              text: TextSpan(
                                                                  text: item[
                                                                      'adi'],
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .black87)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 220,
                                                            child: RichText(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              text: TextSpan(
                                                                  text:
                                                                      yazarlar,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black45)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(5),
                            decoration: containerDecoration(),
                            child: Obx(() => Row(
                                  children: [
                                    _addQuoteController.secilenKitap.isEmpty
                                        ? const Icon(
                                            Icons.book_sharp,
                                            color: colorYellow,
                                            size: 40,
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Image.network(
                                              _addQuoteController
                                                  .secilenKitap['resim'],
                                              width: 30,
                                            ),
                                          ),
                                    const SizedBox(width: 10),
                                    Obx(() => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // kitap önizleme
                                            Text(
                                              _addQuoteController
                                                      .secilenKitap.isEmpty
                                                  ? "Alıntı Hangi Kitaptan?"
                                                  : _addQuoteController
                                                              .secilenKitap[
                                                                  'adi']
                                                              .length <
                                                          18
                                                      ? _addQuoteController
                                                          .secilenKitap['adi']
                                                      : _addQuoteController
                                                              .secilenKitap[
                                                                  'adi']
                                                              .substring(
                                                                  0, 17) +
                                                          '...',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              _addQuoteController
                                                      .secilenKitap.isEmpty
                                                  ? "Kitap Yazarı"
                                                  : secilenYazar().length < 23
                                                      ? secilenYazar()
                                                      : secilenYazar()
                                                              .substring(
                                                                  0, 22) +
                                                          '...',
                                              style: const TextStyle(
                                                  color: Colors.black45),
                                            ),
                                          ],
                                        )),
                                    const Expanded(child: SizedBox(width: 10)),
                                    const Icon(Icons.add),
                                    const SizedBox(width: 10),
                                  ],
                                )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: containerDecoration(color: colorCream),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child:
                                // alıntı bölümü
                                TextField(
                              controller: _alintiCtrl,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Alıntınız..."),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: containerDecoration(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                const Text(
                                  "Sayfa",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  // sayfa
                                  child: TextField(
                                    onChanged: (value) {
                                      if (value
                                          .replaceAll(",", "")
                                          .replaceAll(".", "")
                                          .replaceAll("-", "")
                                          .replaceAll(" ", "")
                                          .isNotEmpty) {
                                        secilenSayfa =
                                            value.toString() + ". Sayfa ";
                                      } else {
                                        secilenSayfa = "";
                                      }
                                      setState(() {});
                                    },
                                    controller: _sayfaCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "isteğe bağlı"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                              onPressed: () {
                                if (_alintiCtrl.text.isNotEmpty) {
                                  addQuote(
                                      isim: _addQuoteController
                                          .secilenKitap['adi'],
                                      yazar: secilenYazar(),
                                      alinti: _alintiCtrl.text,
                                      resim: _addQuoteController
                                          .secilenKitap['resim']);
                                }
                              },
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              child: const Text(
                                "PAYLAŞ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isBannerAdLoaded)
            Container(
              child: AdWidget(ad: _bannerAd),
              width: _bannerAd.size.width.toDouble(),
              height: 72,
              alignment: Alignment.center,
            )
        ],
      ),
    ));
  }

  Column _appBar() {
    return Column(children: [
      Container(
        margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 15),
                const Text("Alıntı ekle",
                    style: TextStyle(
                      fontSize: 17,
                    )),
                const Expanded(child: SizedBox()),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      const Divider(
        height: 0,
        thickness: 1,
      ),
    ]);
  }
}
