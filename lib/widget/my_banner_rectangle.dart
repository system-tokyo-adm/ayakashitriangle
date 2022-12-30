import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'package:quiz_spreadsheet/const.dart';

class MyBannerRectangle extends StatefulWidget {
  const MyBannerRectangle({Key? key}) : super(key: key);

  @override
  State<MyBannerRectangle> createState() => _MyBannerRectangleState();
}

class _MyBannerRectangleState extends State<MyBannerRectangle> {
  final BannerAd _smartBanner = BannerAd(
    adUnitId: Platform.isAndroid
        ? kIsRelease
            ? kAdmobIdBannerRectangle
            : 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716',
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
      },
    ),
  );

  @override
  void initState() {
    _smartBanner.load();
    super.initState();
  }

  @override
  void dispose() {
    _smartBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _smartBanner.size.width.toDouble(),
      height: _smartBanner.size.height.toDouble(),
      child: AdWidget(ad: _smartBanner),
    );
  }
}
