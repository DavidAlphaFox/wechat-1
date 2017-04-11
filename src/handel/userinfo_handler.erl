-module(userinfo_handler).

-export([init/3, handle/2, terminate/3]).

init(_, Req, Opts) ->
	{ok, Req, Opts}.


handle(Req, State) ->
	{Access_token, _Req} = cowboy_req:qs_val(<<"access_token">>, Req),
	io:format("Appid:~p~n",[Access_token]),
	{Openid, _Req} = cowboy_req:qs_val(<<"openid">>, Req),
	io:format("Secret:~p~n",[Openid]),


	Body=[{<<"openid">>,<<"OPENID123">>},{<<"nickname">>,<<"Nickname456">>},{<<"sex">>,23},{<<"province">>,<<"Province789">>},{<<"city">>,<<"City123">>},
 {<<"country">>,<<"Country456">>},{<<"headimgurl">>,<<"Headimgurl789">>},{<<"privilege">>,[<<"PRIVILEGE1">>, <<"PRIVILEGE2">>]},{<<"unionid">>,<<"unionid1321">>}],


	{ok, Req2} = cowboy_req:reply(200, [
			{<<"content-type">>, <<"text/plain">>}
	], jsx:encode(Body), Req),
	{ok, Req2, State}.

terminate(_Reason, Req, State) ->
    ok.
