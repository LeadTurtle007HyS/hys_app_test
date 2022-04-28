import 'package:flutter/cupertino.dart';
import 'package:progress_dialog/progress_dialog.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =  new GlobalKey<NavigatorState>();

   

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

 Future showProgressDialog() {
    final ProgressDialog pr = ProgressDialog(navigatorKey.currentContext);
  return pr.show();
  }

   Future hideProgressDialog() {
    final ProgressDialog pr = ProgressDialog(navigatorKey.currentContext);
  return  pr.hide();
  }

}