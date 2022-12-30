import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'package:quiz_spreadsheet/const.dart';

class MyBanner extends StatefulWidget {
  const MyBanner({Key? key}) : super(key: key);

  @override
  State<MyBanner> createState() => _MyBannerState();
}

class _MyBannerState extends State<MyBanner> {
  final BannerAd _smartBanner = BannerAd(
    adUnitId: Platform.isAndroid
        ? kIsRelease
            ? kAdmobIdBanner
            : 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716',
    size: AdSize.largeBanner,
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
    return kAdDisplay
        ? SizedBox(
            width: _smartBanner.size.width.toDouble(),
            height: _smartBanner.size.height.toDouble(),
            child: AdWidget(ad: _smartBanner),
          )
        : Container();
  }
}
