%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2017 10:03
%%%-------------------------------------------------------------------
-module(test_handler).
-author("jiarj").

-export([init/3, handle/2, terminate/3]).

init(_, Req, Opts) ->
  {ok, Req, Opts}.


handle(Req, State) ->
  {Code, _} = cowboy_req:qs_val(<<"code">>, Req),
  io:format("Code:~p~n",[Code]),
  {CookieVal, _} = cowboy_req:cookie(<<"jwt">>, Req),
  io:format("CookieVal:~p~n",[CookieVal]),
  %Req2 = cowboy_req:set_resp_cookie(<<"inaccount">>, <<"1">>, [], Req),
  {ok, Req3} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"text/plain">>},
    {<<"location">>,<<"/login/wechat">>}
  ], <<"cookies">>, Req),
  {ok, Req3, State}.

terminate(_Reason, Req, State) ->
  ok.

