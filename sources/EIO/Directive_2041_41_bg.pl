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

% Fragment of text 1
% 1. there is an immunity or a privilege under Bulgarian legislation which make it impossible to execute the said order;
optional_refusal(article16_1_1, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    eio_execution_impossible(Measure, bulgaria).

% Fragment of text 2
% 2. the execution of the European Investigative Order would harm essential national security interests or would jeopardise a source of information, or would involve the use of classified information relating to specific intelligence activities;
optional_refusal(article16_1_2, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    (
    proceeding_danger(Measure, bulgaria, national_security);
    proceeding_danger(Measure, bulgaria, jeopardise_source_information);
    proceeding_danger(Measure, bulgaria, classified_information)
    ).

% Fragment of text 3
% 3. the execution of the European Investigative Order would be contrary to the principle of ne bis in idem, except in the cases where the said order is aimed to establish whether a possible conflict with the ne bis in idem principle exists, or where the issuing authority has provided assurances that the evidence transferred as a result of the execution of the said order would not be used to prosecute or impose a sanction on a person whose case has been finally disposed of in another Member State for the same facts;
optional_refusal(article16_1_3, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    contrary_to_ne_bis_in_idem(bulgaria, Measure).

% Fragment of text 4
% 4. The European Investigative Order has been issued in connection with the proceedings referred to in Items 2 and 3 of Article 2 (2) herein and the measure requested is not authorised according to Bulgarian legislation in a similar case;
optional_refusal(article16_1_4, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    (
        art4_b_applies
    ;   art4_c_applies
    ),
    national_law_does_not_authorize(bulgaria, Measure).

% Fragment of text 5
% 5. the European Investigative Order relates to a criminal offence which has been committed outside the territory of the issuing State but wholly or partially on the territory of the Republic of Bulgaria, and which is not an offence according to Bulgarian legislation;
optional_refusal(article16_1_5, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_outside_territory),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_inside_bulgaria),
    not_offence(Offence, bulgaria).

% Fragment of text 6
% 6. there are substantial grounds to believe that the execution of the investigative measure and the other judicial investigation measures would be incompatible with the respect for the rights and freedoms guaranteed by the Convention for the Protection of Human Rights and Fundamental Freedoms of the Council of Europe and the Charter of Fundamental Rights of the European Union;
optional_refusal(article16_1_6, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    proceeding_danger(Measure, bulgaria, incompatible_EU_obligations).

% Fragment of text 8
% 8. the act for which the European Investigative Order has been issued does not constitute a criminal offence under Bulgarian legislation, unless the European Investigative Order relates to a criminal offence on the list referred to in Article 10 (2) herein;
optional_refusal(article16_1_8, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    not_offence(Offence, bulgaria),
    \+ exception(optional_refusal(article16_1_8, bulgaria, europeanInvestigationOrder), _).

% Fragment of text 9
% 9. the measure requested is inapplicable, according to Bulgarian legislation, to the criminal offence for which the European Investigative Order has been issued.
optional_refusal(article16_1_9, bulgaria, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, bulgaria, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    national_law_does_not_authorize(bulgaria, Measure, Offence).