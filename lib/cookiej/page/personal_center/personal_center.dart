import 'dart:async';
import 'dart:io';

import 'package:cookiej/cookiej/action/access_state.dart';
import 'package:cookiej/cookiej/action/app_state.dart';
import 'package:cookiej/cookiej/action/theme_state.dart';
import 'package:cookiej/cookiej/config/config.dart';
import 'package:cookiej/cookiej/config/style.dart';
import 'package:cookiej/cookiej/event/event_bus.dart';
import 'package:cookiej/cookiej/event/weibo_listview_refresh_event.dart';
import 'package:cookiej/cookiej/model/weibos.dart';
import 'package:cookiej/cookiej/page/login/login_page.dart';
import 'package:cookiej/cookiej/page/personal_center/switch_theme.dart/theme_style.dart';
import 'package:cookiej/cookiej/page/public/user_list_page.dart';
import 'package:cookiej/cookiej/page/public/user_page.dart';
import 'package:cookiej/cookiej/page/widget/show_image_view.dart';
import 'package:cookiej/cookiej/provider/picture_provider.dart';
import 'package:cookiej/cookiej/provider/user_provider.dart';
import 'package:cookiej/cookiej/provider/weibo_provider.dart';
import 'package:cookiej/cookiej/utils/local_storage.dart';
import 'package:cookiej/cookiej/utils/utils.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:redux/redux.dart';

class PersonalCenter extends StatelessWidget {

