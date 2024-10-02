:- include('../utils.pl').

%% Regime Jurídico do Mandado de Detenção Europeu (Lei n.º 65/2003, de 23 de Agosto)
%% Law on the European Arrest Warrant (Law no. 65/2003, of 23 August)

eaw_matter(PersonId, IssuingMemberState, portugal, Offence):-
    issuing_proceeding(IssuingMemberState, _, PersonId),
    offence_type(Offence),
    art2_2applies(Offence),
    (
        executing_proceeding(portugal, PersonId, criminal_prosecution)
    ;   executing_proceeding(portugal, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(portugal, PersonId, execution_detention_order)
    ).

issuing_proceeding(IssuingMemberState, _, PersonId):-
    issuing_member_state(IssuingMemberState),
    person_role(PersonId, subject_eaw).

executing_proceeding(portugal, PersonId, Purpose):-
    executing_member_state(portugal),
    executing_proceeding_purpose(PersonId, Purpose),
    member(Purpose, [criminal_prosecution, execution_custodial_sentence, execution_detention_order]),
    person_role(PersonId, subject_eaw).

%% Article 11(a) - Fully implemented
% The offence on which the arrest warrant is based is covered by amnesty in Portugal, where the Portuguese courts have jurisdiction to prosecute the offence;

mandatory_refusal(article11_a, portugal, europeanArrestWarrant):-
    amnesty(Offence, portugal),
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence).

%% Article 11(b) - Fully implemented
% The requested person has been finally judged by a Member State in respect of the same acts provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the Member State where the decision has been taken;

