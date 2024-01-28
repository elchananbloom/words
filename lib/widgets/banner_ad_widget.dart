import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  String adUnitId;

  BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.adSize = AdSize.fullBanner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  /// The banner ad to show. This is `null` until the ad is actually loaded.
  BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: _bannerAd == null
            // Nothing to render yet.
            ? const SizedBox()
            // The actual ad.
            : AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  /// Loads a banner ad.
  void _loadAd() {
    setState(() {
      _bannerAd = BannerAd(
        size: widget.adSize,
        adUnitId: widget.adUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            Sentry.captureMessage('BannerAd loaded: $ad');
            debugPrint('BannerAd loaded: $ad');
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (ad, error) {
            Sentry.captureMessage('BannerAd failed to load: $error');
            debugPrint('BannerAd failed to load: $error');
            ad.dispose();
          },
          onAdClosed: (ad) {
            Sentry.captureMessage('BannerAd closed: $ad');
          },
          onAdOpened: (ad) {
            Sentry.captureMessage('BannerAd opened: $ad');
          },
        ),
      )..load();
    });
  }
}
