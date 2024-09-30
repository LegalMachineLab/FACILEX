:- include('../utils.pl').

eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence):-
    issuing_proceeding(IssuingMemberState, _, PersonId),
    offence_type(Offence),
    art2_2applies(Offence),
    (
        executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ).

issuing_proceeding(IssuingMemberState, _, PersonId):-
    issuing_member_state(IssuingMemberState),
    person_role(PersonId, subject_eaw).

executing_proceeding(ExecutingMemberState, PersonId, Purpose):-
    executing_member_state(ExecutingMemberState),
    executing_proceeding_purpose(PersonId, Purpose),
    member(Purpose, [criminal_prosecution, execution_custodial_sentence, execution_detention_order]),
    person_role(PersonId, subject_eaw).



%% Article 607p(1)(1) - Fully implemented
% § 1. The execution of the European Warrant shall be refused if:
% 1) criminal offence covered with the European Warrant, in the case of jurisdiction of Polish criminal courts, is subject to pardon on the basis of amnesty, [...]

mandatory_refusal(article607p_1_1, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    amnesty(Offence, poland).

%% Article 607p(1)(2) - Fully implemented
% § 1. The execution of the European Warrant shall be refused if:
% 2) valid and final ruling regarding the same acts has been issued against the wanted person in another state and, in the event of sentencing for the same acts, the wanted person is serving or has served a penalty, or the penalty may not be executed according to the law of the state in which the sentence has been pronounced,

mandatory_refusal(article607p_1_2, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    person_event(PersonId, finally_judged, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

%% Article 607p(1)(4) - Fully implemented
% § 1. The execution of the European Warrant shall be refused if:
% 4) the person who is the subject of the European warrant may not be held criminally responsible under the Polish law for the acts on which the arrest warrant is based, owing to his age,

mandatory_refusal(article607p_1_4, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    person_status(PersonId, under_age, poland).

%% Article 607r(1)(point 1) - Partially implemented
% Article 607r. 
% § 1. The execution of the European Warrant may be refused if:
% 1) offence being the basis for issuance of the European Warrant, other than those enumerated in Article 607w, is not an offence under the Polish law, [...]

optional_refusal(article607r_1_1, poland, europeanArrestWarrant):-
    art2_4applies(Offence),
    eaw_matter(_, IssuingMemberState, poland, Offence),
    national_law_not_offence(Offence, poland).

%% Article 607r(1)(point 2) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 2) in the Republic of Poland there are criminal proceedings conducted against the requested person, to whom the European Warrant applies, with regard to the offence that is the basis for the European Warrant,

optional_refusal(article607r_1_2, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    person_event(PersonId, under_prosecution, Offence).

%% Article 607r(1)(point 3) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 3) valid and final ruling on refusal to institute proceedings, on discontinuance of the proceedings, or another ruling on completing the proceedings into the case has been issued against the wanted person in connection with the act being the basis for issuance of the European Warrant,

optional_refusal(article607r_1_3, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    (
        executing_proceeding_status(Offence, poland, terminated)
%    ;   executing_proceeding_status(Offence, poland, halted)
    ;   person_event(PersonId, finally_judged, Offence)
    ).

%% Article 607r(1)(point 4) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 4) under Polish law the statute of limitations for prosecution or execution of penalty has expired and the offence falls within the jurisdiction of Polish courts,

optional_refusal(article607r_1_4, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    executing_proceeding_status(Offence, poland, statute_barred).

%% Article 607r(1)(point 5) - Fully implemented
% § 1. The execution of the European Warrant may be refused if:
% 5) European Warrant applies to offences that, under the Polish law, have been committed, in whole or in part, in the territory of the Republic of Poland, and also on board of a Polish vessel or aircraft,

optional_refusal(article607r_1_5, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    crime_type(Offence, committed_in(poland)).

optional_refusal(article607r_1_5, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    \+ crime_type(Offence, committed_in(IssuingMemberState)),
    prosecution_not_allowed(Offence, poland).

%% Article 607r(3)(a) - Fully implemented
% § 3. The execution of the European Warrant issued in order to execute the penalty of imprisonment or a measure consisting in deprivation of liberty adjudicated in absence of the wanted person may also be refused, unless:

optional_refusal(article607r_3, poland, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, poland, Offence),
    (
        executing_proceeding(poland, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(poland, PersonId, execution_detention_order)
    ),
    issuing_proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    \+ exception(optional_refusal(article607r_3, poland, europeanArrestWarrant), _).

% a) wanted person was summoned to participate in or was notified in another manner of the date and place of the trial or session and advised that a failure to appear would not prevent the issuance of a ruling, or the wanted person had a defence counsel who was present at the trial or session,

exception(optional_refusal(article607r_3, poland, europeanArrestWarrant), article607r_3_a):-
    issuing_proceeding_event(PersonId, Offence, aware_trial),
    issuing_proceeding_event(PersonId, Offence, informed_of_potential_decision).

exception(optional_refusal(article607r_3, poland, europeanArrestWarrant), article607r_3_a):-
    issuing_proceeding_event(PersonId, Offence, mandated_legal_defence).

%% b) after a copy of the ruling had been served on the wanted person along with an advice of their right, time frame and manner of submission in the warrant issuing state of a motion for new court proceedings to be conducted with the participation of the wanted person in relation to the same case, the wanted person failed to file such a motion within the statutory time frame or declared that they did not object to the ruling,

exception(optional_refusal(article607r_3, poland, europeanArrestWarrant), article607r_3_b):-
    issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, does_not_contest_decision).

exception(optional_refusal(article607r_3, poland, europeanArrestWarrant), article607r_3_b):-
    issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, does_not_request_retrial_appeal).

%% c) European Warrant issuing authority ensures that, immediately after transferring the wanted person to the warrant issuing state, the copy of the relevant ruling shall be delivered to that person together with the advice of the right, time frame and manner of submission of a motion for new court proceedings to be conducted with their in relation to the same case.

exception(optional_refusal(article607r_3, poland, europeanArrestWarrant), article607r_3_c):-
    issuing_proceeding_event(PersonId, Offence, not_personally_served_decision),
    issuing_proceeding_event(PersonId, Offence, will_informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, will_informed_of_timeframe_retrial_appeal).