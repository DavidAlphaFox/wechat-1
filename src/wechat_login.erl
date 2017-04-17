%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2017 9:12
%%%-------------------------------------------------------------------
-module(wechat_login).
-author("jiarj").
-include("include/wechat.hrl").

%% API
-export([get_access_token/1,get_userinfo/2,refresh_token/1]).


get_access_token(Code) ->
  {ok,Appid} = application:get_env(wechat,appid),
  {ok,Secret} = application:get_env(wechat,secret),
  %Access_token_Rui = "https://api.weixin.qq.com/sns/oauth2/access_token?appid="++Appid++"&secret="++Secret++"&code="++binary_to_list(Code)++"&grant_type=authorization_code",
  Access_token_Rui = ?API_URL_ACCESS_TOKEN++"?appid="++Appid++"&secret="++Secret++"&code="++binary_to_list(Code)++"&grant_type=authorization_code",
  Response=wechat_util:http_get(Access_token_Rui),
  Response.

refresh_token(REFRESH_TOKEN) ->
  {ok,Appid} = application:get_env(wechat,appid),
  %Access_token_Rui = "https://api.weixin.qq.com/sns/oauth2/access_token?appid="++Appid++"&secret="++Secret++"&code="++binary_to_list(Code)++"&grant_type=authorization_code",
  REFRESH_TOKEN_Rui = ?API_URL_REFRESH_TOKEN++"?appid="++Appid++"&grant_type=refresh_token&refresh_token="++REFRESH_TOKEN,
  Response=wechat_util:http_get(REFRESH_TOKEN_Rui),
  Response.


get_userinfo(ACCESS_TOKEN,OPENID) ->
  %Userinfo_Url = "https://api.weixin.qq.com/sns/userinfo?access_token="++binary_to_list(ACCESS_TOKEN)++"&openid="++binary_to_list(OPENID),
  Userinfo_Url =?API_URL_USERINFO++"?access_token="++binary_to_list(ACCESS_TOKEN)++"&openid="++binary_to_list(OPENID)++"&lang=zh_CN",
  Userinfo=wechat_util:http_get(Userinfo_Url),
  Userinfo.