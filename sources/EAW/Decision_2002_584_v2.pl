:- include('../utils.pl').

%%Decision 2002/584
%%Council Framework Decision of 13 June 2002 on the European arrest warrant and the surrender procedures between Member States (2002/584/JHA)

%%Article 1

eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    punishable_by_law()
    (
        executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    )

%%Article 3
%Grounds for mandatory non-execution of the European arrest warrant

%The judicial authority of the Member State of execution (hereinafter ‘executing judicial authority’) shall refuse to execute the European arrest warrant in the following cases:

%1. if the offence on which the arrest warrant is based[proceeding_matter(PersonId, Offence, ExecutingMemberState)] is covered by amnesty in the executing Member State, where that State had jurisdiction to prosecute the offence under its own criminal law;

%[issuing_proceeding(IssuingMemberState, PersonId, Offence)]= if the offence on which the arrest warrant is based
%amnesty(Offence, ExecutingMemberState),executing_member_state(PersonId, ExecutingMemberState)=is covered by amnesty in the executing Member State

mandatory_refusal(article3_1, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    amnesty(Offence, ExecutingMemberState),
    executing_proceeding(ExecutingMemberState, PersonId, _).


%2. if the executing judicial authority is informed that the requested person has been finally judged by a Member State in respect of the same acts provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing Member State;

%[executing_proceeding(ExecutingMemberState, PersonId, _)]= if the executing judicial authority is informed
%[person_event(PersonId, finally_judged, Offence, ExecutingMemberState)] = the requested person has been finally judged by a Member State 
%[issuing_proceeding(IssuingMemberState, PersonId, Offence)] = in respect of the same acts
%[sentence_served(PersonId, ExecutingMemberState); sentence_being_served(PersonId, ExecutingMemberState); sentence_execution_impossible(PersonId, ExecutingMemberState)]= provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing Member State;
mandatory_refusal(article3_2, ExecutingMemberState, europeanArrestWarrant):-
    executing_proceeding(ExecutingMemberState, PersonId, _),
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    person_event(PersonId, finally_judged, Offence, MemberState),
    (
        sentence_served(PersonId, MemberState)
    ;   sentence_being_served(PersonId, MemberState)
    ;   sentence_execution_impossible(PersonId, MemberState) 
    ).

%3. if the person who is the subject of the European arrest warrant may not, owing to his age, be held criminally responsible for the acts on which the arrest warrant is based under the law of the executing State.

%[executing_proceeding(ExecutingMemberState, PersonId, _)] = if the person who is the subject of the European arrest warrant
%[person_status(PersonId, under_age, ExecutingMemberState)] = may not, owing to his age, be held criminally responsible [..] under the law of the executing State

mandatory_refusal(article3_3, ExecutingMemberState, europeanArrestWarrant):-
    executing_proceeding(ExecutingMemberState, PersonId, _),
    person_status(PersonId, under_age, ExecutingMemberState).

%%Article 4
%Grounds for optional non-execution of the European arrest warrant

%The executing judicial authority may refuse to execute the European arrest warrant:
    
%1. if, in one of the cases referred to in Article 2(4), the act on which the European arrest warrant is based does not constitute an offence under the law of the executing Member State; however, in relation to taxes or duties, customs and exchange, execution of the European arrest warrant shall not be refused on the ground that the law of the executing Member State does not impose the same kind of tax or duty or does not contain the same type of rules as regards taxes, duties and customs and exchange regulations as the law of the issuing Member State;

optional_refusal(article4_1, ExecutingMemberState, europeanArrestWarrant):-
    art2_4applies(Offence),
    issuing_proceeding(_, PersonId, Offence),
    national_law_not_offence(Offence, ExecutingMemberState).

%2. where the person who is the subject of the European arrest warrant is being prosecuted in the executing Member State for the same act as that on which the European arrest warrant is based;

optional_refusal(article4_2, ExecutingMemberState, europeanArrestWarrant):-
    executing_proceeding(ExecutingMemberState, PersonId, _),,
    issuing_proceeding(_, PersonId, Offence),
    person_event(PersonId, under_prosecution, Offence, ExecutingMemberState). %proceeding_status(Offence, ExecutingMemberState, ongoing)

%3. where the judicial authorities of the executing Member State have decided either not to prosecute for the offence on which the European arrest warrant is based or to halt proceedings, or where a final judgment has been passed upon the requested person in a Member State, in respect of the same acts, which prevents further proceedings;

optional_refusal(article4_3, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(_, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, _),
    (
        executing_proceeding_status(Offence, ExecutingMemberState, no_prosecution)
    ;   executing_proceeding_status(Offence, ExecutingMemberState, halted)
    ;   person_event(PersonId, irrevocably_convicted, Offence, _)  %proceeding_status(Offence, ExecutingMemberState, final_judgement),
    ).

%4. where the criminal prosecution or punishment of the requested person is statute-barred according to the law of the executing Member State and the acts fall within the jurisdiction of that Member State under its own criminal law;

optional_refusal(article4_4, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(_, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, _),
    executing_proceeding_status(Offence, ExecutingMemberState, statute_barred).

%5. if the executing judicial authority is informed that the requested person has been finally judged by a third State in respect of the same acts provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing country;

optional_refusal(article4_5, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(_, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, _),
    person_event(PersonId, irrevocably_convicted, Offence, ThirdState),
    ExecutingMemberState \= ThirdState,
    (
        sentence_served(PersonId, ThirdState)
    ;   sentence_being_served(PersonId, ThirdState)
    ;   sentence_execution_impossible(PersonId, ThirdState) 
    ).

%6. if the European arrest warrant has been issued for the purposes of execution of a custodial sentence or detention order, where the requested person is staying in, or is a national or a resident of the executing Member State and that State undertakes to execute the sentence or detention order in accordance with its domestic law;

optional_refusal(article4_6, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(_, PersonId, Offence),
    (
        executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ),
    (   
%        person_staying_in(PersonId, ExecutingMemberState)
        person_nationality(PersonId, ExecutingMemberState)
    ;   person_residence(PersonId, _, ExecutingMemberState, _)
    ).

%7. where the European arrest warrant relates to offences which:
%(a) are regarded by the law of the executing Member State as having been committed in whole or in part in the territory of the executing Member State or in a place treated as such; or

optional_refusal(article4_7_a, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(_, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, _),
    executing_proceeding_status(Offence, ExecutingMemberState, committed_inside_territory).

%(b) have been committed outside the territory of the issuing Member State and the law of the executing Member State does not allow prosecution for the same offences when committed outside its territory.

optional_refusal(article4_7_b, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, _),
    issuing_proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, ExecutingMemberState, no_prosecution).

%%Article 4a
%Decisions rendered following a trial at which the person did not appear in person

%1. The executing judicial authority may also refuse to execute the European arrest warrant issued for the purpose of executing a custodial sentence or a detention order if the person did not appear in person at the trial resulting in the decision, unless the European arrest warrant states that the person, in accordance with further procedural requirements defined in the national law of the issuing Member State:

optional_refusal(article4a_1, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    (
        executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ),
    issuing_proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    \+ exception(optional_refusal(article4a_1_a, ExecutingMemberState, europeanArrestWarrant), _).

%(a) in due time:
%(i) either was summoned in person and thereby informed of the scheduled date and place of the trial which resulted in the decision, or by other means actually received official information of the scheduled date and place of that trial in such a manner that it was unequivocally established that he or she was aware of the scheduled trial;
%(ii) was informed that a decision may be handed down if he or she does not appear for the trial;
    
exception(optional_refusal(article4a_1_a, ExecutingMemberState, europeanArrestWarrant), article4a_1_a):-
    issuing_proceeding_event(PersonId, Offence, aware_trial),
    issuing_proceeding_event(PersonId, Offence, informed_of_potential_decision).
%person_event(PersonId, aware_trial, Offence) IF informed date and place or summoned in person?

%(b) being aware of the scheduled trial, had given a mandate to a legal counsellor, who was either appointed by the person concerned or by the State, to defend him or her at the trial, and was indeed defended by that counsellor at the trial;

exception(optional_refusal(article4a_1_a, ExecutingMemberState, europeanArrestWarrant), article4a_1_b):-
    issuing_proceeding_event(PersonId, Offence, mandated_legal_defence).

%(c) after being served with the decision and being expressly informed about the right to a retrial, or an appeal, in which the person has the right to participate and which allows the merits of the case, including fresh evidence, to be re-examined, and which may lead to the original decision being reversed:
%(i) expressly stated that he or she does not contest the decision;

exception(optional_refusal(article4a_1_a, ExecutingMemberState, europeanArrestWarrant), article4a_1_c_i):-
    issuing_proceeding_event(PersonId, Offence,informed_of_right_retrial_appeal, Offence),
    issuing_proceeding_event(PersonId, Offence, does_not_contest_decision).

%(ii) did not request a retrial or appeal within the applicable time frame;

exception(optional_refusal(article4a_1_a, ExecutingMemberState, europeanArrestWarrant), article4a_1_c_ii):-
    issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, does_not_request_retrial_appeal).

%(d) was not personally served with the decision but:
%(i) will be personally served with it without delay after the surrender and will be expressly informed of his or her right to a retrial, or an appeal, in which the person has the right to participate and which allows the merits of the case, including fresh evidence, to be re-examined, and which may lead to the original decision being reversed;
%and
%(ii) will be informed of the time frame within which he or she has to request such a retrial or appeal, as mentioned in the relevant European arrest warrant.

exception(optional_refusal(article4a_1_a, ExecutingMemberState, europeanArrestWarrant), article4a_1_c_ii):-
    issuing_proceeding_event(PersonId, Offence, not_personally_served_decision),
    issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, informed_of_timeframe_retrial_appeal).

%2. In case the European arrest warrant is issued for the purpose of executing a custodial sentence or detention order under the conditions of paragraph 1(d) and the person concerned has not previously received any official information about the existence of the criminal proceedings against him or her, he or she may, when being informed about the content of the European arrest warrant, request to receive a copy of the judgment before being surrendered. Immediately after having been informed about the request, the issuing authority shall provide the copy of the judgment via the executing authority to the person sought. The request of the person sought shall neither delay the surrender procedure nor delay the decision to execute the European arrest warrant. The provision of the judgment to the person concerned is for information purposes only; it shall neither be regarded as a formal service of the judgment nor actuate any time limits applicable for requesting a retrial or appeal.

%3. In case a person is surrendered under the conditions of paragraph (1)(d) and he or she has requested a retrial or appeal, the detention of that person awaiting such retrial or appeal shall, until these proceedings are finalised, be reviewed in accordance with the law of the issuing Member State, either on a regular basis or upon request of the person concerned. Such a review shall in particular include the possibility of suspension or interruption of the detention. The retrial or appeal shall begin within due time after the surrender.

%%Article 5
%Guarantees to be given by the issuing Member State in particular cases
%The execution of the European arrest warrant by the executing judicial authority may, by the law of the executing Member State, be subject to the following conditions:

%2. if the offence on the basis of which the European arrest warrant has been issued is punishable by custodial life sentence or life-time detention order, the execution of the said arrest warrant may be subject to the condition that the issuing Member State has provisions in its legal system for a review of the penalty or measure imposed, on request or at the latest after 20 years, or for the application of measures of clemency to which the person is entitled to apply for under the law or practice of the issuing Member State, aiming at a non-execution of such penalty or measure;

optional_refusal(article5_2, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, _),
    punishable_by_life_sentence(Offence, IssuingMemberState)
    \+ guarantee(IssuingMemberState, review_clemency_right).

%3. where a person who is the subject of a European arrest warrant for the purposes of prosecution is a national or resident of the executing Member State, surrender may be subject to the condition that the person, after being heard, is returned to the executing Member State in order to serve there the custodial sentence or detention order passed against him in the issuing Member State.

optional_refusal(article5_3, ExecutingMemberState, europeanArrestWarrant):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution),
    (   
    ;   person_nationality(PersonId, ExecutingMemberState)
    ;   person_residence(PersonId, ExecutingMemberState)
    ),
    \+ guarantee(PersonId, Offence, return_to_executing_state).
