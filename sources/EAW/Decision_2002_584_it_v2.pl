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