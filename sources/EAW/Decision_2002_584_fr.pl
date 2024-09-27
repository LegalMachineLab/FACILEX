%% Article 695-22(1°) - Fully implemented
% The execution of a European arrest warrant is refused in the following cases :
% 1° If the offences for which the European Arrest Warrant was issued could have been prosecuted and judged by the French courts and the public prosecution is extinguished by amnesty;

mandatory_refusal(article695_22_1, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    amnesty(Offence, france).

%% 2° If the requested person has been definitively judged by the French judicial authorities or by the judicial authorities of a Member State other than the issuing State for the same facts as those which are the subject of the European arrest warrant, on condition that, in the case of a conviction, the sentence has been executed or is in the process of being executed or can no longer be enforced under the laws of the convicting State;

mandatory_refusal(article695_22_2, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    person_event(PersonId, finally_judged, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId)
    ).

%% 3° If the requested person was aged under thirteen at the time of the offences for which the European arrest warrant was issued;

mandatory_refusal(article695_22_3, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    person_status(PersonId, under_age, france).

%% Article 695-23 - Fully implemented
% The execution of a European arrest warrant may also be refused if the offence for which the warrant is issued does not constitute an offence under French law.

optional_refusal(article695_23, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    national_law_not_offence(Offence, france).

%% Article 695-24 - Fully implemented
% The execution of a European arrest warrant may be refused :
% 1° If, for the acts covered by the arrest warrant, the person who is subject to the warrant is being prosecuted before the French courts or if the French courts have decided not to institute proceedings or to terminate proceedings;

optional_refusal(article695_24_1, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    (
        executing_proceeding_status(Offence, france, no_prosecution)
    ;   executing_proceeding_status(Offence, france, halted)
    ;   person_event(PersonId, under_prosecution, Offence)
    ).

%% 2° If the person requested to execute a custodial sentence or a detention order is a French citizen, has established his or her residence in France or lives in France, and if the conviction is enforceable in France pursuant to article 728-31 ;

optional_refusal(article695_24_2, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    (
        executing_proceeding(france, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(france, PersonId, execution_detention_order)
    ),
    (
        person_nationality(PersonId, france)
    ;   person_residence(PersonId, france)
    ).

%% 3° If the acts for which it was issued were committed, in whole or in part, on French territory ;

optional_refusal(article695_24_3, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    crime_type(Offence, committed_in(france)).

%% 4° If the offence was committed outside the territory of the issuing Member State and French law does not authorise prosecution of the offence when it is committed outside national territory;

optional_refusal(article695_24_4, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    \+ crime_type(Offence, committed_in(IssuingMemberState)),
    prosecution_not_allowed(Offence, france).

%% 5° If the requested person has been definitively judged by the judicial authorities of a third State for the same acts as those which are the subject of the European arrest warrant, providing, in the case of a conviction, that the sentence has been enforced or is in the process of being enforced or can no longer be enforced under the laws of the convicting State;

optional_refusal(article695_24_5, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    person_event(PersonId, irrevocably_convicted_in_third_state, Offence),
    (
        sentence_served_in_third_state(PersonId)
    ;   sentence_being_served_in_third_state(PersonId)
    ;   sentence_execution_impossible_in_third_state(PersonId)
    ).

%% 6° If the offences for which the European arrest warrant was issued could be prosecuted and judged by the French courts and if the time limit for prosecution or punishment has expired.

optional_refusal(article695_24_6, france, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, france, Offence),
    executing_proceeding_status(Offence, france, statute_barred).
