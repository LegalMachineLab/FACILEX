:- include('../utils.pl').

%%Article 1

%The European Investigation Order and obligation to execute it

%1.   A European Investigation Order (EIO) is a judicial decision which has been issued or validated by a judicial authority of a Member State (‘the issuing State’) to have one or several specific investigative measure(s) carried out in another Member State (‘the executing State’) to obtain evidence in accordance with this Directive.
%The EIO may also be issued for obtaining evidence that is already in the possession of the competent authorities of the executing State.

eio_matter(IssuingMemberState, ExecutingMemberState, Measure):-
    issuing_proceeding(IssuingMemberState, _, Measure),
    executing_proceeding(ExecutingMemberState, _, Measure),
    (
        art4_a_applies
    ;   art4_b_applies
    ;   art4_c_applies
    ;   art4_d_applies
    ).

issuing_proceeding(IssuingMemberState, _, Measure):-
    issuing_member_state(IssuingMemberState),
    measure_type(Measure, eio).

executing_proceeding(ExecutingMemberState, _, Measure):-
    executing_member_state(ExecutingMemberState),
    measure_type(Measure, eio).

%%(c) the EIO has been issued in proceedings referred to in Article 4(b) and (c) and the investigative measure would not be authorised under the law of the executing State in a similar domestic case;

optional_refusal(article11_1_c, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
        art4_b_applies
    ;   art4_c_applies
    ),
    national_law_does_not_authorize(ExecutingMemberState, Measure),
    \+ exception(optional_refusal(article188_189, ExecutingMemberState, europeanInvestigationOrder), _).

%%In Portugal, the interception of communications requires the authorisation of a judge (Articles 188-189 Code of Criminal Procedure);

optional_refusal(article188_189, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications),
    \+ exception(optional_refusal(article188_189, ExecutingMemberState, europeanInvestigationOrder), _).

national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_authority(interception_of_telecommunications, IssuingAut),
    validating_authority(interception_of_telecommunications, ValidatingAut),
    ValidatingAut \= judge_or_court.

exception(optional_refusal(article188_189, ExecutingMemberState, europeanInvestigationOrder), article10_2_b):-
    measure_data(Measure, data_directly_accessible_by_executing_authority).