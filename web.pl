:- use_module(library(http/http_server)).
:- use_module(library(http/http_client)).
:- use_module(library(http/http_json)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).

:- initialization(main).

:- http_handler(root(facilex), facilex, []).
:- http_handler(root(facilex_facts), facilex_facts, []).

:- include('meta_interpreter.pl').
% :- include('EAW/Decision_2002_584.pl').

:- dynamic person_event/3.
:- dynamic person_age/2.

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    % Use thread_get_message to keep the server alive on a non interactive system (Docker)
    thread_get_message(_).

facilex_facts(Request) :-
    http_parameters(Request, [facts(FactsInput, [])]),
    format('Content-type: text/plain~n~n'),
    term_string(Facts, FactsInput),
    snapshot((
        forall(member(X, Facts), assert(X)),
        get_answers(Dict)
    )),
    json_write_dict(current_output, Dict, [null('')]).

facilex(Request) :-
    http_read_data(Request, JSONIn, [json_object(dict)]),
    snapshot((
        parse_answers(JSONIn, 0),
        get_answers(Dict),
        print_message(informational, Dict),
        reply_json_dict(Dict)
    )).

parse_test(A, B) :-
    open('api_text/case1.json', read, In),
    json_read_dict(In, Test),
    close(In),
    parse_answers(Test, 0),
    get_answers(_{mandatory: A, optional: B}).
    
parse_answers(_, X) :-
    \+ question(X, _), !.

parse_answers(JSONIn, X) :-
    Y is X+1,
    question(X, Key),
    % print_message(informational, X),
    % print_message(informational, Key),
    get_dict(Key, JSONIn, Value),
    build_fact(Key, Value),
    parse_answers(JSONIn, Y), !.

parse_answers(JSONIn, X) :-
    Y is X+1,
    parse_answers(JSONIn, Y).

question(0, matter).
question(1, personId).
question(2, person_nationality).
question(3, person_age).
question(4, issuing_state).
question(5, executing_state).
question(6, offence).
question(7, art2_eaw).
question(8, executing_proceeding_purpose).
question(9, amnesty).
question(10, offence_committed_in).
question(11, crime_recognised).
question(12, measure).
question(13, art4_eio).
question(14, art694_29_eio).
question(15, issuing_authority).
question(16, validating_authority).

clean_string(String, Clean) :-
    atomic_list_concat(Words, ' ', String),
    atomic_list_concat(Words, '_', ValueUnd),
    string_lower(ValueUnd, ValueLower),
    atom_string(Clean, ValueLower).

build_fact(matter, "European Arrest Warrant") :-
    consult('/app/sources/EAW/case_study_1.pl').

build_fact(matter, "European Investigation Order") :-
    consult('/app/sources/EIO/case_study_2.pl').

build_fact(personId, Value) :-
    clean_string(Value, Clean),
    assert(personId(Clean)),
    assert(person_role(Clean, subject_eaw)).
    
build_fact(issuing_state, Value) :-
    clean_string(Value, Clean),
    assert(issuing_member_state(Clean)), !.

build_fact(executing_state, Value) :-
    clean_string(Value, Clean),
    assert(executing_member_state(Clean)), !.

build_fact(art2_eaw, true) :-
    offence_type(Offence),
    assert(art2_2applies(Offence)), !.

build_fact(executing_proceeding_purpose, Value) :-
    clean_string(Value, Clean),
    personId(PersonId),
    % print_message(informational, R),
    assert(executing_proceeding_purpose(PersonId, Clean)), !.

build_fact(amnesty, true) :-
    offence_type(Offence),
    executing_member_state(Value),
    assert(amnesty(Offence, Value)), !.

build_fact(art4_eio, Value) :-
    clean_string(Value, Clean),
    assert(Clean).

build_fact(art694_29_eio, true) :-
    assert(art694_29_applies(interception_of_telecommunications)).

build_fact(issuing_authority, Value) :-
    clean_string(Value, Clean),
    assert(issuing_authority(interception_of_telecommunications, Clean)).

    build_fact(validating_authority, Value) :-
        clean_string(Value, Clean),
        assert(validating_authority(interception_of_telecommunications, Clean)).

build_fact(person_nationality, Value) :-
    clean_string(Value, Clean),
    personId(PersonId),
    assert(person_nationality(PersonId, Clean)), !.

build_fact(person_age, Value) :-
    personId(PersonId),
    assert(person_age(PersonId, Value)), !.

build_fact(offence, Value) :-
    clean_string(Value, Clean),
    assert(offence_type(Clean)), !.

build_fact(offence_committed_in, Value) :-
    clean_string(Value, Clean),
    assert(offence_committed_in(Clean)), !.

build_fact(crime_recognised, true) :-
    offence_type(Offence),
    assert(crime_constitutes_offence_national_law(Offence, italy)), !.

build_fact(measure, Value) :-
    clean_string(Value, Clean),
    assert(measure_type(Clean, eio)), !.

% Skip unknown facts temporarily
build_fact(_, _).
    
get_answer(mandatory, _{article: Article, memberstate: MemberState, regulation: Regulation, tree: Tree}) :-
    solve(mandatory_refusal(Article, MemberState, Regulation), TreeList),
    term_string(TreeList, Tree).
get_answer(optional, _{article: Article, memberstate: MemberState, regulation: Regulation, tree: Tree}) :-
    solve(optional_refusal(Article, MemberState, Regulation), TreeList),
    term_string(TreeList, Tree).

get_answers(_{mandatory: MDictList, optional: ODictList}) :-
    findall(MDict, get_answer(mandatory, MDict), TMDictList),
    findall(ODict, get_answer(optional, ODict), TODictList),
    strip_results(TMDictList, [], MDictList),
    strip_results(TODictList, [], ODictList).

strip_results([], _, []):- !.
% strip_results([A|Rest], [A.Article|Arts], [A|Dest]) :- Arts = [], !.
strip_results([A|Rest], _Arts, [A|Dest]) :-
    \+ member(A.article, _Arts),
    append(_Arts, [A.article], Arts),
    strip_results(Rest, Arts, Dest), !.
strip_results([A|Rest], Arts, Dest) :-
    strip_results(Rest, Arts, Dest).
% strip_results([A|Rest], Arts, TDest) :-
%     member(A.article, Arts),
%     strip_results(Rest, Arts, TDest).

all_sources(Directory, Files) :-
    working_directory(CWD, CWD),
    atom_concat(CWD, Directory, CWDSub),
    atom_concat(CWDSub, '/**/*.pl', Wildcard),
    % writeln(Wildcard),
    expand_file_name(Wildcard, Files).

consult_all :-
    all_sources(sources, Files),
    forall(member(File, Files), (writeln(File), consult(File))).

main:-
    % consult_all,
    % consult('sources/EAW/case_study_1.pl'),
    server(8000).

% http://localhost:8000/facilex?facts=[proceeding_matter(marco,reato,italia),amnesty(reato,italia),executing_member_state(marco,italia),art2_4applies(italia),national_law_not_offence(reato,italia),person_role(marco,subject_eaw), person_event(marco,under_prosecution,reato)]