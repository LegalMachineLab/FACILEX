:- set_prolog_flag(unknown, warning).

%% Ustawa z dnia 6 czerwca 1997 r. - Kodeks postępowania karnego
% Law of 6 June 1997 - Code of Criminal Procedure

%% Article 607p(1)(1) - Fully implemented
% § 1. The execution of the European Warrant shall be refused if:
% 1) criminal offence covered with the European Warrant, in the case of jurisdiction of Polish criminal courts, is subject to pardon on the basis of amnesty, [...]

mandatory_refusal(article607p_1_1, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    amnesty(Offence, MemberState),
    executing_member_state(PersonId, MemberState).

%% Article 607p(1)(2) - Fully implemented
% § 1. The execution of the European Warrant shall be refused if:
% 2) valid and final ruling regarding the same acts has been issued against the wanted person in another state and, in the event of sentencing for the same acts, the wanted person is serving or has served a penalty, or the penalty may not be executed according to the law of the state in which the sentence has been pronounced,

mandatory_refusal(article607p_1_2, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    person_event(PersonId, irrevocably_convicted, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

%% Article 607p(1)(4) - Fully implemented
% § 1. The execution of the European Warrant shall be refused if:
% 4) the person who is the subject of the European warrant may not be held criminally responsible under the Polish law for the acts on which the arrest warrant is based, owing to his age,

mandatory_refusal(article607p_1_4, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    person_status(PersonId, under_age),
    executing_member_state(PersonId, MemberState).

%%%% TODO

% Poland transposed correctly all three mandatory grounds for refusal of execution of the EAW but also introduced four additional ones.

%% According to Article 607p § 1 CCP the execution of the European Arrest Warrant shall be refused, if it would infringe freedoms and human and citizens rights (point 5) or the offence was committed without violence for political reasons (point 6). For more information see comment to Article 1(3) FD EAW.

mandatory_refusal(article607p_1_5, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    (
        proceeding_status(Offence, MemberState, danger_human_rights)
    ;   proceeding_status(Offence, MemberState, no_violence_political_reasons)
    ).

% Additionally, the execution of an EAW will be refused in case of Polish citizens if there is a lack of double criminality (consequence stemming from the requirement from Article 607p§2 CCP). For more information see comment to Article 4(1) FD EAW.

mandatory_refusal(article607p_2, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    person_nationality(PersonId, polish),
    national_law_not_offence(Offence, polish).

% TODO - how different from 607r_1_1?

% Execution of an EAW will also be refused in case of a lack of a consent to surrender in case of an EAW issued for execution purposes in case of Polish nationals and persons exercising his asylum right in the Republic of Poland (Article 607s§1 CCP). For more information see comment to Article 4(6) FD EAW.

mandatory_refusal(article607s_1, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    person_event(PersonId, no_consent_surrender),
    proceeding_status(Offence, MemberState, execution),
    (
        person_nationality(PersonId, polish)
    ;   person_event(PersonId, asylum)
    ).

%%%%

%% Article 607r(1)(point 1) - Partially implemented
% Article 607r. 
% § 1. The execution of the European Warrant may be refused if:
% 1) offence being the basis for issuance of the European Warrant, other than those enumerated in Article 607w, is not an offence under the Polish law, [...]

optional_refusal(article607r_1_1, MemberState, europeanArrestWarrant):-
    art2_4applies(MemberState),
    proceeding_matter(_, Offence, MemberState),
    national_law_not_offence(Offence, MemberState).

%% Article 607r(1)(point 2) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 2) in the Republic of Poland there are criminal proceedings conducted against the requested person, to whom the European Warrant applies, with regard to the offence that is the basis for the European Warrant,

optional_refusal(article607r_1_2, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_event(PersonId, under_prosecution, Offence).

%% Article 607r(1)(point 3) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 3) valid and final ruling on refusal to institute proceedings, on discontinuance of the proceedings, or another ruling on completing the proceedings into the case has been issued against the wanted person in connection with the act being the basis for issuance of the European Warrant,

optional_refusal(article607r_1_3, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    (
        proceeding_status(Offence, MemberState, no_prosecution)
    ;   proceeding_status(Offence, MemberState, halted)
    ;   person_event(PersonId, irrevocably_convicted, Offence)  %proceeding_status(Offence, MemberState, final_judgement),
    ).

%% Article 607r(1)(point 4) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 4) under Polish law the statute of limitations for prosecution or execution of penalty has expired and the offence falls within the jurisdiction of Polish courts,

optional_refusal(article607r_1_4, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    proceeding_status(Offence, MemberState, statute_barred).

%% Article 607r(1)(point 5) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 5) European Warrant applies to offences that, under the Polish law, have been committed, in whole or in part, in the territory of the Republic of Poland, and also on board of a Polish vessel or aircraft,

optional_refusal(article607r_1_5, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    executing_member_state(PersonId, MemberState),
    proceeding_matter(PersonId, Offence, MemberState),
    proceeding_status(Offence, MemberState, committed_inside_territory).

optional_refusal(article607r_1_5, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    issuing_member_state(PersonId, IssuingMemberState),
    proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, MemberState, no_prosecution).

%% Article 607r(3)(a) - Fully implemented
% § 3. The execution of the European Warrant issued in order to execute the penalty of imprisonment or a measure consisting in deprivation of liberty adjudicated in absence of the wanted person may also be refused, unless:

optional_refusal(article607r_3, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    executing_member_state(PersonId, MemberState),
    (
        proceeding_status(Offence, MemberState, execution_custodial_sentence)
    ;   proceeding_status(Offence, MemberState, execution_detention_order)
    ),
    proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    issuing_member_state(PersonId, IssuingMemberState),
    \+ exception(optional_refusal(article607r_3, MemberState, europeanArrestWarrant), _).

% a) wanted person was summoned to participate in or was notified in another manner of the date and place of the trial or session and advised that a failure to appear would not prevent the issuance of a ruling, or the wanted person had a defence counsel who was present at the trial or session,

exception(optional_refusal(article607r_3, MemberState, europeanArrestWarrant), article607r_3_a):-
    person_event(PersonId, aware_trial, Offence),
    person_event(PersonId, informed_decision, Offence).

exception(optional_refusal(article607r_3, MemberState, europeanArrestWarrant), article607r_3_a):-
    person_event(PersonId, presence_legal_defence, Offence).

%% b) after a copy of the ruling had been served on the wanted person along with an advice of their right, time frame and manner of submission in the warant issuing state of a motion for new court proceedings to be conducted with the participation of the wanted person in relation to the same case, the wanted person failed to file such a motion within the statutory time frame or declared that they did not object to the ruling,

exception(optional_refusal(article607r_3, MemberState, europeanArrestWarrant), article607r_3_b):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_contest_decision, Offence).

exception(optional_refusal(article607r_3, MemberState, europeanArrestWarrant), article607r_3_b):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_request_retrial_appeal, Offence).

%% c) European Warrant issuing authority ensures that, immediately after transferring the wanted person to the warrant issuing state, the copy of the relevant ruling shall be delivered to that person together with the advice of the right, time frame and manner of submission of a motion for new court proceedings to be conducted with their in relation to the same case.

