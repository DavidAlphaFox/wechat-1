%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2017 11:20
%%%-------------------------------------------------------------------
-author("jiarj").
-record(user_info,{openid,access_token,refresh_token,expires_in,role= <<"empty">>,info=[] }).

