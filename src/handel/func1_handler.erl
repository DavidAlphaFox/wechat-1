%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2017 10:03
%%%-------------------------------------------------------------------
-module(func1_handler).
-author("jiarj").

-export([init/3, handle/2, terminate/3]).

init(_, Req, Opts) ->
  {Reply, Req2} = xfutils:only_allow(get, Req),
  {Reply, Req2, Opts}.


handle(Req, State) ->
  {CookieVal, _} = cowboy_req:cookie(<<"jwt">>, Req),
  case CookieVal of
    undefined->
      {ok, Req3} = cowboy_req:reply(302, [
        {<<"content-type">>, <<"text/plain">>},
        {<<"location">>,<<"/login/wechat">>}
      ], "", Req),
      {ok, Req3, State};
    CookieVal ->
      JWT = ejwt:decode(CookieVal,<<"secret">>),
      case JWT of
        error->
            {ok, Req2} = cowboy_req:reply(302, [
              {<<"content-type">>, <<"text/plain">>},
              {<<"location">>,<<"/login/wechat">>}
              ], "", Req),
            {ok, Req2, State};
        [{<<"openid">>,OPENID},{<<"role">>,ROLE}]->
            %Req = cowboy_req:set_resp_cookie(<<"sessionid">>, <<"123456789">>,[], Req),
            {ok, Req2} = cowboy_req:reply(200, [
              {<<"content-type">>, <<"text/plain">>}
            ], <<"func1">>, Req),
            {ok, Req2, State}
      end
  end.

terminate(_Reason, Req, State) ->
  ok.

