%%%-------------------------------------------------------------------
%% @doc wechat public API
%% @end
%%%-------------------------------------------------------------------

-module(wechat_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    application:start(cowboy),
    application:start(jsx),
    application:start(erlydtl),
    application:start(xfutils),
    Dispatch = cowboy_router:compile([
		{'_', [
			{"/login", cowboy_static,{priv_file, wechat, "site/index.html"}},
			%{"/login/wechat", cowboy_static,{priv_file, wechat, "site/login.html"}}
      {"/login/wechat", wechat_login_handler, []},
      {"/wechat/callback", wechat_callback_handler, []},
      {"/sns/oauth2/access_token", access_token_handler, []},
      {"/sns/userinfo", userinfo_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8081}], [
		{env, [{dispatch, Dispatch}]}
	]),
    wechat_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
