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

% Article 589zj(1)

% 1) the court or prosecutor has not obtained the required authorization to carry out the activities with the participation of the person indicated in the EIO;
mandatory_refusal(article589zj_1_1, ExecutingMemberState, europeanInvestigationOrder):-
    \+ required_authorization_obtained(ExecutingMemberState, PersonId, europeanInvestigationOrder).

% 2) a final judgment has been rendered against the prosecuted person in a member state of the European Union for the same acts indicated in the EIO, and, if convicted of the same acts, the prosecuted person is serving a sentence or has served it, or the sentence cannot be enforced according to the law of the state where the conviction was rendered;
mandatory_refusal(article589zj_1_2, ExecutingMemberState, europeanInvestigationOrder):-
    final_judgment_rendered(EU_MemberState, PersonId, Acts),
    same_acts_indicated_in_eio(Acts, europeanInvestigationOrder),
    (serving_sentence(PersonId, Acts); served_sentence(PersonId, Acts); sentence_not_enforceable(EU_MemberState, Acts)).

% 4) the EIO concerns an interrogation in circumstances covered by an absolute prohibition of interrogation;
mandatory_refusal(article589zj_1_4, ExecutingMemberState, europeanInvestigationOrder):-
    eio_concerns_interrogation(europeanInvestigationOrder),
    absolute_prohibition_of_interrogation(ExecutingMemberState).

% 5) the execution of the EIO would violate human and civil liberties and rights;
mandatory_refusal(article589zj_1_5, ExecutingMemberState, europeanInvestigationOrder):-
    execution_violates_human_rights(europeanInvestigationOrder, ExecutingMemberState).

% 6) the requested measure would threaten national security;
mandatory_refusal(article589zj_1_6, ExecutingMemberState, europeanInvestigationOrder):-
    measure_threatens_national_security(europeanInvestigationOrder, ExecutingMemberState).

% Article 589zj(2)

% 1) the act giving rise to the issuance of the EIO, other than those listed in Article 607w CCP, does not constitute a crime under Polish law;
optional_refusal(article589zj_2_1, ExecutingMemberState, europeanInvestigationOrder):-
    act_giving_rise_to_eio(Act, europeanInvestigationOrder),
    \+ article_607w_ccp(Act),
    \+ crime_under_polish_law(Act).

% 2) the act giving rise to the issuance of the EIO under Polish law was committed in whole or in part on the territory of the Republic of Poland or on a Polish ship or aircraft and does not constitute an offense under Polish law;
optional_refusal(article589zj_2_2, ExecutingMemberState, europeanInvestigationOrder):-
    act_giving_rise_to_eio(Act, europeanInvestigationOrder),
    committed_on_polish_territory_or_vessel(Act),
    \+ offense_under_polish_law(Act).

% 3) the execution of the EIO would involve the disclosure of classified information obtained in the course of covert activities, as well as related to the conduct of these activities;
optional_refusal(article589zj_2_3, ExecutingMemberState, europeanInvestigationOrder):-
    execution_involves_disclosure_of_classified_info(europeanInvestigationOrder, ExecutingMemberState).

% 4) according to Polish law, the investigative activity to which the EIO relates cannot be carried out in the case of the crime that is the basis for its issuance;
optional_refusal(article589zj_2_4, ExecutingMemberState, europeanInvestigationOrder):-
    investigative_activity_not_allowed_for_crime(europeanInvestigationOrder, ExecutingMemberState).

% 5) according to Polish law, the investigative measure covered by the EIO cannot be carried out in the proceedings in which it was issued;
optional_refusal(article589zj_2_5, ExecutingMemberState, europeanInvestigationOrder):-
    investigative_measure_not_allowed_in_proceedings(europeanInvestigationOrder, ExecutingMemberState).

% 8) EIO concerns the hearing of persons referred to in Articles 179 § 1 or art. 180 § 1 and 2, as to the circumstances specified in these provisions.
optional_refusal(article589zj_2_8, ExecutingMemberState, europeanInvestigationOrder):-
    eio_concerns_hearing_of_persons(Articles179_180, europeanInvestigationOrder).