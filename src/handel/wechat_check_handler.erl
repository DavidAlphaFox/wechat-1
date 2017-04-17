-module(wechat_check_handler).

-export([init/3, handle/2, terminate/3]).
-include("../include/wechat.hrl").

init(_, Req, _Opts) ->
  {Reply, Req2} = xfutils:only_allow(get, Req),
  {Reply, Req2, no_state}.


handle(Req, State) ->
  {Signature, _Req} = cowboy_req:qs_val(<<"signature">>, Req),
  io:format("Signature:~p~n",[Signature]),
  {Timestamp, _Req} = cowboy_req:qs_val(<<"timestamp">>, Req),
  io:format("Timestamp:~p~n",[Timestamp]),
  {Nonce, _Req} = cowboy_req:qs_val(<<"nonce">>, Req),
  io:format("Nonce:~p~n",[Nonce]),
  {Echostr, _Req} = cowboy_req:qs_val(<<"echostr">>, Req),
  io:format("Echostr:~p~n",[Echostr]),
  %L=lists:sort([Token,binary_to_list(Timestamp),binary_to_list(Nonce)]),
  %Signature_cal=crypto:hash(sha,lists:concat(L)),
  %binary_to_list(Signature_cal),
  %io:format("Signature_cal:~p~n",[Signature_cal]),
  %case Signature =:= Signature_cal of
  %false ->{err,"Signature no match"};
  Result = wechat_signature:check(binary_to_list(Signature), binary_to_list(Timestamp), binary_to_list(Nonce)),
  io:format("result:~p~n",[Result]),
  if
    Result == false ->
      {error, "Signature no match"};
    true ->
      Req2 = cowboy_req:reply(200, [
        {<<"content-type">>, <<"text/plain">>}
      ], Echostr, Req),
      {ok, Req2, State}
  end.
terminate(_Reason, Req, State) ->
    ok.