  final GlobalKey _displayUserNameKey=GlobalKey();
  @override
  Widget build(BuildContext context){
    return StoreBuilder<AppState>(
      builder:(context,store){
        final _theme=store.state.themeState.themeData;
        var _isDarkMode=_theme.brightness==Brightness.dark;
        var iconUrl=PictureProvider.getImgUrlFromId(store.state.currentUser.iconId);
        var user=store.state.currentUser;
        return Scaffold(
          appBar: AppBar(
            // actions: <Widget>[
            //   //设置按钮
            //   IconButton(
            //     iconSize: 24,
            //     icon: Icon(IconData(0xf069,fontFamily:CookieJTextStyle.iconFontFamily)),
            //     onPressed: (){},
            //   ),
            // ],
            bottom: PreferredSize(
              child: Expanded(
                flex: 4,
                child: Column(
                  children:[
                    Container(
                      child:Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: ()=>Navigator.push(
                              context,
                              Platform.isAndroid
                                  ? TransparentMaterialPageRoute(builder: (_) => ShowImagesView([iconUrl],))
                                  : TransparentMaterialPageRoute(builder: (_) => ShowImagesView([iconUrl],))
                            ),
                            child:Hero(
                              tag: iconUrl,
                                child: SizedBox(
                                child: ClipOval(child: Image(image: PictureProvider.getPictureFromUrl(iconUrl),),),
                                width: 64,height: 64,
                              ),
                            )
                          ),
                          Expanded(
                            child:ListTile(
                              title:Row(
                                children:[
                                  Text(store.state.currentUser.screenName,style: _theme.primaryTextTheme.subtitle1),
                                  InkWell(
                                    child: Icon(const IconData(0xf0d7,fontFamily:CookieJTextStyle.iconFontFamily),color:_theme.primaryTextTheme.subtitle1.color ,size: 24),
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
                              subtitle: Text(store.state.currentUser.description.isEmpty?'\u{3000}':store.state.currentUser.description,key: _displayUserNameKey,style: _theme.primaryTextTheme.subtitle2),
                              trailing: IconButton(icon: Icon(const IconData(0xf105,fontFamily:CookieJTextStyle.iconFontFamily),color:_theme.primaryTextTheme.subtitle1.color,size: 28,), onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserPage(inputUser:store.state.currentUser)));
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
                          FlatButton(onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserPage(inputUser:store.state.currentUser)));
                          }, child: Column(
                            children:[
                              Text(store.state.currentUser.statusesCount.toString(),style: _theme.primaryTextTheme.subtitle1),
                              Text('微博',style: _theme.primaryTextTheme.subtitle2)
                            ]
                          )),
                          FlatButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserListPage(type: FriendShipsType.Friends,screenName:user.screenName)));
                          }, child: Column(
                            children:[
                              Text(store.state.currentUser.friendsCount.toString(),style: _theme.primaryTextTheme.subtitle1),
                              Text('关注',style: _theme.primaryTextTheme.subtitle2)
                            ]
                          )),
                          FlatButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserListPage(type: FriendShipsType.Followers,screenName:user.screenName)));
                          }, child: Column(
                            children:[
                              Text(store.state.currentUser.followersCount.toString(),style: _theme.primaryTextTheme.subtitle1),
                              Text('粉丝',style: _theme.primaryTextTheme.subtitle2)
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
          body: Column(
            children:[
              Container(
                margin: EdgeInsets.only(top:24,bottom: 0),
                child: Material(
                  color:_theme.dialogBackgroundColor,
                  child:GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    children: <Widget>[
                    _buildExpandedItem(Icons.star, Colors.yellow[700], '收藏', _theme),
                    _buildExpandedItem(Icons.supervised_user_circle, Colors.blue[400], '我的好友', _theme),
                    _buildExpandedItem(const IconData(0x23), Colors.orange[700], '关注的话题', _theme),
                    _buildExpandedItem(FontAwesomeIcons.qrcode, Colors.blue[400], '扫一扫', _theme,size: 28),
                    _buildExpandedItem(Icons.history, Colors.teal[300], '浏览历史', _theme),
                    _buildExpandedItem(FontAwesomeIcons.envelopeOpen, Colors.purple, '草稿箱', _theme,size: 23),
                     _buildExpandedItem(Icons.location_on, Colors.red[400], '附近的微博', _theme),
                    _buildExpandedItem(Icons.more_horiz, Colors.blueGrey, '更多', _theme),
                    
                    ],
                  )
                ),
              ),
              Container(
                margin: EdgeInsets.only(top:24,bottom: 0),
                child: Ink(
                  color: _theme.dialogBackgroundColor,
                  child:Column(
                    children:[
                      ListTile(
                        leading: Icon(Icons.wb_sunny),
                        title: Text('黑暗模式'),
                        trailing: CupertinoSwitch(
                          value: _isDarkMode,
                          activeColor: store.state.themeState.themeData.primaryColor,
                          onChanged: (value){
                            store.dispatch(SwitchDarkMode(value));
                            //存储夜间模式配置
                            LocalStorage.save(Config.isDarkModeStorageKey, value.toString());
                          },
                        ),
                        onTap: (){
                          
                        },
                      ),
                      Divider(height: 1,),
                      ListTile(
                        leading: Icon(Icons.palette,color:CookieJColors.themeColors[store.state.themeState.themeName]),
                        title: Text('主题样式'),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ThemeStyle()));
                        },
                      ),
                      Divider(height: 1,),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('更多设置'),
                        onTap: () async {
                          assert((){
                            Hive.lazyBox<Weibos>('weibos_box').get(Utils.generateHiveWeibosKey(WeiboTimelineType.Statuses, store.state.accessState.currentAccess.uid)).then((weibos){
                              var lastWeibo=weibos.statuses[weibos.statuses.length-1];
                              Hive.lazyBox<Weibos>('weibos_box').delete(store.state.accessState.currentAccess.uid);
                              WeiboProvider.putIntoWeibosBox(Utils.generateHiveWeibosKey(WeiboTimelineType.Statuses, store.state.accessState.currentAccess.uid), [lastWeibo]);
                              print(Hive.lazyBox<Weibos>('weibos_box').keys);
                              eventBus.fire(WeiboListViewRefreshEvent());
                            });
                            return true;
                          }());
                        },
                        // trailing: FutureBuilder(
                        //   future: Hive.lazyBox<Weibos>('weibos_box').get(store.state.accessState.currentAccess.uid).then((weibos)=>weibos.statuses.length.toString()),
                        //   builder: (context,snaphot)=>Text('已缓存数量${snaphot.data??'0'}',style: _theme.primaryTextTheme.overline)
                        // )
                      )
                    ]
                  ),
                )
              )
            ]
          )
        );
      }
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
            // leading:ExtendedImage.network(
            //   PictureProvider.getImgUrlFromId(user.iconId,sinaImgSize: SinaImgSize.thumbnail),
            //   shape:BoxShape.circle,
            //   width:36,
            //   height: 36,
            // ),
            leading: CircleAvatar(backgroundImage:PictureProvider.getPictureFromId(user.iconId,sinaImgSize: SinaImgSize.small)),
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
      child: InkWell(
        child:Row(
          children:[
            Icon(Icons.add_circle,color: Colors.green), 
          ],
          mainAxisAlignment:MainAxisAlignment.center
        ),
        onTap: (){
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
        },
      ),
    ));

    return itemList;
  }
  Widget _buildExpandedItem(IconData iconData,Color color,String text, ThemeData theme,{double size}){
    return SizedBox.expand(
      child:InkWell(
        onTap:(){},
        child:SizedBox.expand(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                child:SizedBox(
                  width:42,
                  height:42,
                    child:Icon(
                    iconData,
                    color: color,
                    size: size??30,
                  )
                )
              ),
              Text(text,style:theme.textTheme.subtitle2)
            ],
          )
        )
      )
    );
  }

}