import 'dart:convert';

import 'package:cookiej/cookiej/action/access_state.dart';
import 'package:cookiej/cookiej/action/app_state.dart';
import 'package:cookiej/cookiej/action/theme_state.dart';
import 'package:cookiej/cookiej/config/config.dart';
import 'package:cookiej/cookiej/config/style.dart';
import 'package:cookiej/cookiej/db/sql_manager.dart';
import 'package:cookiej/cookiej/net/api.dart';
import 'package:flutter/services.dart';
import 'package:cookiej/cookiej/page/main_page.dart';

import 'package:cookiej/cookiej/provider/picture_provider.dart';

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

  String loadInfo='';
  bool isLoad=false;
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    Store<AppState> store = StoreProvider.of(context);
    if(isLoad) return;
    //加载主题
    String themeName=await LocalStorage.get(Config.themeNameStorageKey);
    bool isDarkMode=await LocalStorage.get(Config.isDarkModeStorageKey)=='true';
    if(themeName!=null){
      store.dispatch(RefreshThemeState(ThemeState(themeName,CookieJColors.getThemeData(themeName,isDarkMode: isDarkMode))));
    }
    //初始化
    await loadAssetData();
    API.init();
    SqlManager.init()
      .then((_)=>Hive.initFlutter())
      .then((_)=>UrlProvider.init())
      .then((_)=>PictureProvider.init())
      .then((_)=>Hive.openBox(HiveBoxNames.cookie))
      .then((_)=>WeiboProvider.init())
      .then((_)=>store.dispatch(InitAccessState()))
      .then((_)=>print('初始化完成'))
      .then((_){
        Future.delayed(Duration(milliseconds: 500),(){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainPage()));
        });
      })
      .catchError((e)=>print(e));
    isLoad=true;
  }
  Future<void> loadAssetData() async {
    try{
      var appkeyMap= json.decode(await rootBundle.loadString('assets/data/appkey.json'));
      Config.appkey_0=appkeyMap['appkey'].toString();
      Config.appSecret_0=appkeyMap['appSecret'].toString();
      Config.redirectUri_0=appkeyMap['redirectUri'].toString();
      if(Config.appkey_0==null||Config.appkey_0.isEmpty){
        throw Exception();
      }
    }catch(e){
       setState(() {
         loadInfo='加载appkey失败\n启动前必须正确在项目asset/data/appkey.json文件中添加appkey';
       });
       throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        color:Theme.of(context).dialogBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Container(
                width: 72,
                height: 72,
                decoration:BoxDecoration(
                  image: DecorationImage(image: ExtendedAssetImageProvider('assets/images/icon.png')),
                  shape: BoxShape.circle
                )
              ),
              Container(
                height: 12,
              ),
              Text('饼干微博',style:Theme.of(context).primaryTextTheme.bodyText2.merge(TextStyle(fontSize: 18))),
              Container(
                height:MediaQuery.of(context).size.height/4
              ),
              Text(loadInfo,style: Theme.of(context).textTheme.subtitle2,)
            ]
          ),
        ),
      )
    );
  }
}