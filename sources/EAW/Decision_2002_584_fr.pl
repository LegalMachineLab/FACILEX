:- include('../utils.pl').

%% Code de procédure pénale
% Code of criminal procedure

%% Article 695-22(1°) - Fully implemented
% The execution of a European arrest warrant is refused in the following cases :
% 1° If the offences for which the European Arrest Warrant was issued could have been prosecuted and judged by the French courts and the public prosecution is extinguished by amnesty;

mandatory_refusal(article695_22_1, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    amnesty(Offence, MemberState),
    executing_member_state(PersonId, MemberState).

%% 2° If the requested person has been definitively judged by the French judicial authorities or by the judicial authorities of a Member State other than the issuing State for the same facts as those which are the subject of the European arrest warrant, on condition that, in the case of a conviction, the sentence has been executed or is in the process of being executed or can no longer be enforced under the laws of the convicting State;

mandatory_refusal(article695_22_2, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    person_event(PersonId, irrevocably_convicted, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

%% 3° If the requested person was aged under thirteen at the time of the offences for which the European arrest warrant was issued;

mandatory_refusal(article695_22_3, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    person_status(PersonId, under_age),
    executing_member_state(PersonId, MemberState).

person_status(PersonId, under_age):-
    person_age(PersonId, Age),
    Age < 13.

%% Article 695-24 - Fully implemented
% The execution of a European arrest warrant may be refused :
% 1° If, for the acts covered by the arrest warrant, the person who is subject to the warrant is being prosecuted before the French courts or if the French courts have decided not to institute proceedings or to terminate proceedings;

optional_refusal(article695_24_1, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    (
        proceeding_status(Offence, MemberState, no_prosecution)
    ;   proceeding_status(Offence, MemberState, halted)
    ;   person_event(PersonId, under_prosecution, Offence)
    ).

%% 2° If the person requested to execute a custodial sentence or a detention order is a French citizen, has established his or her residence in France or lives in France, and if the conviction is enforceable in France pursuant to article 728-31 ;

optional_refusal(article695_24_2, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    (
        proceeding_status(Offence, MemberState, execution_custodial_sentence)
    ;   proceeding_status(Offence, MemberState, execution_detention_order)
    ),
    (   
        person_domicile(PersonId, MemberState)
    ;   person_nationality(PersonId, MemberState)
    ;   person_residence(PersonId, _, MemberState, _)
    ).

% TODO - Add article 728_31

%% 3° If the acts for which it was issued were committed, in whole or in part, on French territory ;

optional_refusal(article695_24_3, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    executing_member_state(PersonId, MemberState),
    proceeding_matter(PersonId, Offence, MemberState),
    proceeding_status(Offence, MemberState, committed_inside_territory).

%% 4° If the offence was committed outside the territory of the issuing Member State and French law does not authorise prosecution of the offence when it is committed outside national territory;

optional_refusal(article695_24_4, MemberState, europeanArrestWarrant):-
    person_role(PersonId, subject_eaw),
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    issuing_member_state(PersonId, IssuingMemberState),
    proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, MemberState, no_prosecution).

%% 5° If the requested person has been definitively judged by the judicial authorities of a third State for the same acts as those which are the subject of the European arrest warrant, providing, in the case of a conviction, that the sentence has been enforced or is in the process of being enforced or can no longer be enforced under the laws of the convicting State;

optional_refusal(article695_24_5, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    person_role(PersonId, subject_eaw),
    proceeding_status(Offence, ThirdState, final_judgement),
    MemberState \= ThirdState,
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

%% 6° If the offences for which the European arrest warrant was issued could be prosecuted and judged by the French courts and if the time limit for prosecution or punishment has expired.

optional_refusal(article695_24_6, MemberState, europeanArrestWarrant):-
    proceeding_matter(PersonId, Offence, MemberState),
    executing_member_state(PersonId, MemberState),
    proceeding_status(Offence, MemberState, statute_barred).
