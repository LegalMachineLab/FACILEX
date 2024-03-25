:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).

:- initialization(main).

:- http_handler(root(facilex), facilex, []).

:- include('EAW/Decision_2002_584.pl').

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

facilex(Request) :-
    http_parameters(Request, [facts(FactsInput, [])]),
    format('Content-type: text/plain~n~n'),
    term_string(Facts, FactsInput),
    snapshot((
    forall(member(X, Facts), assert(X)),
    get_answers(Dict)
    )),
    json_write_dict(current_output, Dict, [null('')]).

get_answer(mandatory, _{article: Article, memberstate: MemberState, regulation: Regulation}) :-
    mandatory_refusal(Article, MemberState, Regulation).
get_answer(optional, _{article: Article, memberstate: MemberState, regulation: Regulation}) :-
    optional_refusal(Article, MemberState, Regulation).

get_answers(_{mandatory: MDictList, optional: ODictList}) :-
    findall(MDict, get_answer(mandatory, MDict), MDictList),
    findall(ODict, get_answer(optional, ODict), ODictList).

main:-
    server(8000).

% http://localhost:8000/facilex?facts=[proceeding_matter(marco,reato,italia),amnesty(reato,italia),executing_member_state(marco,italia),art2_4applies(italia),national_law_not_offence(reato,italia),person_role(marco,subject_eaw), person_event(marco,under_prosecution,reato)]