mandatory_refusal(article11_b, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    person_event(PersonId, finally_judged, Offence),
    sentence_served_being_served_or_execution_impossible(PersonId).

%% Article 11(c) - Fully implemented
% Under Portuguese law, the requested person may not, owing to his/her age, be held criminally responsible for the acts on which the European arrest warrant is based.

mandatory_refusal(article11_c, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    person_status(PersonId, under_age, portugal).

person_status(PersonId, under_age, italy):-
    person_age(PersonId, Age),
    Age < 16.

%% Article 2(3) - Fully implemented
% For offences other than those covered by the preceding paragraph, the surrender of the requested person shall only take place if the acts for which the European arrest warrant has been issued constitute an offence under the Portuguese law, whatever the constituent elements or however it is described.

optional_refusal(article2_3, portugal, europeanArrestWarrant):-
    art2_4applies(Offence),
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    national_law_not_offence(Offence, portugal).

%% Article 12(1)(b) - Fully implemented
% A criminal procedure against the requested person is pending in Portugal for the same acts as that for which the European arrest warrant was issued;

optional_refusal(article12_1_b, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    person_event(PersonId, under_prosecution, Offence).

%% Article 12(1)(c) - Fully implemented
% Knowing the facts on which the European arrest warrant is based, the Public Prosecution Office decides either not to prosecute or to terminate the proceedings through discontinuation;

optional_refusal(article12_1_c, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    executing_proceeding_status(Offence, portugal, non_prosecution_or_halted_proceeding).

%% Article 12(1)(d) - Fully implemented
% A final judgment has been passed upon the requested person in a Member State, in respect of the same acts, which prevents further proceedings, in cases other than those referred to in Article 11(b).

optional_refusal(article12_1_d, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    person_event(PersonId, finally_judged, Offence).

%% Article 12(1)(e) - Fully implemented
% The criminal prosecution or punishment of the requested person is statute-barred according to the Portuguese law, provided that the Portuguese courts have jurisdiction over the conduct for which the European arrest warrant has been issued;

optional_refusal(article12_1_e, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    executing_proceeding_status(Offence, portugal, statute_barred).

%% Article 12(1)(f) - Fully implemented
% The requested person has been finally judged by a third State in respect of the same acts provided that, where there has been sentence, the sentence has been served or is currently being served or may no longer be executed under the law of the sentencing State;

optional_refusal(article12_1_f, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    person_event(PersonId, irrevocably_convicted_in_third_state, Offence),
    sentence_served_being_served_or_execution_impossible(PersonId).

%% Article 12(1)(g) - Fully implemented
% The arrest warrant has been issued for the purposes of execution of a custodial sentence or detention order, where the requested person is staying in the national territory, has the Portuguese nationality or resides in Portugal and the Portuguese State undertakes to execute the sentence or detention order in accordance with the Portuguese law;

optional_refusal(article12_1_g, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    (
        executing_proceeding(portugal, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(portugal, PersonId, execution_detention_order)
    ),
    (
        person_nationality(PersonId, portugal)
    ;   person_residence(PersonId, portugal)
    ).

%%Article 12(1)(h) - Fully implemented
% The European arrest warrant relates to offences which:

%% Article 12(1)(h)(i) - Fully implemented
% Are regarded by the Portuguese law as having been committed in whole or in part in the national territory or aboard Portuguese ships and aircrafts; or

optional_refusal(article12_1_h_i, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    crime_type(Offence, committed_in(portugal)).

%% Article 12(1)(h)(ii) - Fully implemented
% Have been committed outside the territory of the issuing Member State, provided that the Portuguese criminal law is not applicable to the same offences when committed outside the national territory.

optional_refusal(article12_1_h_ii, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    \+ crime_type(Offence, committed_in(IssuingMemberState)),
    prosecution_not_allowed(Offence, portugal).

%% Article 12-A(1) - Fully implemented
% The execution of a European arrest warrant issued for the purpose of executing a custodial sentence or detention order can be refused if the person did not appear in person at the trial resulting in the decision, unless the European arrest warrant states that the person, in accordance with the national legislation of the issuing Member State:

optional_refusal(article12_a_1, portugal, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, portugal, Offence),
    (
        executing_proceeding(portugal, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(portugal, PersonId, execution_detention_order)
    ),
    issuing_proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    \+ exception(optional_refusal(article12_a_1, portugal, europeanArrestWarrant), _).

%% Article 12-A(1)(a) - Fully implemented
% Was summoned in person and thereby informed of the scheduled date and place of the trial which resulted in the decision, or by other means actually received official information of the scheduled date and place of that trial in such a manner that it was unequivocally established that he or she was aware of the scheduled trial and that a decision could be handed down if he or she did not appear for the trial; or
    
exception(optional_refusaloptional_refusal(article12_a_1, portugal, europeanArrestWarrant), article12_a_1_a):-
    person_event(PersonId, aware_trial, Offence),
    person_event(PersonId, informed_decision, Offence).
%person_event(PersonId, aware_trial, Offence) IF informed date and place or summoned in person?

%% Article 12-A(1)(b) - Fully implemented
% Being aware of the scheduled trial, had given a mandate to a legal counsellor, who was either appointed by the person concerned or by the State, to defend him or her at the trial, and was indeed defended by that counsellor at the trial; or

exception(optional_refusaloptional_refusal(article12_a_1, portugal, europeanArrestWarrant), article12_a_1_b):-
    person_event(PersonId, mandated_legal_defence, Offence).

%% Article 12-A(1)(c) - Fully implemented
% After being served with the decision and expressly informed about the right to a retrial or to an appeal which allows for the re-examination of the merits of the case, including fresh evidence, and which may lead to a different decision from the initial one, expressly stated that he or she does not contest the decision or did not request a retrial or appeal within the applicable time frame; or

exception(optional_refusaloptional_refusal(article12_a_1, portugal, europeanArrestWarrant), article12_a_1_c):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_contest_decision, Offence).

    exception(optional_refusaloptional_refusal(article12_a_1, portugal, europeanArrestWarrant), article12_a_1_c):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_request_retrial_appeal, Offence).

%% Article 12-A(1)(d) - Fully implemented
% Was not personally served with the decision but, following his or her surrender to the issuing Member State, is immediately and expressly informed of his or her right to a retrial or to an appeal which allows for the re-examination of the merits of the case, including fresh evidence, and which may lead to a different decision from the initial one, as well as respective time frames.

exception(optional_refusaloptional_refusal(article12_a_1, portugal, europeanArrestWarrant), article12_a_1_d):-
    person_event(PersonId, not_personally_served_decision, Offence),
    person_event(PersonId, will_informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, will_informed_of_timeframe_retrial_appeal, Offence).
