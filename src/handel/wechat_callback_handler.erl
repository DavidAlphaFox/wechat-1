-module(wechat_callback_handler).

-export([init/3, handle/2, terminate/3]).
-include("../include/wechat.hrl").

init(_, Req, Opts) ->
  {Reply, Req2} = xfutils:only_allow(get, Req),
  {Reply, Req2, no_state}.


handle(Req, State) ->
  {Code, _Req} = cowboy_req:qs_val(<<"code">>, Req),
  io:format("Code:~p~n",[Code]),
  {States, _Req} = cowboy_req:qs_val(<<"state">>, Req),
  io:format("States:~p~n",[States]),
  {ok,Appid} = application:get_env(wechat,appid),
  {ok,Secret} = application:get_env(wechat,secret),
  %Access_token_Rui = "https://api.weixin.qq.com/sns/oauth2/access_token?appid="++Appid++"&secret="++Secret++"&code="++binary_to_list(Code)++"&grant_type=authorization_code",
  Access_token_Rui = "http://localhost:8081/sns/oauth2/access_token?appid="++Appid++"&secret="++Secret++"&code="++binary_to_list(Code)++"&grant_type=authorization_code",
  Response=wechat_util:http_get(Access_token_Rui),
  io:format("Result:~p~n",[Response]),
  case check_access_token(Response) of
      false->{error, Req, State};
      {true,ACCESS_TOKEN,OPENID} ->
        {ACCESS_TOKEN,OPENID},
        %Userinfo_Url = "https://api.weixin.qq.com/sns/userinfo?access_token="++binary_to_list(ACCESS_TOKEN)++"&openid="++binary_to_list(OPENID),
        Userinfo_Url = "http://localhost:8081/sns/userinfo?access_token="++binary_to_list(ACCESS_TOKEN)++"&openid="++binary_to_list(OPENID),
        Userinfo=wechat_util:http_get(Userinfo_Url),
        case check_userinfo(Userinfo) of
            false->{error, Req, State};
            {true,Userinfo}->
              {ok, Req2} = cowboy_req:reply(200, [
                {<<"content-type">>, <<"text/plain">>}
              ], jsx:encode(Userinfo), Req),
              {ok, Req2, State}
        end
  end.


terminate(_Reason, Req, State) ->
    ok.

check_access_token([{<<"errcode">>,_},
  {<<"errmsg">>,_}])->
  false;
%%[{<<"access_token">>,<<"ACCESS_TOKEN">>},{<<"expires_in">>,7200},{<<"refresh_token">>,<<"REFRESH_TOKEN">>},{<<"openid">>,<<"OPENID">>},{<<"scope">>,<<"SCOPE">>},{<<"unionid">>,<<"UNIONID">>}]
check_access_token([{<<"access_token">>,ACCESS_TOKEN},
  {<<"expires_in">>,Expires_in},
  {<<"refresh_token">>,REFRESH_TOKEN},
  {<<"openid">>,OPENID},
  {<<"scope">>,SCOPE},
  {<<"unionid">>,UNIONID}])->
  {true,ACCESS_TOKEN,OPENID}.

check_userinfo([{<<"errcode">>,_},
  {<<"errmsg">>,_}])->
  false;
%%[{<<"openid">>,<<"OPENID">>},{<<"nickname">>,<<"Nickname">>},{<<"sex">>,Sex},{<<"province">>,<<"Province">>},{<<"city">>,<<"City">>},
%% {<<"country">>,<<"Country">>},{<<"headimgurl">>,<<"Headimgurl">>},{<<"privilege">>,Privilege},{<<"unionid">>,<<"SCOPE">>}]
check_userinfo([{<<"openid">>,OPENID},
  {<<"nickname">>,Nickname},
  {<<"sex">>,Sex},
  {<<"province">>,Province},
  {<<"city">>,City},
  {<<"country">>,Country},
  {<<"headimgurl">>,Headimgurl},
  {<<"privilege">>,Privilege},
  {<<"unionid">>,SCOPE}])->
  {true,[{<<"openid">>,OPENID},
    {<<"nickname">>,Nickname},
    {<<"sex">>,Sex},
    {<<"province">>,Province},
    {<<"city">>,City},
    {<<"country">>,Country},
    {<<"headimgurl">>,Headimgurl},
    {<<"privilege">>,Privilege},
    {<<"unionid">>,SCOPE}]}.