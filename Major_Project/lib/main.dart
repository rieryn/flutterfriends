import 'package:animated_splash/animated_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_i18n/loaders/local_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:major_project/models/live_chat_message_model.dart';
import 'package:major_project/services/firebase/firestore_services.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/localdb/covid_db.dart';
import 'package:major_project/services/utils/location_service.dart';
import 'package:major_project/services/utils/marker_bitmapper.dart';
import 'package:major_project/views/components/navigation_controller.dart';
import 'package:major_project/views/pages/chat_page/chat_page.dart';
import 'package:major_project/views/pages/login_page/login_page.dart';
import 'package:major_project/views/pages/map_page/map_page.dart';
import 'package:major_project/views/pages/profilegame_page/components/game_data.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'models/chat_session_model.dart';
import 'models/markerpopup_model.dart';
import 'models/post_model.dart';
import 'models/profile_model.dart';
import 'models/settings_model.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocationService.instance.init();
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/flutter_i18n'),
  );
  GameController.instance.init();
  await Flame.util.fullScreen();
  await Flame.images.load('rowrow_2.png');
  await Flame.images.load('bunny_sheet.png');
  await Flame.images.load('warrior_sheet.png');
  List<String> ghost_images = [
    'ghost_appear.png',
    'ghost_attack.png',
    'ghost_die.png',
    'ghost_idle.png'
  ];
  await Flame.images.loadAll(ghost_images);
  await Flame.images.load('slime_sheet.png');
  List<String> demon_images = [
    'demon_attack1.png',
    'demon_attack2.png',
    'demon_idle.png'
  ];
  await Flame.images.loadAll(demon_images);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await flutterI18nDelegate.load(null);
  CovidDB.instance.init();
  await Flame.util.fullScreen();
  await Flame.images.load('rowrow_2.png');
  await Flame.images.load('glowsword.png');
  //wrap in localdb init
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User>.value(value: FirebaseAuth.instance.userChanges()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    //async load things like bitmap images
    MarkerBitmapper.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);

    final db = FirebaseService();
    return MultiProvider(
      providers: [
        StreamProvider<List<Profile>>.value(
            value: db.streamProfilesInRadius(
                radius: 25,
                currentLocation: LocationService.instance.currentLocation)),
        StreamProvider<List<Post>>.value(
            value: FirebaseService().streamPostsInRadius(
                radius: 25,
                currentLocation: LocationService.instance.currentLocation)),
        ChangeNotifierProvider(create: (_) => Settings()),
        StreamProvider<List<ChatSession>>(
          create: (_) => db.streamChatSessions(_user?.uid),
        ),
      ],
      child: Consumer<Settings>(builder: (context, settings, child) {
        print(settings.getTheme());
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              FlutterI18nDelegate(
                translationLoader: FileTranslationLoader(
                    useCountryCode: false,
                    fallbackFile: 'en',
                    basePath: 'assets/flutter_i18n'),
              ),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en', 'CA'), // english ca
              const Locale('fr', 'CA'), // french ca
              const Locale.fromSubtags(
                  languageCode: 'zh',
                  scriptCode: 'Hans',
                  countryCode: 'CN'), // chinese
              //todo: replace all ui strings with AppLocalizations.of(context).stringName
            ],
            title: 'Mapcha',
            theme: settings.getTheme(),
            home: SplashScreen.navigate(
              name: 'assets/images/intro.flr',
              loopAnimation: 'assets/images/intro.flr',
              next: (_) => NavigationController(),
              until: () => Future.delayed(Duration(seconds: 10)),
              startAnimation: '1',
            ),
            routes: <String, WidgetBuilder>{
              //named routes
              '/home': (BuildContext context) => NavigationController(),
              '/login': (BuildContext context) => LoginPage(),
              '/chatPage': (BuildContext context) => ChatPage(),
              '/map': (BuildContext context) => MapPage(),
            });
      }),
    );
  }

  Function duringSplash = () {
    return;
  };
}
