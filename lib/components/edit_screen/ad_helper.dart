import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdHelper {
  static void loadRewardedAd({
    required Function(RewardedAd ad) onAdLoaded,
    required void Function() onAdFailed,

  }) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Error al cargar anuncio recompensado: $error');
          onAdFailed();
        },
      ),
    );
  }
}
