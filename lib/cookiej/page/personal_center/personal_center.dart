import 'dart:async';

import 'package:cookiej/cookiej/action/access_state.dart';
import 'package:cookiej/cookiej/action/app_state.dart';
import 'package:cookiej/cookiej/action/theme_state.dart';
import 'package:cookiej/cookiej/config/config.dart';
import 'package:cookiej/cookiej/config/style.dart';
import 'package:cookiej/cookiej/page/login/login_page.dart';
import 'package:cookiej/cookiej/page/personal_center/switch_theme.dart/theme_style.dart';
import 'package:cookiej/cookiej/provider/picture_provider.dart';
import 'package:cookiej/cookiej/provider/user_provider.dart';
import 'package:cookiej/cookiej/utils/local_storage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class PersonalCenter extends StatelessWidget {

  final GlobalKey _displayUserNameKey=GlobalKey();
  @override
  Widget build(BuildContext context){
    final store=StoreProvider.of<AppState>(context);
    final _theme=store.state.themeState.themeData;
    var _isDarkMode=_theme.brightness==Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          //设置按钮
          IconButton(
            iconSize: 24,
            icon: Icon(IconData(0xf1de)),
            onPressed: (){},
          ),
        ],
        bottom: PreferredSize(
          child: Expanded(
            flex: 3,
            child: Column(
              children:[
                Container(
                  child:Row(
                    children: <Widget>[
                      SizedBox(
                        //头像
                        child: ExtendedImage(
                          image:PictureProvider.getPictureFromId(store.state.currentUser.iconId),
                          shape: BoxShape.circle,
                        ),
                        width: 64,height: 64,
                      ),
                      Expanded(
                        child:ListTile(
                          title:Row(
                            children:[
                              Text(store.state.currentUser.screenName,style: _theme.primaryTextTheme.subhead),
                              InkWell(
                                child: Icon(IconData(0xf0d7,fontFamily:CookieJTextStyle.iconFontFamily),color:_theme.primaryTextTheme.subhead.color ,size: 24),
                                onTap: ()async{
                                  final RenderBox textDescription=_displayUserNameKey.currentContext.findRenderObject();
                                  showMenu(
                                    context: _displayUserNameKey.currentContext,
                                    position:RelativeRect.fromLTRB(textDescription.localToGlobal(Offset.zero).dx, textDescription.localToGlobal(Offset.zero).dy,100, 0), 
                                    items: await getLocalUsersItems(store,context),
                                  );
                                },
                              )
                            ]
                          ),
                          subtitle: Text(store.state.currentUser.description.isEmpty?'\u{3000}':store.state.currentUser.description,key: _displayUserNameKey,style: _theme.primaryTextTheme.subtitle),
                          trailing: IconButton(icon: Icon(IconData(0xf105,fontFamily:CookieJTextStyle.iconFontFamily),color:_theme.primaryTextTheme.subhead.color,size: 28,), onPressed: (){

                          }),
                        ),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left:14,bottom: 10),
                ),
                Container(
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      FlatButton(onPressed: (){}, child: Column(
                        children:[
                          Text(store.state.currentUser.statusesCount.toString(),style: _theme.primaryTextTheme.subhead),
                          Text('微博',style: _theme.primaryTextTheme.subtitle)
                        ]
                      )),
                      FlatButton(onPressed: (){}, child: Column(
                        children:[
                          Text(store.state.currentUser.friendsCount.toString(),style: _theme.primaryTextTheme.subhead),
                          Text('关注',style: _theme.primaryTextTheme.subtitle)
                        ]
                      )),
                      FlatButton(onPressed: (){}, child: Column(
                        children:[
                          Text(store.state.currentUser.followersCount.toString(),style: _theme.primaryTextTheme.subhead),
                          Text('粉丝',style: _theme.primaryTextTheme.subtitle)
                        ]
                      )),
                    ]
                  )
                )
              ]
            ),
          ), 
          preferredSize: Size.fromHeight(128),
        ),
      ),
      //菜单
      body: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(top:24,bottom: 0),
        child: ListView(
          children:[
            ListTile(
              leading: Icon(Icons.wb_sunny),
              title: Text('夜间模式'),
              trailing: CupertinoSwitch(
                value: _isDarkMode,
                activeColor: store.state.themeState.themeData.primaryColor,
                onChanged: (value){
                  store.dispatch(SwitchDarkMode(value));
                  //存储夜间模式配置
                  LocalStorage.save(Config.isDarkModeStorageKey, value.toString());
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.palette,color:CookieJColors.themeColors[store.state.themeState.themeName]),
              title: Text('切换主题'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ThemeStyle()));
              },
            ),
            Divider()
          ]
        ),
      )
    );
  }

  Future<List<PopupMenuEntry>> getLocalUsersItems(Store<AppState> store,BuildContext context) async{
    var state=store.state;
    var itemList=<PopupMenuEntry>[];
    var userList=await UserProvider.getLocalAccessUsers(state.accessState);
    if(userList.success){
      userList.data.forEach((user){
        GlobalKey _itemKey=GlobalKey();
        itemList.add(PopupMenuItem(
          key: _itemKey,
          child:ListTile(
            leading:ExtendedImage(
              image:PictureProvider.getPictureFromId(user.iconId,sinaImgSize: SinaImgSize.thumbnail),
              shape:BoxShape.circle,
              width:36,
              height: 36,
            ),
            //leading: CircleAvatar(backgroundImage:PictureProvider.getPictureFromId(user.iconId,sinaImgSize: SinaImgSize.thumbnail)),
            title: Text(user.screenName),
            trailing: IconButton(padding: EdgeInsets.all(0), icon: Icon(Icons.remove_circle,color: Colors.red,), onPressed: (){
              Navigator.pop(context);
              store.dispatch(RemoveAccess(state.accessState.loginAccesses[user.idstr]));
            }),
            contentPadding: EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
            onTap: (){
              Navigator.pop(context);
              if(user.idstr!=store.state.accessState.currentAccess.uid){
                store.dispatch(UpdateCurrentAccess(store.state.accessState.loginAccesses[user.idstr]));
              }
            },
            selected: user.idstr==state.currentUser.idstr,
          ),
        ));
        itemList.add(PopupMenuDivider(height: 1,));
      });
    }
    itemList.add(PopupMenuItem(
      child: Row(
        children:[
          IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.add_circle,color: Colors.green), 
            onPressed: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
            }
          )
        ],
        mainAxisAlignment:MainAxisAlignment.center
      ),
    ));

    return itemList;
  }


}