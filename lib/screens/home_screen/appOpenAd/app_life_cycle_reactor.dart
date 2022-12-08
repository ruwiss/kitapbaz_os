import 'package:bigfamily/constants/admob_id.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppLifecycleReactor {
  late AppOpenAd _appOpenAd;
  bool _isAdLoaded = false;
  void loadAppOpenAd() {
    AppOpenAd.load(
        adUnitId: AdUnitId.appOpen,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
            onAdLoaded: (ad) {
              _listenToAppStateChanges();
              _isAdLoaded = true;
              _appOpenAd = ad;
              _appOpenAdEvents();
            },
            onAdFailedToLoad: (LoadAdError error) => print(
                'AppOpenAd Error: ${error.message} | Error Code : ${error.code}')),
        orientation: AppOpenAd.orientationPortrait);
  }

  void _appOpenAdEvents() {
    _appOpenAd.fullScreenContentCallback =
        FullScreenContentCallback(onAdDismissedFullScreenContent: (_) {
      _appOpenAd.dispose();
      loadAppOpenAd();
    }, onAdFailedToShowFullScreenContent: (_, __) {
      _appOpenAd.dispose();
      loadAppOpenAd();
    });
  }

  void _listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.foreground && _isAdLoaded) {
      _appOpenAd.show();
    }
  }
}
