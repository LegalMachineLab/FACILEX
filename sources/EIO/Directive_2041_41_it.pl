:- include('../utils.pl').

eio_matter(IssuingMemberState, ExecutingMemberState, Measure):-
    issuing_member_state(IssuingMemberState),
    executing_member_state(ExecutingMemberState),
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
    executing_member_state(IssuingMemberState),
    measure_type(Measure, eio).



crime_type(Offence, committed_in(CommIn)):-
    offence_type(Offence),
    offence_committed_in(CommIn).

% Article 9(1) - Partially implemented
% When the act required for the execution of the investigation order is not provided for by Italian law or the conditions required by Italian law for its execution are not met, the public prosecutor shall, after informing the issuing authority, proceed by means of one or more different acts that are in any event suitable for achieving the same purpose.

% Article 10(1)(b) - Fully implemented
% the person against whom proceedings are being conducted enjoys immunities recognised by the Italian State which restrict or prevent the exercise or continuation of criminal prosecution;

optional_refusal(article10_1_b, italy, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, italy, Measure),
    person_role(PersonId, _),
    person_nationality(PersonId, italy),
    contrast_with(_, italy, immunity_privilege).

% Article 10(1)(c) - Fully implemented
% the execution of the investigation order could be detrimental to national security;

optional_refusal(article10_1_c, italy, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, italy, Measure),
    proceeding_danger(_, italy, national_security).

% Article 10(1)(d) - Fully implemented
% the information transmitted indicates a violation of the prohibition to submit a person, already finally judged, to a retrial for the same facts;

optional_refusal(article10_1_d, italy, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, italy, Measure),
    contrary_to_ne_bis_in_idem(italy, _).

% Article 10(1)(e) - Fully implemented
% there are reasonable grounds for considering that the performance of the act required in the investigation order is not compatible with the State's obligations under Article 6 of the Treaty on European Union and the Charter of Fundamental Rights of the European Union;

optional_refusal(article10_1_e, italy, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, italy, Measure),
    proceeding_danger(_, italy, incompatible_EU_obligations).