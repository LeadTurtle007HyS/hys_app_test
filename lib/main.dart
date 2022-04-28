import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hys/SocialPart/Podcast/services/locator_service.dart';
import 'package:hys/SocialPart/business/CreateBusiness.dart';
import 'package:hys/models/user.dart';
import 'package:hys/providers/navproviders.dart';
import 'package:hys/services/auth.dart';
import 'package:hys/services/fcm_service.dart';
import 'package:hys/splashscreen.dart';
import 'package:hys/navBar.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hys/authanticate/authanticate.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'SocialPart/Podcast/controllers/audio_player_controller.dart';
import 'SocialPart/Podcast/controllers/path_controller.dart';
import 'SocialPart/Podcast/controllers/record_controller.dart';
import 'SocialPart/Podcast/controllers/settings_controller.dart';
import 'SocialPart/Podcast/controllers/theme_controller.dart';
import 'SocialPart/Podcast/controllers/timer_controller.dart';
import 'SocialPart/Podcast/controllers/waveform_controller.dart';
import 'SocialPart/Podcast/services/navigation_service.dart';


var routes = <String, WidgetBuilder>{
  "/home": (BuildContext context) => Wrapper(index: 2),
  "/signin": (BuildContext context) => Wrapper(),
  // "/loading": (BuildContext context) => Home(),
};

Map<int, Color> color = {
  50: Color.fromRGBO(88, 165, 196, .8),
  100: Color.fromRGBO(88, 165, 196, .8),
  200: Color.fromRGBO(88, 165, 196, .8),
  300: Color.fromRGBO(88, 165, 196, .8),
  400: Color.fromRGBO(88, 165, 196, .8),
  500: Color.fromRGBO(88, 165, 196, .8),
  600: Color.fromRGBO(88, 165, 196, .8),
  700: Color.fromRGBO(88, 165, 196, .8),
  800: Color.fromRGBO(88, 165, 196, .8),
  900: Color.fromRGBO(88, 165, 196, .8),
};

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  //  await FirebaseMessaging.instance
  //       .setForegroundNotificationPresentationOptions(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
  //   print("message recieved");
  //   print(event.notification.body);
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    
  //   print('Message clicked!');
  //   locator<NavigationService>().navigateTo('/home');
  
  // });


  //  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage message) {
  //   //Its compulsory to check if RemoteMessage instance is null or not.
  //   if (message != null) {
  //     print('getInitialMessage');
  //    locator<NavigationService>().navigateTo('/home');
  //   }
  // });

  

   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  
  
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);

// these are the local storage folders created by using Hive
  await Hive.openBox("usertokendata");
  await Hive.openBox("mypersonaldata");
  await Hive.openBox("userdata");
  await Hive.openBox("allquestions");
  await Hive.openBox("topiclist");
  await Hive.openBox('allsocialposts');
  await Hive.openBox("commentliked");
  await Hive.openBox("commentreplied");
  await Hive.openBox("commentreport");
  await Hive.openBox("subcommentliked");
  await Hive.openBox("subcommentreport");
  await Hive.openBox("socialfeedreactions");
  await Hive.openBox("socialfeedcommentsreactions");
  await Hive.openBox("socialfeedsubcommentsreactions");
  await Hive.openBox("socialfeedpostsaved");
  await Hive.openBox('socialeventcommentsreactions');
  await Hive.openBox('socialeventreactions');
  await Hive.openBox('socialeventsubcommentsreactions');
  await Hive.openBox('sm_events');
  await Hive.openBox('sm_event_likes');
  await Hive.openBox('sm_event_joins');
  await Hive.openBox('sm_event_comments_likes');
  await Hive.openBox('sm_event_comments_replies');
  await Hive.openBox('sm_podcast');
  await Hive.openBox('sm_podcast_likes');
  await Hive.openBox("allnotifications");

  final ThemeController themeController = ThemeController();
  await themeController.init();

  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NavBarIndex(),
        ),
        ChangeNotifierProvider(
          create: (_) => themeController,
        ),
        ChangeNotifierProvider(
          create: (_) => RecordController(),
        ),
        ChangeNotifierProvider(
          create: (_) => TimerController(),
        ),
        ChangeNotifierProvider(
          create: (_) => PathController(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioPlayerController(""),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsController(),
        ),
        ChangeNotifierProvider(
          create: (_) => WaveformController(),
        ),
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
    super.initState();
     setupFcm();
  
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().authStateChanges,
      initialData: User(),
      child: Portal(
        child: MaterialApp(
            navigatorKey: locator<NavigationService>().navigatorKey,
            onGenerateRoute: (routeSettings) {
              switch (routeSettings.name) {
                case '/home':
                  return MaterialPageRoute(builder: (context) => Wrapper());
                default:
                  return MaterialPageRoute(builder: (context) => Wrapper());
              }
            },
            title: 'HyS',
            theme: ThemeData(
              primarySwatch: MaterialColor(0xff58a5c4, color),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            debugShowCheckedModeBanner: false,
            home: Splash(
              index: index,
            ),
            routes: routes),
      ),
    );
  }
}

// wrapper is used to check that once app opened by user then user is already
//login or not if yes then user will stay login elser it jumps to login page
class Wrapper extends StatelessWidget {
  final int index;

  const Wrapper({Key key, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return Authanticate();
    } else {
      return BottomNavigationBarWidget(index:index);
    }
  }
}

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message");
// }
