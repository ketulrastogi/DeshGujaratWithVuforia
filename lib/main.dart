import 'dart:convert';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'config.dart';
import 'helpers/deco_localizations.dart';
import 'helpers/wordpress.dart';
import 'models/post_model.dart';
import 'models/category_model.dart';
import 'helpers/helpers.dart';
import 'screens/home_screen.dart';
import 'screens/single_post.dart';

void main() => runApp(DecoNews());

class DecoNews extends StatefulWidget {
  static final navKey = new GlobalKey<NavigatorState>();
  static final scaffoldKey = new GlobalKey<ScaffoldState>();
  static _DecoNewsState of(BuildContext context) =>
      context.findAncestorStateOfType<_DecoNewsState>();
  const DecoNews({Key navKey}) : super(key: navKey);

  @override
  _DecoNewsState createState() => _DecoNewsState();
}

class _DecoNewsState extends State<DecoNews> {
  /// Keeps index of selected item from drawer
  int _selectedDrawerItem = 0;

  /// Theme brightness
  Brightness _brightness;

  /// Right to left language support
  bool _rtlEnabled = false;

  /// Determines if adMob ad is loaded
  bool isAdMobLoaded = false;

  /// Firebase messaging
  static FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    /// set default app theme
    _setDefaultBrightness();

    ///init runtime RTL support
    _setDefaultRTLSupport();

    /// init push notifications
    _initPushNotifications();

    /// init AdMob
    _initAdMob();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: MaterialApp(
        locale: _getLocale(),
        navigatorKey: DecoNews.navKey,
        title: Config.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: _brightness,
          canvasColor: _brightness == Brightness.dark
              ? Color(0xFF282C39)
              : Color(0xFFFAFAFA),
          primaryColor: _brightness == Brightness.dark
              ? Color(0xFF1B1E28)
              : Color(0xFFFFFFFF),
        ),
        localizationsDelegates: <LocalizationsDelegate>[
          //add custom localizations delegate
          const DecoLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: _getLocalesFromLocaleCodes(),
        builder: (BuildContext context, Widget child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: child,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
      padding: appPadding(),
    );
  }

  /// Returns app padding depending on the type of ads and their position
  EdgeInsets appPadding() {
    /// Since banner size for adMob banner is depending on screen height
    /// If the screen height is lesser or equal to 400px, banner height is 32px
    /// If the screen height is bigger than 400px and smaller or equal to 720px banner height is 50px
    /// If the screen height is bigger than 720px banner height is 90px
    /// Accordingly, screen padding is set, so the content is not covered by the banner.

    double screenHeight = MediaQueryData.fromWindow(window).size.height;
    double adHeight = 32;
    if (screenHeight > 400 && screenHeight <= 720) {
      adHeight = 50;
    } else if (screenHeight > 720) {
      adHeight = 90;
    }

    if (isAdMobLoaded) {
      if (Config.adMobPosition == 'bottom') {
        return EdgeInsets.only(bottom: adHeight);
      }

      return EdgeInsets.only(top: adHeight);
    }

    return EdgeInsets.all(0);
  }

  Locale _getLocale() {
    Locale locale = Locale(Config.defaultLocale);

    if (_rtlEnabled) locale = Locale('ar');

    return locale;
  }

  /// Adds locales to the locale list
  List<Locale> _getLocalesFromLocaleCodes() {
    List<Locale> locales = [Locale(Config.defaultLocale)];

    if (Config.defaultLocale != 'ar')
      locales.add(Locale('ar'));
    else
      locales.add(Locale('en'));

    return locales;
  }

  /// Returns index of selected item in drawer
  int getSelected() {
    return _selectedDrawerItem;
  }

  /// Updates index of selected item in drawer
  void setSelected(int index) {
    _selectedDrawerItem = index;
  }

  /// On app launch set correct theme color
  void _setDefaultBrightness() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String brightness = (prefs.getString('brightness') ?? '');

    if (brightness != 'light' && brightness != 'dark') {
      brightness = Config.defaultColor == 'dark' ? 'dark' : 'light';
    }

