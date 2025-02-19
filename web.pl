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
% :- include('sources/utils.pl').

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    % Use thread_get_message to keep the server alive on a non interactive system (Docker)
    thread_get_message(_).

facilex_facts(Request) :-
    http_parameters(Request, [facts(FactsInput, [])]),
    format('Content-type: text/plain~n~n'),
    term_string(Facts, FactsInput),
    snapshot((
        forall(member(X, Facts), assertz(X)),
        get_answers(Dict)
    )),
    json_write_dict(current_output, Dict, [null('')]).

facilex(Request) :-
    http_read_data(Request, JSONIn, [json_object(dict)]),
    % listing(personId(A, B)),
    % snapshot((
    setup_call_cleanup(
        (
            parse_answers(JSONIn, 0)
        ),
        (
            get_answers(Dict),
            reply_json_dict(Dict)
        ),
        cleanup).
    
    % parse_answers(JSONIn, 0),
    % get_answers(Dict),
    % print_message(informational, Dict),
    % reply_json_dict(Dict),
    % cleanup.
    % )).

parse_test(TestNum, A, B) :-
    atomics_to_string(['api_text/case', TestNum, '.json'], File),
    open(File, read, In),
    json_read_dict(In, Test),
    close(In),
    parse_answers(Test, 0),
    get_answers(_{mandatory: A, optional: B}).
    
parse_answers(_, X) :-
    \+ question(X, _), !.

parse_answers(JSONIn, X) :-
    Y is X+1,
    question(X, Key),
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
question(17, exception_data_available).
question(18, personIdFreezing).
question(19, certificate_status).
question(20, proceeding_actor).
%ADD new questions?

clean_string(String, Clean) :-
    atomic_list_concat(Words, ' ', String),
    atomic_list_concat(Words, '_', ValueUnd),
    string_lower(ValueUnd, ValueLower),
    atom_string(Clean, ValueLower).

load_state_file(eaw, italy) :-
    load_server(A),
    atomics_to_string([A, 'sources/EAW/Decision_2002_584_it_v2.pl'], File),
    consult(File).
load_state_file(eaw, france) :-
    load_server(A),
    atomics_to_string([A, 'sources/EAW/Decision_2002_584_fr.pl'], File),
    consult(File).
load_state_file(eaw, bulgaria) :-
    load_server(A),
    atomics_to_string([A, 'sources/EAW/Decision_2002_584_bg.pl'], File),
    consult(File).
load_state_file(eaw, portugal) :-
    load_server(A),
    atomics_to_string([A, 'sources/EAW/Decision_2002_584_pt.pl'], File),
    consult(File).
load_state_file(eaw, poland) :-
    load_server(A),
    atomics_to_string([A, 'sources/EAW/Decision_2002_584_pl.pl'], File),
    consult(File).

load_state_file(eio, italy) :-
    load_server(A),
    atomics_to_string([A, 'sources/EIO/Directive_2041_41_it.pl'], File),
    consult(File).
load_state_file(eio, france) :-
    load_server(A),
    atomics_to_string([A, 'sources/EIO/Directive_2041_41_fr.pl'], File),
    consult(File).
load_state_file(eio, bulgaria) :-
    load_server(A),
    atomics_to_string([A, 'sources/EIO/Directive_2041_41_bg.pl'], File),
    consult(File).
load_state_file(eio, portugal) :-
    load_server(A),
    atomics_to_string([A, 'sources/EIO/Directive_2041_41_pt.pl'], File),
    consult(File).
load_state_file(eio, poland) :-
    load_server(A),
    atomics_to_string([A, 'sources/EIO/Directive_2041_41_pl.pl'], File),
    consult(File).

load_server("/app/") :-
    getenv('KUBERNETES_SERVICE_HOST', _), !.
load_server('').

build_fact(matter, "European Arrest Warrant") :-
    load_server(A),
    % atomics_to_string([A, 'sources/EAW/case_study_1.pl'], File),
    assert(matter(eaw)),
    atomics_to_string([A, 'sources/EAW/Decision_2002_584_v3.pl'], File),
    consult(File).

build_fact(matter, "European Investigation Order") :-
    load_server(A),
    assert(matter(eio)),
    % atomics_to_string([A, 'sources/EIO/case_study_2.pl'], File),
    atomics_to_string([A, 'sources/EIO/Directive_2014_41_v2.pl'], File),
    consult(File).

build_fact(matter, "European Freezing or Confiscation Order") :-
    load_server(A),
    assert(matter(efco)),
    % atomics_to_string([A, 'sources/Regulation/case_study_3.pl'], File),
    atomics_to_string([A, 'sources/Regulation/Regulation_2018_1805_v2.pl'], File),
    consult(File).

build_fact(personId, Value) :-
    clean_string(Value, Clean),
    assertz(personId(Clean)),
    assertz(person_role(Clean, subject_eaw)).

build_fact(personIdFreezing, Value) :-
    clean_string(Value, Clean),
    assertz(personId(Clean)),
    assertz(person_role(Clean, subject_freezingOrder)).
    
build_fact(issuing_state, Value) :-
    clean_string(Value, Clean),
    assertz(issuing_member_state(Clean)), !.

build_fact(executing_state, Value) :-
    clean_string(Value, Clean),
    matter(M),
    assertz(executing_member_state(Clean)), 
    load_state_file(M, Clean), !.

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
    assertz(amnesty(Offence, Value)), !.

build_fact(art4_eio, Value) :-
    clean_string(Value, Clean),
    assertz(Clean).

