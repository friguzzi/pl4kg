

:- ensure_loaded(train).
%:- include(valid).


:- include(theory).

main:-
  open('out_conf_oi.pl',write,St),
  in(R),
  concurrent_maplist(confidence, R, RC, S),
  writeln(St,'out(['),
  write_rules(RC,S,St),
  writeln(St,']).'),
  close(St).

write_rules([(H:P:-B)],[(SB,SH)],S):-!,
  copy_term((H,B),(H1,B1)),
  numbervars((H1,B1),0,_M),
  and2list(B1,BL),
  write(S,'('),
  write_disj_clause(S,([H1:P]:-BL)),
  write(S,') % '), write(S,SB),write(S,' '),writeln(S,SH).

write_rules([H:P:-B|T],[(SB,SH)|ST],S):-!,
  copy_term((H,B),(H1,B1)),
  numbervars((H1,B1),0,_M),
  and2list(B1,BL),
  write(S,'('),
  write_disj_clause(S,([H1:P]:-BL)),
  write(S,'), % '), write(S,SB),write(S,' '),writeln(S,SH),
  write_rules(T,ST,S).



write_disj_clause(S,(H:-[])):-!,
  write_head(S,H),
  format(S,".~n~n",[]).

write_disj_clause(S,(H:-B)):-
  write_head(S,H),
  format(S,' :- ',[]),
  write_body(S,B).


write_head(S,[A:1.0|_Rest]):-!,
  format(S,"~q:1.0",[A]).

write_head(S,[A:P,'':_P]):-!,
  format(S,"~q:~g",[A,P]).

write_head(S,[A:P]):-!,
  format(S,"~q:~g",[A,P]).

write_head(S,[A:P|Rest]):-
  format(S,"~q:~g ; ",[A,P]),
  write_head(S,Rest).

write_body(S,[]):-!,
  format(S,"  true",[]).

write_body(S,[A]):-!,
  format(S,"  ~q",[A]).

write_body(S,[A|T]):-
  format(S,"  ~q,",[A]),
  write_body(S,T).
confidence(((tt(A,R,B):_P):-Body),((tt(A,R,B):C):-Body_no_inv),(SupportBody,SupportRule)):-
  and2list(Body,BodyL),
  maplist(remove_inv_lit,BodyL,BodyL_no_inv),
  list2and(BodyL_no_inv,Body_no_inv),
  term_variables(Body_no_inv,Vars),
  (aggregate_all(count, (A,B),(Body_no_inv,oi(Vars)),SupportBody)->
    (aggregate_all(count, (t(A,R,B),once((Body_no_inv,oi(Vars)))),SupportRule)->
      true
    ;
      SupportRule=0
    ), 
    (SupportBody=0->
      C=0
    ;
      C is SupportRule/SupportBody
    )
  ;
    SupportBody=0,
    SupportRule=0,
    C=0
  ).
%,
%  write(((tt(A,R,B):P):-Body)),write(C),write(' '),write(SupportBody),write(' '),write(SupportRule),nl.
  
oi(Vars):-
  sort(Vars,VarsOI),
  length(VarsOI,LOI),
  length(Vars,L),
  L=LOI.

and2list((A,B),[A|L]):-
  !,
  and2list(B,L).

and2list(A,[A]).

list2and([A],A):-
  !.

list2and([A|L],(A,B)):-
  list2and(L,B).

remove_inv_lit(r(A,i(R),B),t(B,R,A)):-!.
remove_inv_lit(r(A,R,B),t(A,R,B)).


write_rule(S,R,(SB,SR)):-
  write(S,'('),
  write_canonical(S,R),
  write(S,'), %'),
  write(S,SB),write(S,' '),write(S,SR),nl(S).


:- initialization(main,main).