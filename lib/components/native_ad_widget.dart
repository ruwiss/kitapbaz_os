import 'dart:async';

import 'package:bigfamily/constants/admob_id.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NativeAdState();
}

class NativeAdState extends State<NativeAdWidget> {
  late NativeAd? _nativeAd;
  final Completer<NativeAd> nativeAdCompleter = Completer<NativeAd>();

  @override
  void initState() {
    super.initState();

    _nativeAd = NativeAd(
      adUnitId: AdUnitId.native,
      request: const AdRequest(nonPersonalizedAds: true),
      customOptions: <String, Object>{},
      factoryId: "listTile",
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          nativeAdCompleter.complete(ad as NativeAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError err) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$ad onAdOpened.'),
        onAdClosed: (Ad ad) => print('$ad onAdClosed.'),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd!.dispose();
    _nativeAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NativeAd>(
      future: nativeAdCompleter.future,
      builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
        Widget child;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            child = Container();
            break;
          case ConnectionState.done:
            if (snapshot.hasData) {
              child = AdWidget(ad: _nativeAd!);
            } else {
              child = const SizedBox();
            }
        }

        return Container(
          height: 72,
          child: child,
          color: const Color(0xFFFFFFFF),
        );
      },
    );
  }
}
