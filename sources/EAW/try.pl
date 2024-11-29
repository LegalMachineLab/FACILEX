:- include('../utils.pl').

%%Decision 2002/584
%%Council Framework Decision of 13 June 2002 on the European arrest warrant and the surrender procedures between Member States (2002/584/JHA)

%%Articles 1-2
%1. The European arrest warrant is a judicial decision issued by a Member State with a view to the arrest and surrender by another Member State of a requested person, for the purposes of conducting a criminal prosecution or executing a custodial sentence or detention order.

eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence):-
    issuing_proceeding(IssuingMemberState, _, PersonId),
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

issuing_proceeding(IssuingMemberState, _, PersonId):-
    issuing_member_state(IssuingMemberState),
    person_role(PersonId, subject_eaw).

executing_proceeding(ExecutingMemberState, PersonId, Purpose):-
    executing_member_state(ExecutingMemberState),
    executing_proceeding_purpose(PersonId, Purpose),
    member(Purpose, [criminal_prosecution, execution_custodial_sentence, execution_detention_order]),
    person_role(PersonId, subject_eaw).


art2_4applies(Offence):-
    \+ art2_2applies(Offence).

crime_type(Offence, committed_in(CommIn)):-
    offence_type(Offence),
    offence_committed_in(CommIn).

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
    person_event(PersonId, under_prosecution, Offence). 

%3. where the judicial authorities of the executing Member State have decided either not to prosecute for the offence on which the European arrest warrant is based or to halt proceedings, or where a final judgment has been passed upon the requested person in a Member State, in respect of the same acts, which prevents further proceedings;

