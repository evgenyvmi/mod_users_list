-module(mod_users_list).

-author("Evgeny Andruschenko").

-behavior(gen_mod).

-include("ejabberd.hrl").
-include("logger.hrl").

-export([start/2, stop/1]).

start(_Host, _Opt) -> 
	List_of_users = get_all_users(),
	?INFO_MSG("registred useres - ~p~n", [List_of_users]),
	send_list(List_of_users),
	ok.
stop(_Host) -> ok.

get_all_users() ->
        Get_User = 
        	fun(Tuple_User, Acc) -> 
        		[element(1, element(2, Tuple_User)) | Acc]
        	end,
        Accumulating_List_of_users = 
        	fun() -> 
        		mnesia:foldl(Get_User, [], passwd)
        	end,
        element(2, mnesia:transaction(Accumulating_List_of_users)).

send_list(List) -> 
	Post = List,
	PostUrl = "http://localhost:5280/user",
	httpc:request(post, {PostUrl, [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
	ok.