%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 四月 2017 11:18
%%%-------------------------------------------------------------------
-module(user_mnesia).
-author("jiarj").
-include("include/user_store.hrl").
-include_lib("stdlib/include/qlc.hrl").

%% API
-export([install/0, add/0, find/0, find2/0, add_user/4, find_user_by_openid/1, find_by_role/0]).

install() ->
  mnesia:delete_schema([node()]),
  mnesia:create_schema([node()]),
  application:start(mnesia),
  mnesia:create_table(user_info, [{attributes,record_info(fields,user_info)}, {disc_copies,[node()]}]),
  application:stop(mnesia).

add_user(Openid,Access_token,Refresh_token,Expires_in)->
  add_user(Openid,Access_token,Refresh_token,Expires_in,[],[])
.
add_user(Openid,Access_token,Refresh_token,Expires_in,[],[])->
  F=fun()->
    mnesia:write(#user_info{openid = Openid,access_token = Access_token,refresh_token = Refresh_token,expires_in = Expires_in})
    end,
  mnesia:activity(transaction,F);
add_user(Openid,Access_token,Refresh_token,Expires_in,Role,Info)->
  F=fun()->
    mnesia:write(#user_info{openid = Openid,access_token = Access_token,refresh_token = Refresh_token,expires_in = Expires_in,role = Role,info=Info})
    end,
  mnesia:activity(transaction,F).

find_user_by_openid(Openid)->
  F=fun()->
    mnesia:read({user_info, Openid})
    end,
  mnesia:activity(transaction,F).


add()->
  F=fun()->
    mnesia:write(#user_info{openid = <<"1">>,access_token = <<"9527">>,refresh_token = <<"refresh_tiken">>,expires_in = <<"999">>,role = <<"admin">>})
    end,
  mnesia:activity(transaction,F).
find()->

  do(qlc:q([ X || X <- mnesia:table(user_info)])).

find2()->
  F=fun()->
    case mnesia:read({user_info, <<"1">>}) of
      [User = #user_info{}]->
        User;
    []->
      underfind
    end
    end,
  mnesia:activity(transaction,F).

find_by_role()->
  do(qlc:q([User|| User =#user_info{role = Role} <- mnesia:table(user_info),Role =:= <<"empty">> ])).



do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.

