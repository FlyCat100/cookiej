import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:cookiej/cookiej/config/config.dart';
import 'package:cookiej/cookiej/net/api.dart';
import 'package:cookiej/cookiej/utils/utils.dart';

class AccessApi{
  static final baseUrl=API.baseUrl;
  
  ///获取用户登陆页面地址
  static String getOauth2Authorize(){
    var url='$baseUrl/oauth2/authorize';
    var params={
      "client_id":Config.appkey,
      "redirect_uri":Config.redirectUri
    };
    url=Utils.formatUrlParams(url, params);
    return url;
  }

  ///获取accessToken
  static Future<String> getOauth2Access(String code) async{
    var url='/oauth2/access_token';
    var params={
      "client_id":Config.appkey,
      "client_secret":Config.appSecret,
      "grant_type":"authorization_code",
      "redirect_uri":Config.redirectUri,
      "code":code,
    };
    var httpCli=new HttpClient();
    var uri=new Uri.https('api.weibo.com',url,params);
    var request=await httpCli.postUrl(uri);
    var httpResponse=await request.close();
    var responseBody = await httpResponse.transform(utf8.decoder).join();
    return responseBody;
  }
}