build_fact(art694_29_eio, true) :-
    assertz(art694_29_applies(interception_of_telecommunications)).

build_fact(issuing_authority, Value) :-
    clean_string(Value, Clean),
    assertz(issuing_authority(interception_of_telecommunications, Clean)).

build_fact(validating_authority, Value) :-
    clean_string(Value, Clean),
    assertz(validating_authority(interception_of_telecommunications, Clean)).

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

build_fact(national_law_not_offence_eaw, true) :-
    offence_type(Offence),
    executing_member_state(ExecutingMemberState),
    assertz(national_law_not_offence(Offence, ExecutingMemberState)), !.

build_fact(measure, Value) :-
    clean_string(Value, Clean),
    assertz(measure_type(Clean, eio)), !.

build_fact(exception_data_available, true) :-
    measure_type(Measure, eio),
    assertz(measure_data(Measure, data_directly_accessible_by_executing_authority)), !.

build_fact(certificate_status, true) :-
    issuing_member_state(IssuingMemberState),
    assertz(certificate_status(IssuingMemberState, not_transmitted)), !.

build_fact(proceeding_actor, Value) :-
    clean_string(Value, Clean),
    issuing_member_state(IssuingMemberState),
    assertz(proceeding_actor(IssuingMemberState, Clean)), !.

build_fact(contrast_with_eio, Value) :-
    clean_string(Value, Clean),
    measure_type(Measure, eio),
    executing_member_state(ExecutingMemberState),
    assertz(contrast_with(Measure, ExecutingMemberState, Clean)), !.

build_fact(proceeding_danger_eio, Value) :-
    clean_string(Value, Clean),
    measure_type(Measure, eio),
    executing_member_state(ExecutingMemberState),
    assertz(proceeding_danger(Measure, ExecutingMemberState, Clean)), !.

build_fact(national_law_does_not_authorize_eio, true) :-
    measure_type(Measure, eio),
    executing_member_state(ExecutingMemberState),
    assertz(national_law_does_not_authorize(ExecutingMemberState, Measure)), !.

build_fact(ne_bis_in_idem_eio, true) :-
    measure_type(Measure, eio),
    executing_member_state(ExecutingMemberState),
    assertz(contrary_to_ne_bis_in_idem(ExecutingMemberState, Measure)), !.

build_fact(executing_proceeding_status, Value) :-
    offence_type(Offence),
    clean_string(Value, Clean),
    executing_member_state(ExecutingMemberState),
    assertz(executing_proceeding_status(Offence, ExecutingMemberState, Clean)), !.

% Skip unknown facts temporarily
build_fact(_, _).

cleanup :-
    retractall(amnesty(_, _)),
    retractall(art2_2applies(_)),
    retractall(art2_4applies(_)),
    retractall(art4_a_applies),
    retractall(art4_b_applies),
    retractall(art4_c_applies),
    retractall(art4_d_applies),
    retractall(art694_29_applies(_)),
    retractall(certificate_status(_, _)),
    retractall(contrary_to_ne_bis_in_idem(_, _)),
    retractall(contrast_with(_, _, _)),
    retractall(crime_constitutes_offence_national_law(_, _)),
    retractall(executing_member_state(_)),
    retractall(eaw_matter(_, _, _, _)),
    retractall(executing_proceeding(_, _, _)),
    retractall(executing_proceeding_purpose(_, _)),
    retractall(executing_proceeding_status(_, _, _)),
    retractall(issuing_authority(_, _)),
    retractall(issuing_member_state(_)),
    retractall(issuing_proceeding(_, _, _)),    
    retractall(measure_data(_, _)),
    retractall(measure_type(_, _)),
    retractall(national_law_does_not_authorize(_, _)),
    retractall(national_law_not_offence(_, _)),
    retractall(offence_committed_in(_)),
    retractall(offence_type(_)),
    retractall(personId(_)),
    retractall(person_age(_, _)),
    retractall(person_event(_, _, _)),    
    retractall(person_nationality(_, _)),
    retractall(person_role(_, _)),
    retractall(proceeding_actor(_, _)),
    retractall(proceeding_danger(_, _, _)),
    retractall(validating_authority(_, _)),
    retractall(matter(_)),
    % print_message(informational, L),    
    % forall(
    %     predicate_property(A,dynamic),
    %     member(A, L) -> ! ; 
    %     retractall(A)
    % ),
    % unload_file('sources/EAW/case_study_1.pl'),
    % unload_file('sources/EIO/case_study_2.pl'),
    % unload_file('sources/Regulation/case_study_3.pl'),
    % unload_file('sources/EAW/Decision_2002_584_v3.pl'),
    % unload_file('sources/EIO/Directive_2014_41_v2.pl'),
    % unload_file('sources/Regulation/Regulation_2018_1805_v2.pl').
    unload_all.
    
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
strip_results([A|Rest], TArts, [A|Dest]) :-
    \+ member(A.article, TArts),
    append(TArts, [A.article], Arts),
    strip_results(Rest, Arts, Dest), !.
strip_results([_|Rest], Arts, Dest) :-
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

unload_all :-
    all_sources(sources, Files),
    forall(member(File, Files), (unload_file(File))).

main:-
    % consult_all,
    % consult('sources/EAW/case_study_1.pl'),
    server(8000).

% http://localhost:8000/facilex?facts=[proceeding_matter(marco,reato,italia),amnesty(reato,italia),executing_member_state(marco,italia),art2_4applies(italia),national_law_not_offence(reato,italia),person_role(marco,subject_eaw), person_event(marco,under_prosecution,reato)]
