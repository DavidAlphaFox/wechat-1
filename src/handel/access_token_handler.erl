-module(access_token_handler).

-export([init/3, handle/2, terminate/3]).

init(_, Req, Opts) ->
	{ok, Req, Opts}.


handle(Req, State) ->
	{Appid, _Req} = cowboy_req:qs_val(<<"appid">>, Req),
	io:format("Appid:~p~n",[Appid]),
	{Secret, _Req} = cowboy_req:qs_val(<<"secret">>, Req),
	io:format("Secret:~p~n",[Secret]),
	{Code, _Req} = cowboy_req:qs_val(<<"code">>, Req),
	io:format("Code:~p~n",[Code]),
	{Grant_type, _Req} = cowboy_req:qs_val(<<"grant_type">>, Req),
	io:format("Grant_type:~p~n",[Grant_type]),

	Body=[{<<"access_token">>,<<"ACCESS_TOKEN123">>},{<<"expires_in">>,7200},{<<"refresh_token">>,<<"REFRESH_TOKEN123">>},{<<"openid">>,<<"OPENID123">>},{<<"scope">>,<<"SCOPE1321">>},{<<"unionid">>,<<"Unionid123">>}],


	{ok, Req2} = cowboy_req:reply(200, [
			{<<"content-type">>, <<"text/plain">>}
	], jsx:encode(Body), Req),
	{ok, Req2, State}.

terminate(_Reason, Req, State) ->
    ok.