exception(optional_refusal(article607r_3, MemberState, europeanArrestWarrant), article607r_3_c):-
    person_event(PersonId, not_personally_served_decision, Offence),
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, informed_of_timeframe_retrial_appeal, Offence).

%% Article 607s(1 and 2) - Partially implemented
% § 1. The European Warrant issued to execute the penalty of imprisonment or a measure consisting in deprivation of liberty with regard to the wanted person who is a Polish citizen or has been granted asylum in the Republic of Poland shall not be executed, unless such a person expresses consent to the extradition.

% § 2. The execution of the European Warrant may also be refused if it has been issued for the purpose referred to in § 1, and the wanted person has the place of residence or permanently stays in the territory of the Republic of Poland.

% § 3. By refusing the extradition due to reasons specified in § 1 or § 2, the court shall decide on the execution of the penalty or measure adjudicated by the judicial authority of the European Warrant issuing state.

% § 4. In the decision referred to in § 3, the court shall determine legal classification of the act under the Polish law. If the penalty or measure adjudicated by the judicial authority of the European Warrant issuing state exceeds the statutory maximum limit, the court shall determine a penalty or measure to be executed accordingly to the Polish law equal to the maximum possible statutory period, taking into account the period of the actual deprivation of liberty abroad and the penalty or measure executed there. If the European Warrant has not been accompanied by documents or information necessary for the execution of penalty in the territory of the Republic of Poland, the court shall postpone its session and request the competent body of the European Warrant issuing state to send such documents or information.

% § 5. The penalty shall be executed in accordance with provisions of the Polish law. The provisions of Chapter 66g apply accordingly, except for Article 611tg, Article 611ti § 2 and § 3, Article 611tk, Article 611tm, Article 611to § 2 and Article 611tp.
