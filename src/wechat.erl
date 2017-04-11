-module(wechat).

-export([get_access_token/2]).


-include("include/wechat.hrl").

%{"access_token":"ACCESS_TOKEN","expires_in":7200}
get_access_token(AppId, AppSecret) ->
    URL = list_to_binary(?WECHAT_API_URI ++ "/cgi-bin/token?grant_type=client_credential&appid="++AppId++"&secret="++AppSecret),
    wechat_util:http_get(URL).


