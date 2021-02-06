import 'dart:io';

import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import 'deco_localizations.dart';

/// Show loading message
void showLoadingDialog(context) {
  bool isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white : Color(0xFF1B1E28))
          ),

          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(22.0, 0.0, 0.0, 0.0),
            child: Text(
              DecoLocalizations.of(context).localizedString("dialog_please_wait"),
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1B1E28),
                fontSize: 14,
                height: 16 / 14
              ),
            ),
          )
        ],
      ),
    ),
  );
}

/// Show error messages
void showErrorDialog(context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(DecoLocalizations.of(context).localizedString("dialog_ok")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

/// Adds ad widget to the bottom of the screen in case facebook ads are enabled
OverlayEntry addAdWidget({ BuildContext context }) {
  if (!Config.facebookAdsEnabled) {
    return null;
  }

  /// Assuming that ad size is set to 'small'
  double height = 50.0;

  if (Config.facebookAdType == 'banner' && Config.facebookAdSize != 'small')
    height = 90.0;

  else if(Config.facebookAdType == 'native banner' || Config.facebookAdType == 'native') {
    if(Config.facebookAdSize == 'medium') {
      height = 100.0;
    } else if(Config.facebookAdSize == 'large') {
      height = 120.0;
    }
  }

  OverlayEntry adPlacementWidget = OverlayEntry(
    builder: (context) {
      return Positioned(
        child: Stack(
          children: [
            Container(
              color: Config.defaultColor == 'dark'? Color(0xFF1B1E28) : Color(0xFFFFFFFF),
            ),
            adWidget(context),
          ],
        ),
        top: Config.facebookAdPosition == 'bottom' ? null : MediaQuery.of(context).padding.top,
        bottom: Config.facebookAdPosition == 'bottom' ? MediaQuery.of(context).padding.bottom : null,
        left: 0,
        height: height,
        width: MediaQuery.of(context).size.width,
      );
    }
  );

  Overlay.of(context).insert(
    adPlacementWidget
  );

  return adPlacementWidget;
}

/// Adds ad padding to the screen in case the facebook ads are enabled
EdgeInsets adPadding({ BuildContext context, EdgeInsets defaultPadding }){
  if (Config.facebookAdsEnabled && Config.facebookAdLoaded) {

    /// Assuming that ad size is set to 'small'
    double height = 50.0;
    EdgeInsets size;

    if (Config.facebookAdType == 'banner' && Config.facebookAdSize != 'small')
      height = 90.0;

    else if(Config.facebookAdType == 'native banner' || Config.facebookAdType == 'native') {
      if(Config.facebookAdSize == 'medium') {
        height = 100.0;
      } else if(Config.facebookAdSize == 'large') {
        height = 120.0;
      }
    }

    if(defaultPadding == null) {
      defaultPadding = EdgeInsets.all(0);
    }

    size = EdgeInsets.only(
        top: Config.facebookAdPosition == 'top'? height + defaultPadding?.top : defaultPadding?.top,
        bottom: Config.facebookAdPosition == 'bottom'? height + defaultPadding?.bottom : defaultPadding?.bottom,
        right: defaultPadding?.right,
        left: defaultPadding?.left
    );

    return size;
  }

  return defaultPadding ?? EdgeInsets.all(0);
}

/// Creates the ad widget which is placed according to the Config position
Widget adWidget(BuildContext context) {
  if (Config.facebookAdType == 'banner') {
    return FacebookBannerAd(
      placementId: Platform.isIOS
          ? Config.facebookIOSBannerAdPlacementId
          : Config.facebookAndroidBannerAdPlacementId,
      bannerSize: Config.facebookAdSize == 'small'
          ? BannerSize.STANDARD
          : BannerSize.LARGE,
      listener: (result, value) {
        if (result == BannerAdResult.ERROR) {
          Config.facebookAdLoaded = false;
          Config.facebookAdOverlay.remove();
          Config.facebookAdOverlay = null;
        }
      },
    );
  }

  if (Config.facebookAdType == 'native banner') {
    return FacebookNativeAd(
      width: double.infinity,
      placementId: Config.facebookAndroidNativeBannerAdPlacementId,
      adType: NativeAdType.NATIVE_BANNER_AD,
      bannerAdSize: Config.facebookAdSize == 'small'
          ? NativeBannerAdSize.HEIGHT_50
          : Config.facebookAdSize == 'medium'
          ? NativeBannerAdSize.HEIGHT_100
          : NativeBannerAdSize.HEIGHT_120,
      listener: (result, value) {
        if (result == NativeAdResult.ERROR) {
          Config.facebookAdLoaded = false;
          Config.facebookAdOverlay.remove();
          Config.facebookAdOverlay = null;
        }
      },
    );
  }

  if (Config.facebookAdType == 'native') {
    return FacebookNativeAd(
      width: double.infinity,
      placementId: Platform.isIOS
          ? Config.facebookIOSNativeAdPlacementId
          : Config.facebookAndroidNativeAdPlacementId,
      adType: NativeAdType.NATIVE_AD,
      height: Config.facebookAdSize == 'small'
          ? 50.0
          : Config.facebookAdSize == 'medium'
          ? 100.0
          : 120.0,
      listener: (result, value) {
        if (result == NativeAdResult.ERROR) {
          Config.facebookAdLoaded = false;
          Config.facebookAdOverlay.remove();
          Config.facebookAdOverlay = null;
        }
      },
    );
  }

  return Placeholder(
    color: Colors.blue,
  );

}

String localizedDate(context, String date) {
  return DateFormat("d MMM y", Localizations.localeOf(context).languageCode)
      .format(DateTime.parse(date));
}
