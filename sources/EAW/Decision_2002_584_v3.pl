:- include('../utils.pl').

%%Decision 2002/584
%%Council Framework Decision of 13 June 2002 on the European arrest warrant and the surrender procedures between Member States (2002/584/JHA)

%%Articles 1-2
%1. The European arrest warrant is a judicial decision issued by a Member State with a view to the arrest and surrender by another Member State of a requested person, for the purposes of conducting a criminal prosecution or executing a custodial sentence or detention order.

eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    %punishable_by_law(IssuingMemberState, Offence),
    %art2applies(Offence),
    (
        art2_2applies(Offence)
    ;   art2_4applies(Offence)
    ),
    (
        executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ).

%%Article 3
%Grounds for mandatory non-execution of the European arrest warrant

%The judicial authority of the Member State of execution (hereinafter ‘executing judicial authority’) shall refuse to execute the European arrest warrant in the following cases:

%1. if the offence on which the arrest warrant is based[proceeding_matter(PersonId, Offence, ExecutingMemberState)] is covered by amnesty in the executing Member State, where that State had jurisdiction to prosecute the offence under its own criminal law;

%[issuing_proceeding(IssuingMemberState, PersonId, Offence)]= if the offence on which the arrest warrant is based
%amnesty(Offence, ExecutingMemberState),executing_member_state(PersonId, ExecutingMemberState)=is covered by amnesty in the executing Member State

mandatory_refusal(article3_1, ExecutingMemberState, europeanArrestWarrant):-
    amnesty(Offence, ExecutingMemberState),
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence).


%2. if the executing judicial authority is informed that the requested person has been finally judged by a Member State in respect of the same acts provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing Member State;

%[executing_proceeding(ExecutingMemberState, PersonId, _)]= if the executing judicial authority is informed
%[person_event(PersonId, finally_judged, Offence)] = the requested person has been finally judged by a Member State 
%[issuing_proceeding(IssuingMemberState, PersonId, Offence)] = in respect of the same acts
%[sentence_served(PersonId, ExecutingMemberState); sentence_being_served(PersonId, ExecutingMemberState); sentence_execution_impossible(PersonId, ExecutingMemberState)]= provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing Member State;
mandatory_refusal(article3_2, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    person_event(PersonId, finally_judged, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

%3. if the person who is the subject of the European arrest warrant may not, owing to his age, be held criminally responsible for the acts on which the arrest warrant is based under the law of the executing State.

%[executing_proceeding(ExecutingMemberState, PersonId, _)] = if the person who is the subject of the European arrest warrant
%[person_status(PersonId, under_age, ExecutingMemberState)] = may not, owing to his age, be held criminally responsible [..] under the law of the executing State

mandatory_refusal(article3_3, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    person_status(PersonId, under_age, ExecutingMemberState).



%%Article 4
%Grounds for optional non-execution of the European arrest warrant

%The executing judicial authority may refuse to execute the European arrest warrant:
    
%1. if, in one of the cases referred to in Article 2(4), the act on which the European arrest warrant is based does not constitute an offence under the law of the executing Member State; however, in relation to taxes or duties, customs and exchange, execution of the European arrest warrant shall not be refused on the ground that the law of the executing Member State does not impose the same kind of tax or duty or does not contain the same type of rules as regards taxes, duties and customs and exchange regulations as the law of the issuing Member State;

optional_refusal(article4_1, ExecutingMemberState, europeanArrestWarrant):-
    art2_4applies(Offence),
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    national_law_not_offence(Offence, ExecutingMemberState).

%2. where the person who is the subject of the European arrest warrant is being prosecuted in the executing Member State for the same act as that on which the European arrest warrant is based;

optional_refusal(article4_2, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    person_event(PersonId, under_prosecution_by_executing_state, Offence). %proceeding_status(Offence, ExecutingMemberState, ongoing)

%3. where the judicial authorities of the executing Member State have decided either not to prosecute for the offence on which the European arrest warrant is based or to halt proceedings, or where a final judgment has been passed upon the requested person in a Member State, in respect of the same acts, which prevents further proceedings;

optional_refusal(article4_3, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    (
        executing_proceeding_status(Offence, ExecutingMemberState, no_prosecution)
    ;   executing_proceeding_status(Offence, ExecutingMemberState, halted)
    ;   person_event(PersonId, irrevocably_convicted_in_ms, Offence)  %proceeding_status(Offence, ExecutingMemberState, final_judgement),
    ).

%4. where the criminal prosecution or punishment of the requested person is statute-barred according to the law of the executing Member State and the acts fall within the jurisdiction of that Member State under its own criminal law;

optional_refusal(article4_4, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    executing_proceeding_status(Offence, ExecutingMemberState, statute_barred).

%5. if the executing judicial authority is informed that the requested person has been finally judged by a third State in respect of the same acts provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing country;

optional_refusal(article4_5, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    person_event(PersonId, irrevocably_convicted_in_third_state, Offence),
    %ExecutingMemberState \= ThirdState,
    (
        sentence_served_in_third_state(PersonId)
    ;   sentence_being_served_in_third_state(PersonId)
    ;   sentence_execution_impossible_in_third_state(PersonId)
    ).

%6. if the European arrest warrant has been issued for the purposes of execution of a custodial sentence or detention order, where the requested person is staying in, or is a national or a resident of the executing Member State and that State undertakes to execute the sentence or detention order in accordance with its domestic law;

optional_refusal(article4_6, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    (
        executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ),
    (   
%        person_staying_in(PersonId, ExecutingMemberState)
        person_nationality(PersonId, ExecutingMemberState)
    ;   person_residence(PersonId, _, ExecutingMemberState, _)
    ).

