-module(wechat_login_handler).

-export([init/3, handle/2, terminate/3]).

init(_, Req, _Opts) ->
  {Reply, Req2} = xfutils:only_allow(get, Req),
  {Reply, Req2, no_state}.


handle(Req, State) ->
  {ok,Appid} = application:get_env(wechat,appid),
  {ok,Redirect_uri} = application:get_env(wechat,redirect_uri),
  Enc_url=edoc_lib:escape_uri(Redirect_uri),
  <<A:32,_B:32,_C:32>> = crypto:strong_rand_bytes(12),
  Url = ["https://open.weixin.qq.com/connect/qrconnect?","appid=",Appid,"&redirect_uri=",Enc_url,"&response_type=code&scope=snsapi_login&state=",integer_to_list(A),"#wechat_redirect"],
  Url_f =lists:flatten(Url),
  Url_f_b=list_to_binary(Url_f),
		io:format("=================~n"),
		io:format(Url_f),
    {ok, Req2} = cowboy_req:reply(302, [
        {<<"content-type">>, <<"text/plain">>},
        {<<"location">>,Url_f_b}
    ], "", Req),
    {ok, Req2, State}.

terminate(_Reason, Req, State) ->
    ok.
