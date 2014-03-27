-module(delta_encoding).

-export([encode/1, decode/1, sencode/1, prop_encode/1, prop_decode/1]).

encode(List) when is_list(List) -> doEncode(undef, List, []).
sencode(List) when is_list(List) -> doEncode(undef, lists:sort(List), []).
decode(List) when is_list(List) -> doDecode(undef, List, []).

prop_encode(List) when is_list(List) -> doPropEncode(1, undef, lists:sort(fun({_, A},{_, B}) when A =< B -> true; (_,_) -> false end, List), {[],[]}).
prop_decode({Keys, Values}) -> doPropDecode(1, undef, Keys, Values, []).

doEncode(undef, [], _Acc) -> [];
doEncode(Last, [Item], Acc) -> lists:reverse([Item-Last|Acc]);
doEncode(undef, [Item|Rest], Acc) -> doEncode(Item, Rest, [Item|Acc]);
doEncode(Last, [Item|Rest], Acc) -> doEncode(Item, Rest, [Item-Last|Acc]).

doPropEncode(_Count, undef, [], _Acc) -> [];
doPropEncode(Count, Last, [{Key, Value}], {KAcc, VAcc}) -> {lists:reverse([{Key, Count}|KAcc]), lists:reverse([Value-Last|VAcc])};
doPropEncode(1, undef, [{Key, Value}|Rest], {KAcc, VAcc}) -> doPropEncode(2, Value, Rest, {[{Key, 1}|KAcc], [Value|VAcc]});
doPropEncode(Count, Last, [{Key, Value}|Rest], {KAcc, VAcc}) -> doPropEncode(Count+1, Value, Rest, {[{Key, Count}|KAcc], [Value-Last|VAcc]}).

doDecode(undef,[], _Acc) -> [];
doDecode(Last,[Item], Acc) -> lists:reverse([Item+Last|Acc]);
doDecode(undef, [Item|Rest], Acc) -> doDecode(Item, Rest, [Item|Acc]);
doDecode(Last, [Item|Rest], Acc) -> doDecode(Item+Last, Rest, [Item+Last|Acc]).

doPropDecode(_Count, undef, [], [], _Acc) -> [];
doPropDecode(Count, Last, [{Key, Count}], [Item], Acc) -> lists:reverse([{Key, Item+Last}|Acc]);
doPropDecode(1, undef, [{Key, 1}|KRest], [Item|IRest], Acc) -> doPropDecode(2, Item, KRest, IRest, [{Key, Item}|Acc]);
doPropDecode(Count, Last, [{Key, Count}|KRest], [Item|IRest], Acc) -> doPropDecode(Count+1, Item+Last, KRest, IRest, [{Key, Item+Last}|Acc]).
