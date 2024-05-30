:- include('../utils.pl').

%%Decision 2002/584
%%Council Framework Decision of 13 June 2002 on the European arrest warrant and the surrender procedures between Member States (2002/584/JHA)

%%Articles 1-2
%1. The European arrest warrant is a judicial decision issued by a Member State with a view to the arrest and surrender by another Member State of a requested person, for the purposes of conducting a criminal prosecution or executing a custodial sentence or detention order.

eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence):-
    issuing_proceeding(IssuingMemberState, PersonId),
    offence_type(Offence),
    (
        art2_2applies(Offence)
    ;   art2_4applies(Offence)
    ),
    (
        executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ).

art2_4applies(Offence):-
    \+ art2_2applies(Offence).

issuing_proceeding(IssuingMemberState, PersonId):-
    issuing_member_state(IssuingMemberState),
    person_role(PersonId, subject_eaw).

executing_proceeding(ExecutingMemberState, PersonId, Purpose):-
    executing_member_state(ExecutingMemberState),
    executing_proceeding_purpose(PersonId, Purpose),
    member(Purpose, [criminal_prosecution, execution_custodial_sentence, execution_detention_order]),
    person_role(PersonId, subject_eaw).

executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence):-
    executing_member_state(ExecutingMemberState),
    executing_proceeding_purpose(PersonId, execution_custodial_sentence),
    person_role(PersonId, subject_eaw).

executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order):-
    executing_member_state(ExecutingMemberState),
    executing_proceeding_purpose(PersonId, execution_detention_order),
    person_role(PersonId, subject_eaw).

crime_type(Offence, committed_in(CommIn)):-
    offence_type(Offence),
    offence_committed_in(CommIn).

%3. if the person who is the subject of the European arrest warrant may not, owing to his age, be held criminally responsible for the acts on which the arrest warrant is based under the law of the executing State.

%[executing_proceeding(ExecutingMemberState, PersonId, _)] = if the person who is the subject of the European arrest warrant
%[person_status(PersonId, under_age, ExecutingMemberState)] = may not, owing to his age, be held criminally responsible [..] under the law of the executing State

mandatory_refusal(article3_3, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    person_status(PersonId, under_age, ExecutingMemberState).

person_status(PersonId, under_age, ExecutingMemberState):-
    person_age(PersonId, Age),
    executing_member_state(ExecutingMemberState).

%%Article 4
%Grounds for optional non-execution of the European arrest warrant

%The executing judicial authority may refuse to execute the European arrest warrant:
    
%1. if, in one of the cases referred to in Article 2(4), the act on which the European arrest warrant is based does not constitute an offence under the law of the executing Member State; however, in relation to taxes or duties, customs and exchange, execution of the European arrest warrant shall not be refused on the ground that the law of the executing Member State does not impose the same kind of tax or duty or does not contain the same type of rules as regards taxes, duties and customs and exchange regulations as the law of the issuing Member State;

optional_refusal(article4_1, ExecutingMemberState, europeanArrestWarrant):-
    art2_4applies(Offence),
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    national_law_not_offence(Offence, ExecutingMemberState).

%% Legge 22 aprile 2005, n. 69
%% Provisions to adapt national legislation to the Council Framework Decision 2002/584/JHA of 13 June 2002 on the European arrest warrant and the surrender procedures between Member States

%% Art. 1
%1.[...]
%2. Il mandato d'arresto europeo è una decisione giudiziaria emessa da uno Stato membro dell'Unione europea, di seguito denominato "Stato membro di emissione", in vista dell'arresto e della consegna da parte di un altro Stato membro, di seguito denominato "Stato membro di esecuzione", di una persona, al fine dell'esercizio di azioni giudiziarie in materia penale o dell'esecuzione di una pena o di una misura di sicurezza privative della libertà personale.

eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence):-
    issuing_proceeding(IssuingMemberState, PersonId),
    crime_type(Offence, committed_in(MemberState)),
    (
        executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(ExecutingMemberState, PersonId, execution_detention_order)
    ).

% c) if the person who is the subject of the European arrest warrant was a minor 14 years of age at the time of the commission of the offence.

mandatory_refusal(article18_1_c, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    person_status(PersonId, under_age, italy).

person_status(PersonId, under_age, italy):-
    person_age(PersonId, Age),
    Age < 14,
    executing_member_state(italy).

%% Article 7(1-2) - Fully implemented
% 1. Italy shall execute the European arrest warrant only where the act constitutes a criminal offence under national law, irrespective of its legal classification and the single constituent elements of the offence.
% 2. For the purposes of paragraph 1, for offences relating to taxes, customs and exchanges, it is not necessary that Italian law imposes the same kind of taxes or duties or contains the same kind of tax, duty, customs and exchange regulations as the law of the issuing Member State.

mandatory_refusal(article7_1, MemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    national_law_not_offence(Offence, italy).

national_law_not_offence(Offence, italy):-
    \+ crime_constitutes_offence_national_law(Offence, italy).

national_law_not_offence(driving_without_license, italy):-
    cassazione(numero_41102_2022, driving_without_license, italy).

cassazione(numero_41102_2022, driving_without_license, italy).