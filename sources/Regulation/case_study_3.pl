:- include('../utils.pl').

%% REGULATION (EU) 2018/1805 OF THE EUROPEAN PARLIAMENT AND OF THE COUNCIL of 14 November 2018 on the mutual recognition of freezing orders and confiscation orders

%%Article 1

regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder):-
    issuing_proceeding(IssuingMemberState, europeanFreezingOrder, Offence),
    executing_proceeding(ExecutingMemberState, europeanFreezingOrder, Offence),
    person_role(PersonId, subject_freezingOrder).

issuing_proceeding(IssuingMemberState, europeanFreezingOrder, Offence):-
    issuing_member_state(IssuingMemberState),
    offence_type(Offence).
    
executing_proceeding(ExecutingMemberState, europeanFreezingOrder, Offence):-
    executing_member_state(ExecutingMemberState),
    offence_type(Offence).

%%(c) the freezing certificate is incomplete or manifestly incorrect and has not been completed following the consultation referred to in paragraph 2;

optional_refusal(article8_1_c, ExecutingMemberState, europeanFreezingOrder):-
    regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder),
    issuing_proceeding_status(IssuingMemberState, certificate_incomplete_manifestly_incorrect).

issuing_proceeding_status(IssuingMemberState, certificate_incomplete_manifestly_incorrect):-
    certificate_status(IssuingMemberState, not_transmitted).

%% (f) in exceptional situations, there are substantial grounds to believe, on the basis of specific and objective evidence, that the execution of the freezing order would, in the particular circumstances of the case, entail a manifest breach of a relevant fundamental right as set out in the Charter, in particular the right to an effective remedy, the right to a fair trial or the right of defence.

optional_refusal(article8_1_f, ExecutingMemberState, europeanFreezingOrder):-
    regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder),
    proceeding_danger(IssuingMemberState, ExecutingMemberState, breach_fundamental_rights).

proceeding_danger(IssuingMemberState, ExecutingMemberState, breach_fundamental_rights):-
    proceeding_actor(IssuingMemberState, Actor),
    Actor = civil_party,
    executing_member_state(ExecutingMemberState).