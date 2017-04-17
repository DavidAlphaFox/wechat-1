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
  case Code of
    undefined ->
      {ok, Req2} = cowboy_req:reply(302, [
        {<<"content-type">>, <<"text/plain">>},
        {<<"location">>,<<"localhost:8080/wechat/login">>}
      ], "", Req),
      {ok, Req2, State};
    _->
      Response=wechat_login:get_access_token(Code),
      io:format("Result:~p~n",[Response]),
      case check_access_token(Response) of
        false->{error, Req, State};
        {true,[{<<"access_token">>,ACCESS_TOKEN},
          {<<"expires_in">>,Expires_in},
          {<<"refresh_token">>,REFRESH_TOKEN},
          {<<"openid">>,OPENID},
          {<<"scope">>,SCOPE}]} ->
          %%保存用户信息到数据库
          user_mnesia:add_user(OPENID , ACCESS_TOKEN , REFRESH_TOKEN , Expires_in),


          Userinfo=wechat_login:get_userinfo(ACCESS_TOKEN,OPENID),
          case check_userinfo(Userinfo) of
            false->{error, Req, State};
            {true,[{<<"openid">>,OPENID},
              {<<"nickname">>,Nickname},
              {<<"sex">>,Sex},
              {<<"province">>,Province},
              {<<"city">>,City},
              {<<"country">>,Country},
              {<<"headimgurl">>,Headimgurl},
              {<<"privilege">>,Privilege}]}->
              [{user_info,OPENID,ACCESS_TOKEN,REFRESH_TOKEN,_Expires_in,ROLE,_Info}]=user_mnesia:find_user_by_openid(OPENID),
              %%数据库里取角色
              Payload = [{<<"openid">>,OPENID},{<<"role">>,ROLE}],
              JWT = ejwt:encode(Payload, <<"secret">>),
              Req2 = cowboy_req:set_resp_cookie(<<"jwt">>, JWT, [], Req),
              {ok, Req3} = cowboy_req:reply(200, [
                {<<"content-type">>, <<"text/plain">>}
              ], jsx:encode(Userinfo), Req2),
              {ok, Req3, State}
          end
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
  {<<"scope">>,SCOPE}])->
  {true,[{<<"access_token">>,ACCESS_TOKEN},
    {<<"expires_in">>,Expires_in},
    {<<"refresh_token">>,REFRESH_TOKEN},
    {<<"openid">>,OPENID},
    {<<"scope">>,SCOPE}]}.

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
  {<<"privilege">>,Privilege}])->
  {true,[{<<"openid">>,OPENID},
    {<<"nickname">>,Nickname},
    {<<"sex">>,Sex},
    {<<"province">>,Province},
    {<<"city">>,City},
    {<<"country">>,Country},
    {<<"headimgurl">>,Headimgurl},
    {<<"privilege">>,Privilege}]}.