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
    http_server(http_dispatch, [port(Port)]).

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
    % snapshot((
        parse_answers(JSONIn, 0),
        get_answers(Dict),
        print_message(informational, Dict),
        reply_json_dict(Dict).
        % json_write_dict(current_output, Dict, [null('')])
    % )).

parse_test :-
    open('test.json', read, In),
    json_read_dict(In, Test),
    close(In),
    parse_answers(Test, 0).
    
parse_answers(JSONIn, X) :-
    \+ question(X, _), !.

parse_answers(JSONIn, X) :-
    Y is X+1,
    question(X, Key),
    print_message(informational, X),
    print_message(informational, Key),
    get_dict(Key, JSONIn, Value),
    build_fact(Key, Value),
    parse_answers(JSONIn, Y), !.

parse_answers(JSONIn, X) :-
    Y is X+1,
    parse_answers(JSONIn, Y).

question(0, personId).
question(1, person_nationality).
question(2, person_age).
question(3, issuing_state).
question(4, executing_state).
question(5, offence).
question(6, art2_eaw).
question(7, executing_proceeding_purpose).
question(8, amnesty).
question(9, offence_committed_in).
question(10, crime_recognised).
question(11, measure).
question(12, art694_29_eio).
question(13, issuing_authority).
question(14, validating_authority).

clean_string(String, Clean) :-
    atomic_list_concat(_Words, ' ', String),
    atomic_list_concat(_Words, '_', _ValueUnd),
    string_lower(_ValueUnd, ValueLower),
    atom_string(Clean, ValueLower).

build_fact(personId, Value) :-
    clean_string(Value, Clean),
    assertz(personId(Clean)),
    assertz(person_role(Clean, subject_eaw)).
    
build_fact(issuing_state, Value) :-
    clean_string(Value, Clean),
    assertz(issuing_member_state(Clean)), !.

build_fact(executing_state, Value) :-
    clean_string(Value, Clean),
    assertz(executing_member_state(Clean)), !.

build_fact(art2_eaw, true) :-
    offence_type(Offence),
    assertz(art2_2applies(Offence)), !.

build_fact(executing_proceeding_purpose, Value) :-
    clean_string(Value, Clean),
    personId(PersonId),
    % print_message(informational, R),
    assertz(executing_proceeding_purpose(PersonId, Clean)), !.

build_fact(amnesty, true) :-
    offence_type(Offence),
    executing_member_state(Value),
    assertz(amnesty(Offense, Value)), !.

% build_fact(question6, _) :-
%     personId(PersonId),
%     assertz(person_role(PersonId, subject_eaw)), !.

build_fact(person_nationality, Value) :-
    clean_string(Value, Clean),
    personId(PersonId),
    assertz(person_nationality(PersonId, Clean)), !.

build_fact(person_age, Value) :-
    personId(PersonId),
    assertz(person_age(PersonId, Value)), !.

build_fact(offence, Value) :-
    clean_string(Value, Clean),
    assertz(offence_type(Clean)), !.

build_fact(offence_committed_in, Value) :-
    clean_string(Value, Clean),
    assertz(offence_committed_in(Clean)), !.

build_fact(crime_recognised, true) :-
    offence_type(Offence),
    assertz(crime_constitutes_offence_national_law(Offence, italy)), !.

build_fact(measure, Value) :-
    clean_string(Value, Clean),
    assertz(measure_type(Clean, eio)), !.

build_fact(_, _).
    
get_answer(mandatory, _{article: Article, memberstate: MemberState, regulation: Regulation, tree: Tree}) :-
    solve(mandatory_refusal(Article, MemberState, Regulation), TreeList),
    term_string(TreeList, Tree).
get_answer(optional, _{article: Article, memberstate: MemberState, regulation: Regulation, tree: Tree}) :-
    solve(optional_refusal(Article, MemberState, Regulation), TreeList),
    term_string(TreeList, Tree).

get_answers(_{mandatory: MDictList, optional: ODictList}) :-
    findall(MDict, get_answer(mandatory, MDict), MDictList),
    findall(ODict, get_answer(optional, ODict), ODictList).

all_sources(Directory, Files) :-
    working_directory(CWD, CWD), 
    atom_concat(CWD, Directory, CWDSub), 
    atom_concat(CWDSub, '/**/*.pl', Wildcard),
    writeln(Wildcard),
    expand_file_name(Wildcard, Files).

consult_all :-
    all_sources(sources, Files),
    forall(member(File, Files), (writeln(File), consult(File))).

main:-
    % consult_all,
    consult('sources/EAW/case_study_1.pl'),
    server(8000).

% http://localhost:8000/facilex?facts=[proceeding_matter(marco,reato,italia),amnesty(reato,italia),executing_member_state(marco,italia),art2_4applies(italia),national_law_not_offence(reato,italia),person_role(marco,subject_eaw), person_event(marco,under_prosecution,reato)]