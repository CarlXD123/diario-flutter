import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool _isReady = false;

  void loadAd(VoidCallback onLoaded, VoidCallback onFailed) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isReady = true;
          onLoaded();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isReady = false;
          onFailed();
        },
      ),
    );
  }

  void showRewardedAd({
    required BuildContext context,
    required VoidCallback onRewarded,
    required String featureKey, // Nuevo: para saber qué se desbloquea
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isUnlocked = prefs.getBool(featureKey) ?? false;

    if (isUnlocked) {
      onRewarded();
      return;
    }

    if (_isReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) => loadAd(() {}, () {}),
        onAdFailedToShowFullScreenContent: (ad, error) => loadAd(() {}, () {}),
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) async {
        await prefs.setBool(featureKey, true);
        onRewarded();
      });

      _rewardedAd = null;
      _isReady = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Anuncio no disponible, intenta más tarde")),
      );
    }
  }


  bool get isReady => _isReady;
}