    setBrightness(brightness == 'dark' ? Brightness.dark : Brightness.light);
  }

  /// Change theme color
  Future<void> setBrightness(Brightness brightness) async {
    setState(() {
      _brightness = brightness;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'brightness', brightness == Brightness.dark ? 'dark' : 'light');
  }

  /// Change the app padding if adMob ad loads
  void setAdMobLoaded(bool isLoaded) async {
    if (isAdMobLoaded != isLoaded)
      setState(() {
        isAdMobLoaded = isLoaded;
      });
  }

  /// On app launch set correct text and screen direction support
  void _setDefaultRTLSupport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRTLEnabled = (prefs.getBool('isRTLEnabled') ?? null);

    if (isRTLEnabled == null) {
      isRTLEnabled = Config.defaultLocale == 'ar';
    }

    setRTLSettings(isRTLEnabled);
  }

  /// Change right to left support settings
  Future<void> setRTLSettings(bool enabled) async {
    setState(() => _rtlEnabled = enabled);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRTLEnabled', enabled);
  }

  /// init push notifications
  Future<void> _initPushNotifications() async {
    if (!Config.pushNotificationsEnabled) {
      return;
    }

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        _processPushNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        _processPushNotification(message);
      },
    );

    if (Platform.isIOS) {
      iOSPermission();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    firebaseMessaging.getToken().then((token) {
      if (prefs.getBool('isPushNotificationEnabled') ?? true) {
        setSubscription(true);
      }
    });
  }

  void _processPushNotification(payload) async {
    // get context
    final context = DecoNews.navKey.currentState.overlay.context;

    // debug lines
    // print('Processing push notification. Payload:');
    // print(payload);
    // print(payload['data']);
    // print(payload['data']['post_id']);

    // show loading message
    showLoadingDialog(context);

    // get post id
    int postID = int.parse(payload['data']['post_id']);

    try {
      // get post data by id
      Response postResponse = await WordPress.fetchPost(postID);
      var postData = jsonDecode(postResponse.body);

      // get category data
      var categoryID = postData['categories'][0];
      Response categoryResponse =
          await WordPress.fetchCategory(categoryID.toString());
      var categoryData = jsonDecode(categoryResponse.body);

      CategoryModel category = CategoryModel.fromJson(categoryData[0]);
      PostModel post = PostModel.fromJson(postData, category);

      // close dialog and open article
      Navigator.of(context, rootNavigator: true).pop('dialog');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SinglePost(post),
      ));
    } catch (exception) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      DecoNews.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('An error occured loading post data!'),
        duration: Duration(seconds: 5),
      ));
    }
  }

  /// ask for permission on iOS
  void iOSPermission() {
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  setSubscription(value) {
    value ? _subscribe() : _unsubscribe();
    _setSettingToStorage(value);
  }

  static _subscribe() {
    firebaseMessaging.subscribeToTopic('DECO_NEWS');
  }

  static _unsubscribe() {
    firebaseMessaging.unsubscribeFromTopic('DECO_NEWS');
  }

  static void _setSettingToStorage(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPushNotificationEnabled', value);
  }

  /// Init AdMob
  _initAdMob() {
    if (!Config.adMobEnabled) {
      return;
    }

    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    FirebaseAdMob.instance.initialize(
        appId: isIOS ? Config.adMobiOSAppID : Config.adMobAndroidID);

    BannerAd myBanner = BannerAd(
      // Replace the testAdUnitId with an ad unit id from the AdMob dash.
      // https://developers.google.com/admob/android/test-ads
      // https://developers.google.com/admob/ios/test-ads
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.smartBanner,
      listener: (MobileAdEvent event) {
        print("BannerAd event is $event");
        if (event == MobileAdEvent.loaded) {
          /// handle a variable if an ad was loaded to enable bottom padding
          setAdMobLoaded(true);
        } else if (event == MobileAdEvent.failedToLoad) {
          /// handle a variable if an ad was not loaded to disable additional bottom padding
          setAdMobLoaded(false);
        }
      },
    );

    /// load banner
    myBanner
      ..load()
      ..show(
          anchorType: Config.adMobPosition != 'top'
              ? AnchorType.bottom
              : AnchorType.top);

    if (Config.adMobShowInterstitialAd) {
      InterstitialAd myInterstitial = InterstitialAd(
        // Replace the testAdUnitId with an ad unit id from the AdMob dash.
        // https://developers.google.com/admob/android/test-ads
        // https://developers.google.com/admob/ios/test-ads
        adUnitId: InterstitialAd.testAdUnitId,
        listener: (MobileAdEvent event) {
          print("InterstitialAd event is $event");
        },
      );

      myInterstitial
        ..load()
        ..show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
          horizontalCenterOffset: 0.0,
        );
    }
  }
}
