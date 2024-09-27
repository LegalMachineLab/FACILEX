:- include('../utils.pl').

%% Закон за екстрадицията и Европейската заповед за арест
%% Extradition and European Arrest Warrant Act

%% Article 39(1) - Fully implemented
% Article 39
% The District court shall refuse to execute a European arrest warrant, where:
% 1. the offence on which the warrant is based is covered by amnesty in the Republic of Bulgaria and falls within its criminal jurisdiction;

mandatory_refusal(article39_1, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    amnesty(Offence, MemberState),
    executing_member_state(PersonId, MemberState).

%% Article 39
% The District court shall refuse to execute a European arrest warrant, where:
% 2. it has been informed that the person claimed has been finally judged by the Bulgarian court or by the court of a third Member State in respect of the same offence on which the warrant is based and the sentence has been served or is being served, or the sentence may no longer be executed under the legislation of the sentencing State;

mandatory_refusal(article39_2, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_event(PersonId, irrevocably_convicted, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

%% Article 39
% The District court shall refuse to execute a European arrest warrant, where:
% 3. the person claimed is a minor according to Bulgarian legislation.

mandatory_refusal(article39_3, MemberState, europeanArrestWarrant):-
    person_status(PersonId, under_age),
    executing_member_state(PersonId, MemberState).

%% Article 36(2) - Partially implemented
% Conditions for Applicability of European Arrest Warrant
% Article 36
% (2) A surrender on the basis of a European arrest warrant shall be carried out if the act in respect of which the said warrant is issued, also constitutes a criminal offence under the laws of the Republic of Bulgaria. In relation to taxes or duties, customs and exchange, execution of the European arrest warrant shall not be refused on the ground that the Bulgarian law does not impose the same kind of tax or duty or does not contain the same type of rules as regards taxes, duties and customs and exchange regulations as the law of the issuing Member State.

optional_refusal(article36_2, MemberState, europeanArrestWarrant):-
    art2_4applies(MemberState),
    proceeding_matter(_, Offence, MemberState),
    national_law_not_offence(Offence, MemberState).

%% Article 40(1)(1)
% The District Court may refuse to execute a European arrest warrant where: (amended, SG No. 52/2008) before reception of the warrant, the person has been arraigned as an accused party or is a defendant in the Republic of Bulgaria in respect of the offence on the basis of which the said warrant is issued

optional_refusal(article40_1_1, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_event(PersonId, under_prosecution, Offence).

%% Article 40(1)(1a)
% 1a. (new, SG No. 52/2008) the criminal prosecution for the offence on the basis of which the warrant is issued has been terminated in the Republic of Bulgaria before reception of the said warrant;

optional_refusal(article40_1_1a, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    (
%        proceeding_status(Offence, MemberState, no_prosecution)
       proceeding_status(Offence, MemberState, halted)
%    ;   person_event(PersonId, irrevocably_convicted, Offence)
    ).
% TODO - Has been terminated? = halted?

%% Article 40(1)(2)
% 2. the criminal prosecution or the execution of the punishment is statute-barred according to Bulgarian legislation and the offence is triable by a Bulgarian court;

optional_refusal(article40_1_2, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    proceeding_status(Offence, MemberState, statute_barred).

%% Article 40(1)(3)
% 3. it has been informed that the person claimed has served or is serving a sentence in a State which is not a member of the European Union, under a final judgement in respect of the same offence on which the warrant is based or the said sentence may no longer be executed under the legislation of the sentencing State;

optional_refusal(article40_1_3, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    person_event(PersonId, irrevocably_convicted_in_third_state, Offence),
    %ExecutingMemberState \= ThirdState,
    (
        sentence_served_in_third_state(PersonId)
    ;   sentence_being_served_in_third_state(PersonId)
    ;   sentence_execution_impossible_in_third_state(PersonId)
    ).

%% Article 40(1)(4)
% 4. (amended, SG No. 52/2008, supplemented, SG No. 45/2019, effective 1.01.2020) the person claimed resides or is permanently resident in the Republic of Bulgaria, or is a Bulgarian national and the Bulgarian court undertakes that the prosecutor will execute the custodial sentence or the detention order imposed by the court of the issuing Member State; Article 29(2) of the Recognition, Execution and Transmission of Judicial Instruments to Impose a Custodial Sentence or Measures involving Deprivation of Liberty Act shall apply in such cases;

optional_refusal(article40_1_4, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    (
        proceeding_status(Offence, MemberState, execution_custodial_sentence)
    ;   proceeding_status(Offence, MemberState, execution_detention_order)
    ),
    (   
       person_nationality(PersonId, MemberState)
    ;   person_residence(PersonId, _, MemberState, _)
    ;   person_residence(PersonId, person_claim_residence, MemberState, _)
    ).

%% Article 40(1)(5)
% 5. the offence has been committed in whole or in part in the territory of the Republic of Bulgaria or ....

optional_refusal(article40_1_5, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    executing_member_state(PersonId, MemberState),
    proceeding_matter(PersonId, Offence, MemberState),
    proceeding_status(Offence, MemberState, committed_inside_territory).

%% Article 40(1)(5)
% 5. the offence ... has been committed outside the territory of the issuing Member State and Bulgarian legislation does not allow criminal prosecution for the same offence when committed outside the territory of the Republic of Bulgaria.

optional_refusal(article40_1_6, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    issuing_member_state(PersonId, IssuingMemberState),
    proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, MemberState, no_prosecution).

%% Article 40(2)
% (2) (New, SG No. 55/2011) The District Court may also refuse to execute a European arrest warrant issued for the purposes of execution of a custodial sentence or detention order rendered at a trial where the person has not appeared in person, unless the European arrest warrant explicitly states that one of the following conditions is met:

optional_refusal(article40_2, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    executing_member_state(PersonId, MemberState),
    (
        proceeding_status(Offence, MemberState, execution_custodial_sentence)
    ;   proceeding_status(Offence, MemberState, execution_detention_order)
    ),
    proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    issuing_member_state(PersonId, IssuingMemberState),
    \+ exception(optional_refusal(article40_2, MemberState, europeanArrestWarrant), _).

% 1. the person was summoned in person and thereby informed, in due time, of the scheduled date and place of the trial, or was otherwise officially informed thereof in such a manner that it was unequivocally established that he/she was aware of the scheduled trial, and was informed that a decision may be handed down if he/she does not appear;
    
exception(optional_refusal(article40_2, MemberState, europeanArrestWarrant), article40_2_1):-
    person_event(PersonId, aware_trial, Offence),
    person_event(PersonId, informed_decision, Offence).
%person_event(PersonId, aware_trial, Offence) IF informed date and place or summoned in person?

% 2. having been informed of the scheduled trial in due time, the person gave mandate to a legal counsellor, or the court appointed one for the person, to defend him/her during the trial, and the person was indeed so defended;

exception(optional_refusal(article40_2, MemberState, europeanArrestWarrant), article40_2_2):-
    person_event(PersonId, aware_trial, Offence),
    person_event(PersonId, presence_legal_defence, Offence).

% 3. after the person was personally served with the decision and was expressly informed about the right to a retrial or appeal, in which he/she has the right to participate and which allows the merits of the case, including fresh evidence, to be re-examined, and which may lead to the original act being reversed, he/she expressly stated that he/she did not contest the decision, or he/she did not request a retrial or appeal within the applicable time frame;

exception(optional_refusal(article40_2, MemberState, europeanArrestWarrant), article40_2_3):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_contest_decision, Offence).

exception(optional_refusal(article40_2, MemberState, europeanArrestWarrant), article40_2_3):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_request_retrial_appeal, Offence).

% 4. the person was not personally served with the decision, but will be served therewith without delay after the surrender, and the person will be explicitly informed of the right to a retrial or appeal, in which he/she has the right to participate and which allows the merits of the case, including fresh evidence, to be re-examined, and which may lead to the original act being reversed, and of the time frame within which he/she may request a retrial or appeal.

exception(optional_refusal(article40_2, MemberState, europeanArrestWarrant), article40_2_4):-
    person_event(PersonId, not_personally_served_decision, Offence),
    person_event(PersonId, will_informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, will_informed_of_timeframe_retrial_appeal, Offence).