optional_refusal(article4_3, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    (
        executing_proceeding_status(Offence, ExecutingMemberState, non_prosecution_or_halted_proceeding)
%    ;   executing_proceeding_status(Offence, ExecutingMemberState, halted)
    ;   person_event(PersonId, finally_judged, Offence)
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
    sentence_served_being_served_or_execution_impossible(PersonId).

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
    ;   person_residence(PersonId, ExecutingMemberState)
    ).


%7. where the European arrest warrant relates to offences which:
%(a) are regarded by the law of the executing Member State as having been committed in whole or in part in the territory of the executing Member State or in a place treated as such; or

optional_refusal(article4_7_a, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, _, ExecutingMemberState, Offence),
    crime_type(Offence, committed_in(ExecutingMemberState)).


%(b) have been committed outside the territory of the issuing Member State and the law of the executing Member State does not allow prosecution for the same offences when committed outside its territory.

optional_refusal(article4_7_b, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    \+ crime_type(Offence, committed_in(IssuingMemberState)),
    prosecution_not_allowed(Offence, ExecutingMemberState).


%%Article 4a
%Decisions rendered following a trial at which the person did not appear in person

%1. The executing judicial authority may also refuse to execute the European arrest warrant issued for the purpose of executing a custodial sentence or a detention order if the person did not appear in person at the trial resulting in the decision, unless the European arrest warrant states that the person, in accordance with further procedural requirements defined in the national law of the issuing Member State:

optional_refusal(article4a_1, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
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
    issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
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
    \+ issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, will_informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, will_informed_of_timeframe_retrial_appeal).

%2. In case the European arrest warrant is issued for the purpose of executing a custodial sentence or detention order under the conditions of paragraph 1(d) and the person concerned has not previously received any official information about the existence of the criminal proceedings against him or her, he or she may, when being informed about the content of the European arrest warrant, request to receive a copy of the judgment before being surrendered. Immediately after having been informed about the request, the issuing authority shall provide the copy of the judgment via the executing authority to the person sought. The request of the person sought shall neither delay the surrender procedure nor delay the decision to execute the European arrest warrant. The provision of the judgment to the person concerned is for information purposes only; it shall neither be regarded as a formal service of the judgment nor actuate any time limits applicable for requesting a retrial or appeal.

%3. In case a person is surrendered under the conditions of paragraph (1)(d) and he or she has requested a retrial or appeal, the detention of that person awaiting such retrial or appeal shall, until these proceedings are finalised, be reviewed in accordance with the law of the issuing Member State, either on a regular basis or upon request of the person concerned. Such a review shall in particular include the possibility of suspension or interruption of the detention. The retrial or appeal shall begin within due time after the surrender.

%%Article 5
%Guarantees to be given by the issuing Member State in particular cases
%The execution of the European arrest warrant by the executing judicial authority may, by the law of the executing Member State, be subject to the following conditions:

%2. if the offence on the basis of which the European arrest warrant has been issued is punishable by custodial life sentence or life-time detention order, the execution of the said arrest warrant may be subject to the condition that the issuing Member State has provisions in its legal system for a review of the penalty or measure imposed, on request or at the latest after 20 years, or for the application of measures of clemency to which the person is entitled to apply for under the law or practice of the issuing Member State, aiming at a non-execution of such penalty or measure;

optional_refusal(article5_2, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    punishable_by_life_sentence(Offence, IssuingMemberState),
    \+ guarantee(IssuingMemberState, review_clemency_right).


%3. where a person who is the subject of a European arrest warrant for the purposes of prosecution is a national or resident of the executing Member State, surrender may be subject to the condition that the person, after being heard, is returned to the executing Member State in order to serve there the custodial sentence or detention order passed against him in the issuing Member State.

optional_refusal(article5_3, ExecutingMemberState, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence),
    executing_proceeding(ExecutingMemberState, PersonId, criminal_prosecution),
    (   
        person_nationality(PersonId, ExecutingMemberState)
    ;   person_residence(PersonId, ExecutingMemberState)
    ),
    \+ guarantee(PersonId, Offence, return_to_executing_state).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('../utils.pl').

%% Legge 22 aprile 2005, n. 69
%% Provisions to adapt national legislation to the Council Framework Decision 2002/584/JHA of 13 June 2002 on the European arrest warrant and the surrender procedures between Member States

%% Art. 1
%1.[...]
%2. Il mandato d'arresto europeo è una decisione giudiziaria emessa da uno Stato membro dell'Unione europea, di seguito denominato "Stato membro di emissione", in vista dell'arresto e della consegna da parte di un altro Stato membro, di seguito denominato "Stato membro di esecuzione", di una persona, al fine dell'esercizio di azioni giudiziarie in materia penale o dell'esecuzione di una pena o di una misura di sicurezza privative della libertà personale.


eaw_matter(PersonId, IssuingMemberState, ExecutingMemberState, Offence):-
    issuing_proceeding(IssuingMemberState, _, PersonId),
    (
        art2_2applies(Offence)
    ;   art2_4applies(Offence)
    ),
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



%Article 7(1-2-3-4) - Fully implemented
%   1. Italy shall execute the European arrest warrant only where the act constitutes a criminal offence under national law, irrespective of its legal classification and the single constituent elements of the offence.




%% Article 18(1)(a) - Fully implemented
% The Court of Appeals refuses the surrender in the following cases:
% a) if the offence charged in the European arrest warrant is extinguished by amnesty under Italian law, when there is jurisdiction of the Italian State over the fact

mandatory_refusal(article18_1_a, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    amnesty(Offence, italy).

% b) if it appears that, in respect of the person sought, for the same acts, there has been, in Italy, an irrevocable judgement, or a criminal decree of conviction, or a judgement of no grounds to proceed which is no longer subject to an appeal or, in another Member State of the European Union, a final judgement, provided that, in the case of a conviction, the sentence has already been served or is currently being served, or can no longer be enforced under the laws of the sentencing State

mandatory_refusal(article18_1_b, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    (
        person_event(PersonId, finally_judged, Offence)
    ;   executing_proceeding_status(Offence, italy, criminal_conviction_or_no_grounds_to_proceed)
%    ;   person_event(PersonId, judgement_no_grounds_to_proceed, Offence)
    ).

mandatory_refusal(article18_1_b, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    person_event(PersonId, finally_judged, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

% c) if the person who is the subject of the European arrest warrant was a minor 14 years of age at the time of the commission of the offence.

mandatory_refusal(article18_1_c, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    person_status(PersonId, under_age, italy).

person_status(PersonId, under_age, italy):-
    person_age(PersonId, Age),
    Age =< 14.

%% Article 7(1-2) - Fully implemented
% 1. Italy shall execute the European arrest warrant only where the act constitutes a criminal offence under national law, irrespective of its legal classification and the single constituent elements of the offence.
% 2. For the purposes of paragraph 1, for offences relating to taxes, customs and exchanges, it is not necessary that Italian law imposes the same kind of taxes or duties or contains the same kind of tax, duty, customs and exchange regulations as the law of the issuing Member State.

%Article 8 - Fully implemented
%Compulsory delivery
%1. By way of derogation from Article 7(1), the European arrest warrant shall be executed regardless of double criminality for offenses which, according to the law of the issuing Member State, fall under the categories referred to in Article 2(2) of the Framework Decision and are punishable by a custodial sentence or detention order of three years or more.

mandatory_refusal(article7_1, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    national_law_not_offence(Offence, italy),
    \+ exception(art2_2applies(Offence), article8).

national_law_not_offence(driving_without_license, italy):-
    cassazione(numero_41102_2022, driving_without_license, italia).

%% Article 18bis - Fully implemented
% 1. When the European arrest warrant has been issued for the purpose of prosecution in criminal matters, the Court of Appeal may refuse surrender in the following cases
% (a) if the European arrest warrant concerns offences which under Italian law are regarded as offences committed in whole or in part in its territory, or in a place assimilated to its territory; or offences committed outside the territory of the issuing Member State, if Italian law does not allow criminal prosecution for the same offences committed outside its territory;

optional_refusal(article18bis_1_a, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    crime_type(Offence, committed_in(italy)).
    

optional_refusal(article18bis_1_a, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    \+ crime_type(Offence, committed_in(IssuingMemberState)),
    prosecution_not_allowed(Offence, italy).


%Article 18bis(1)(b) - Fully implemented
% 1. When the European arrest warrant has been issued for the purpose of prosecution in criminal matters, the Court of Appeal may refuse surrender in the following cases
% (b) if criminal proceedings are in progress against the requested person for the same offence as that on which the European arrest warrant is based.

optional_refusal(article18bis_1_b, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    person_event(PersonId, under_prosecution, Offence).

% Article 18(2-2bis) - Fully implemented
% 2. When the European arrest warrant has been issued for the purpose of the execution of a custodial sentence or a security measure, the Court of Appeal may refuse to surrender of the Italian citizen or of a person who lawfully and effectively resides continuously for at least five years on the Italian territory, as long as it also orders that such sentence or security measure be executed in Italy in accordance with its domestic law.

optional_refusal(article18bis_2, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    (
        executing_proceeding(italy, PersonId, execution_custodial_sentence)
    ;   executing_proceeding(italy, PersonId, execution_detention_order)
    ),
    (
        person_nationality(PersonId, italy)
    ;   person_residence(PersonId, italy)
    ).
    
person_residence(PersonId, italy):-
    person_continuous_residence(PersonId, italy, Time),
    Time >= 5,
    residence_status(PersonId, italy, lawful_effective).


% 2-bis. For the purposes of verifying the lawful and effective residence on the Italian territory of the person requested to be surrendered, the Court of Appeal shall ascertain whether the execution of the sentence or of the security measure on the territory is in fact suitable to enhance the person's chances of social reintegration, taking into account: the duration, nature and modalities of residence; the time elapsed between the commission of the offence on the basis of which the European arrest warrant was issued and the beginning of the period of residence; the commission of offences and the regular fulfilment of social security and tax obligation duties during that period; the compliance with national rules on the entry and residence of foreigners, as well the family ties, linguistic, cultural, social, economic or other ties that the person possesses on Italian territory and any other relevant element. The judgment is null and void if it does not contain the specific indication of the elements referred above and the relevant evaluation criteria

residence_status(PersonId, italy, lawful_effective):-
    residence_purpose(PersonId, italy, social_reintegration, article18_2bis).

%% Article 6(1-bis) - Fully implemented
% When it has been issued for the purpose of enforcing a custodial sentence or a detention order involving deprivation of liberty applied following a trial at which the person concerned did not appear in person, the European arrest warrant shall also contain an indication of at least one of the following conditions:

optional_refusal(article61bis, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    (
        proceeding_status(Offence, italy, execution_custodial_sentence)
    ;   proceeding_status(Offence, italy, execution_detention_order)
    ;   proceeding_status(Offence, italy, deprivation_of_liberty)
    ),
    issuing_proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    \+ exception(optional_refusal(article61bis, italy, europeanArrestWarrant), _).

%(a) the person concerned has been summoned in a timely manner in person or in such a way as to guarantee unequivocally that he or she was aware of the time and place of the trial which led to the decision rendered in his or her absence and of the fact that such decision could also have been made in his absence.

exception(optional_refusal(article61bis, italy, europeanArrestWarrant), article61bis_a):-
    issuing_proceeding_event(PersonId, Offence, aware_trial),
    issuing_proceeding_event(PersonId, Offence, informed_of_potential_decision).

%(b) the person concerned, having been informed of the proceedings against him, was represented at the trial resulting in the abovementioned decision by a legal counsellor, either appointed by the person concerned or ex officio.

exception(optional_refusal(article61bis, italy, europeanArrestWarrant), article61bis_b):-
    issuing_proceeding_event(PersonId, Offence, mandated_legal_defence).

%(c) the person concerned, having been served with the decision of which enforcement is sought and informed of the right to a retrial or of the right to appeal, in which he or she has the right to participate and which allows a review of the merits of the decision, as well as by means of the bringing of new evidence, the possibility of its reform, has declared expressly stated that he or she does not contest that decision or did not request the renewal of the trial or lodged an appeal within the prescribed time limit.

exception(optional_refusal(article61bis, italy, europeanArrestWarrant), article61bis_c):-
    issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    (
        issuing_proceeding_event(PersonId, Offence, does_not_contest_decision)
    ;   issuing_proceeding_event(PersonId, Offence, does_not_request_retrial_appeal)
    ).

%(d) the person concerned has not been personally served with the decision, but will receive it personally and without delay after the surrender in the issuing Member State and will be expressly informed either of the right to a retrial or to lodge an appeal, in which he or she has the right to participate and which allows a review on the merits, as well as, including by through the bringing of new evidence, the possibility of a reform of that decision, and of the time-limits within which he may request a new trial or lodge an appeal for the appeal.

exception(optional_refusal(article61bis, _, europeanArrestWarrant), article61bis_d):-
    \+ issuing_proceeding_event(PersonId, Offence, informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, will_informed_of_right_retrial_appeal),
    issuing_proceeding_event(PersonId, Offence, will_informed_of_timeframe_retrial_appeal).

%% Article 18-ter - Fully implemented
% 1. When the European arrest warrant has been issued for the purpose of the execution of a custodial sentence or a detention order imposed as a result of a trial at which the person concerned did not appear in person, the court of appeal may also refuse surrender if the European arrest warrant does not contain the indication of any of the conditions set out in Article 6(1a) and the issuing State has not indicated any such conditions even following a request made pursuant to Article 16.
% 2. In the cases referred to in paragraph 1, the court of appeal may, however, give rise to surrender if it is proved with certainty that the person concerned had knowledge of the trial or that he or she has voluntarily evaded knowledge of the trial.
% 3. When the conditions set out in Article 6(1-bis, letter (d) are fulfilled the person whose surrender is requested who has not previously been informed of the criminal proceedings held against him/her, may request the transmission of a copy of the judgment on which the European arrest warrant is based. The request shall not, under any circumstances, constitute grounds for postponing the surrender procedure or the decision to execute the European arrest warrant. The court of appeal shall immediately forward of the request to the issuing authority.

% TODO

%% Article 19(1) - Fully implemented
% If the offence on the basis of which the European arrest warrant has been issued is punishable by a custodial sentence or a security measure for life, execution of the warrant shall be subject to the condition that the issuing Member State makes provision in its law for review of the sentence imposed, on an application or after a maximum of twenty years, or for the application of measures of clemency to which the person is entitled under the law or practice of the issuing Member State, so that the sentence or security measure is not executed.

optional_refusal(article19_1, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    punishable_by_life_sentence(Offence, IssuingMemberState),
    \+ guarantee(IssuingMemberState, review_clemency_right).

%% Article 19(2) - Fully implemented
% If the European arrest warrant has been issued for the purpose of prosecuting an Italian citizen or a person who has been lawfully and effectively residing continuously for at least five years in the Italian territory, the execution of the warrant may be subject to the condition that the person, after having been tried, is returned to the Italian State to serve there the custodial sentence or detention order which may have been imposed on him in the issuing Member State. The provisions of Article 18-bis, paragraph 2-bis shall apply.

optional_refusal(article19_2, italy, europeanArrestWarrant):-
    eaw_matter(PersonId, IssuingMemberState, italy, Offence),
    executing_proceeding(italy, PersonId, criminal_prosecution),
    (
        person_citizenship(PersonId, italian)
    ;   (
            person_continuous_residence(PersonId, italy, Time),
            Time >= 5,
            residence_status(PersonId, italy, lawful_effective)
        )
    ),
    \+ guarantee(PersonId, Offence, return_to_executing_state).


% TODO - prosecution important? processuale vs esecuzione pena? sentenza 43252/23?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


offence_type(theft).
art2_4applies(theft).
executing_proceeding_purpose(mario, criminal_prosecution).
issuing_member_state(france).
person_role(mario, subject_eaw).
executing_member_state(italy).
person_age(mario, 18).
offence_committed_in(france).
person_nationality(mario, france).

person_event(mario, finally_judged, theft).
sentence_served(mario).
