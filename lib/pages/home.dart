import 'dart:async';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

import '../ad_manager.dart';
import 'next_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo();
  int _coins = 0;
  final _nativeAdController = NativeAdmobController();

  //InterstitialAd create
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        targetingInfo: targetingInfo,
        adUnitId: InterstitialAd.testAdUnitId, //AdManager.interstitialAdUnitId
        listener: (MobileAdEvent event) {
          print('Interstitial Event: $event');
        });
  }

  //BannerAd create
  BannerAd createBannerAdd() {
    return BannerAd(
        targetingInfo: targetingInfo,
        adUnitId: BannerAd.testAdUnitId, //AdManager.bannerAdUnitId
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          print('Banner Event: $event');
        });
  }

  @override
  void initState() {
    super.initState();

    //must be initialize your appId
    FirebaseAdMob.instance.initialize(appId: 'YOUR_APP_ID'); //AdManager.appId

    //Banner & InterstitialAd Load
    _bannerAd = createBannerAdd()..load();
    _interstitialAd = createInterstitialAd()..load();

    //RewardedVideoAd
    RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo);
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print('Rewarded event: $event');
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _coins += rewardAmount;
        });
      }
    };

  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 10), () {
      //interstitial ad not allowed your app start screen, this is not allowed by admob, maybe because of this they rejected your app.
      // when you interstitial ad show on app first screen then your app facing publishing problem on playStore.
      _bannerAd?.show();
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _bannerAd?.dispose();
                _bannerAd = null;
                _interstitialAd?.show();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => MyNextPage()));
              }),
          IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () async {
                _bannerAd?.dispose();
                _bannerAd = null;
                await RewardedVideoAd.instance.show();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyNextPage(
                      ads: _coins,
                        )));
              }),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          return Container(
              margin: EdgeInsets.all(8),
              color: Colors.blue,
              height: 200,
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
              ));
        },
        separatorBuilder: (context, index) {
          return index % 4 == 0
              ? Container(
                  margin: EdgeInsets.all(8),
                  height: 200,
                  color: Colors.green,
                  child: NativeAdmob(
                    adUnitID: NativeAd.testAdUnitId,
                    controller: _nativeAdController,
                    type: NativeAdmobType.full,
                    loading: Center(child: CircularProgressIndicator()),
                    error: Text('failed to load'),
                  ))
              : Container();
        },
        itemCount: 20,
      ),
    );
  }

}
