import 'package:cookiej/cookiej/action/access_state.dart';
import 'package:cookiej/cookiej/action/app_state.dart';
import 'package:cookiej/cookiej/action/theme_state.dart';
import 'package:cookiej/cookiej/action/user_state.dart';
import 'package:cookiej/cookiej/config/config.dart';
import 'package:cookiej/cookiej/config/style.dart';
import 'package:cookiej/cookiej/db/sql_manager.dart';
import 'package:cookiej/cookiej/page/main_page.dart';
import 'package:cookiej/cookiej/provider/access_provider.dart';
import 'package:cookiej/cookiej/provider/picture_provider.dart';
import 'package:cookiej/cookiej/provider/user_provider.dart';
import 'package:cookiej/cookiej/provider/url_provider.dart';
import 'package:cookiej/cookiej/provider/weibo_provider.dart';
import 'package:cookiej/cookiej/utils/local_storage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

import 'package:redux/redux.dart';

class BootPage extends StatefulWidget {
  static final String routePath = "/";
  @override
  _BootPageState createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    Store<AppState> store = StoreProvider.of(context);
    Future.delayed(Duration(seconds: 1),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainPage()));
    });
    //加载主题
    String themeName=await LocalStorage.get(Config.themeNameStorageKey);
    bool isDarkMode=await LocalStorage.get(Config.isDarkModeStorageKey)=='true';
    if(themeName!=null){
      store.dispatch(RefreshThemeState(ThemeState(themeName,CookieJColors.getThemeData(themeName,isDarkMode: isDarkMode))));
    }
    // //初始化数据库
    // await SqlManager.init();
    // await Hive.initFlutter();
    // await UrlProvider.init();
    // await PictureProvider.init();
    // await WeiboProvider.init();
    // //await Hive.openBox('cookiej_hive_database');
    // //加载本地用户信息
    // store.dispatch(InitAccessState());

    //链式初始化
    SqlManager.init()
      .then((_)=>Hive.initFlutter())
      .then((_)=>UrlProvider.init())
      .then((_)=>PictureProvider.init())
      .then((_)=>WeiboProvider.init())
      .then((_)=>store.dispatch(InitAccessState()))
      .catchError((e)=>print(e));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        color:Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Container(
                width: 72,
                height: 72,
                decoration:BoxDecoration(
                  image: DecorationImage(image: ExtendedAssetImageProvider('res/images/icon.png')),
                  shape: BoxShape.circle
                )
              ),
              Container(
                height: 12,
              ),
              Text('饼干微博',style:Theme.of(context).primaryTextTheme.body2.merge(TextStyle(fontSize: 18))),
              Container(
                height:MediaQuery.of(context).size.height/4
              )
            ]
          ),
        ),
      )
    );
  }
}