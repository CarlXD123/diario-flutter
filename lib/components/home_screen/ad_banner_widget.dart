import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatelessWidget {
  final BannerAd bannerAd;

  const AdBannerWidget({required this.bannerAd});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: bannerAd.size.height.toDouble(),
      width: bannerAd.size.width.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}
