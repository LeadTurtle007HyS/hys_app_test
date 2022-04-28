import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppData {

  AppData._();
  static const String appName = 'FlexColor\u{00AD}Scheme';
  static const String version = '4.1.1';
  static const String packageVersion = 'FlexColorScheme package $version';
  static const String packageUrl = 'https://pub.dev/packages/flex_color_scheme';
  static const String flutterVersion = 'stable v2.5.3';
  static const String copyright = '© 2020, 2021';
  static const String author = 'Mike Rydstrom';
  static const String license = 'BSD 3-Clause License';
  static const String icon = 'assets/images/app_icon.png';

  static const String podcastFileNode="podcast_bg_files";

  static const String podcastAlbumNode="podcast_album_table";
  static const String podcastAlbumEpisodes="podcast_album_episode_table";

  static const double maxBodyWidth = 1000;

  static const double desktopBreakpoint = 1150;

  static const double phoneBreakpoint = 600;

  static const double edgeInsetsPhone = 8;
  static const double edgeInsetsTablet = 14;
  static const double edgeInsetsDesktop = 18;

  static const double edgeInsetsBigDesktop = 24;

  static const double popupMenuOpacity = 0.95;

  static double responsiveInsets(double width) {
    if (width < phoneBreakpoint) return edgeInsetsPhone;
    if (width < desktopBreakpoint) return edgeInsetsTablet;
    return edgeInsetsDesktop;
  }


  static String title(BuildContext context) =>
      (context as Element).findAncestorWidgetOfExactType<MaterialApp>().title;

  static String get font => GoogleFonts.rubik().fontFamily;

  static VisualDensity get visualDensity =>
      FlexColorScheme.comfortablePlatformDensity;


  static const TextTheme textTheme = TextTheme(
    headline1: TextStyle(
      fontSize: 57, // Same as M3, defaults to 96 in Material2018 Typography.
    ),
    headline2: TextStyle(
      fontSize: 45, // Same as M3, defaults to 60 in Material2018 Typography.
    ),
    headline3: TextStyle(
      fontSize: 36, // Same as M3, defaults to 48 in Material2018 Typography.
    ),
    headline4: TextStyle(
      fontSize: 28, // Same as M3, defaults to 34 in Material2018 Typography.
    ),
    // I chose this, I later saw it happened to match new M3 style too - cool!
    overline: TextStyle(
      fontSize: 11, // Defaults to 10 in Material2018 Typography.
      letterSpacing: 0.5, // Defaults to 1.5 in Material2018 Typography.
    ),
  );
}
