:-[freq].

:-[rank].

main(H1,H3,H5,H10,MRR):-
  findall(R,rank(_G,_A,R),FilteredRanks),
  findall(A,rank(_,A,_R),Args),
  length(Args,NT),
  maplist(rankl,Args,FilteredRanks,Ranks),
  maplist(hits(Ranks,NT),[1,3,5,10],[H1,H3,H5,H10]),
  maplist(rr,Ranks,RR),
  sum_list(RR,SRR),
  MRR is SRR/NT.

rr(Rank,RR):-
  RR is 1/Rank.

hits(Ranks,N,K,H):-
  maplist(hit(K),Ranks,Hits),
  sum_list(Hits,S),
  H is S/N.

hit(K,R,H):-
  (R=< K->
    H=1
  ;
    H=0
  ).




/**
 * rankl(:Element:term,+OrderedList:list,-Rank:float) is det
 * 
 * The predicate returns the rank of Element in the list OrderedList.
 * Group of records with the same value are assigned the average of the ranks.
 * OrderedList is a list of pairs (S - E) where S is the score and E is the element.
 * 
 * https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.rank.html
 */
rankl(E,L,R):-
  rank_group_freq(L,E,+inf,0,1,[],R).

/**
* rank_group(+OrderedList:list,:Element:term,+CurrentScore:float,+LengthOfCurrentGroup:float,+CurrentPosition:float,-Rank:float) is det
* 
* CurrentScore is the score of the current group. LengthOfCurrentGroup is the number of elements in the current group.
* CurrentPosition is the position of the first element in the list.
*/
rank_group_freq([],_E,_S,_NG,_N,_,+inf).

rank_group_freq([(S1 - E1)|T],E,S,NG,N,L,R):-
N1 is N+1,
(E1==E->
  (S1<S->
    rank_group_freq_found(T,E,S1,1,N1,[(S1-E1)],R)
  ;
    NG1 is NG+1,
    rank_group_freq_found(T,E,S1,NG1,N1,[(S1-E1)|L],R)
  )
;
  (S1<S->
    rank_group_freq(T,E,S1,1,N1,[(S1-E1)],R)
  ;
    NG1 is NG+1,
    rank_group_freq(T,E,S1,NG1,N1,[(S1-E1)|L],R)
  )
).

/**
* rank_group_found(+OrderedList:list,+CurrentScore:float,+LengthOfCurrentGroup:float,+CurrentPosition:float,-Rank:float) is det
* 
* CurrentScore is the score of the current group. LengthOfCurrentGroup is the number of elements in the current group.
* CurrentPosition is the position of the first element in the list. The group contains the element to be ranked.
*/
rank_group_freq_found([],E,_S,NG,N,L,R):-!,
  rank_by_freq(L,E,RG),
  R is N-1-NG+RG.

rank_group_freq_found([(S1 - E1)|T],E,S,NG,N,L,R):-
(S1<S->
  rank_by_freq(L,E,RG),
  R is N-1-NG+RG
;
  N1 is N+1,
  NG1 is NG+1,
  rank_group_freq_found(T,E,S1,NG1,N1,[(S1-E1)|L],R)
).

rank_by_freq([(_-_)],_,1):-!.

rank_by_freq(L,E,R):-
  freq(D),
  maplist(freq_ass(D),L,LT),
  sort(0, @>=, LT,  LS),
  rank_av(E,LS,R).

freq_ass(D,(_ - E),(F-E)):-
  F=D.get(E).
%  writeln(fr(F)). 

rank_av(E,L,R):-
  rank_group_av(L,E,+inf,0,1,R).

/**
* rank_group(+OrderedList:list,:Element:term,+CurrentScore:float,+LengthOfCurrentGroup:float,+CurrentPosition:float,-Rank:float) is det
* 
* CurrentScore is the score of the current group. LengthOfCurrentGroup is the number of elements in the current group.
* CurrentPosition is the position of the first element in the list.
*/
rank_group_av([],_E,_S,_NG,_N,+inf).

rank_group_av([(S1 - E1)|T],E,S,NG,N,R):-
N1 is N+1,
(E1==E->
  (S1<S->
    rank_group_av_found(T,S1,1,N1,R)
  ;
    NG1 is NG+1,
    rank_group_av_found(T,S1,NG1,N1,R)
  )
;
  (S1<S->
    rank_group_av(T,E,S1,1,N1,R)
  ;
    NG1 is NG+1,
    rank_group_av(T,E,S1,NG1,N1,R)
  )
).

/**
* rank_group_found(+OrderedList:list,+CurrentScore:float,+LengthOfCurrentGroup:float,+CurrentPosition:float,-Rank:float) is det
* 
* CurrentScore is the score of the current group. LengthOfCurrentGroup is the number of elements in the current group.
* CurrentPosition is the position of the first element in the list. The group contains the element to be ranked.
*/
rank_group_av_found([],_S,NG,N,R):-
  R is N-(NG+1.0)/2.

rank_group_av_found([(S1 - _E1)|T],S,NG,N,R):-
(S1<S->
  R is N-(NG+1.0)/2
;
  N1 is N+1,
  NG1 is NG+1,
  rank_group_av_found(T,S1,NG1,N1,R)
).


main_hr:-
  main(H1,H3,H5,H10,MRR),writeln(H1),writeln(H3),writeln(H5),writeln(H10),writeln(MRR).
:- initialization(main_hr,main).