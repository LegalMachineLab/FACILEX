TODO questions
-aggiungere stati
-aggiungere reati
(person_event)
    has the person been finally judged
    is the person under prosecution in the executing MS for the same acts
    irrevocably convicted in third state not MS
exceptions!!!
    PL:
        asylum request
        no consent to surrender
(executing_proceeding_status)    
    decision not to prosecute
    decision to halt proceedings
    prosecution or punishment is statute barred
    



## EIO
(contrast_with)
    there is an immunity or a privilege
    freedom of the press
    freedom of expression in other media
(proceeding_danger)
    harm essential national security interests
    jeopardise the source of the information
    involve the use of classified information
    incompatible_EU_obligations
(national_law_does_not_authorize)
    national law does not authorize the use
contrary_to_ne_bis_in_idem
not_offence(c'è crime_recognised dentro EAW)


## EAW
- amnesty(Offence, ExecutingMemberState)
- person_event(PersonId, _, Offence):
    - finally_judged
    [*the requested person has been finally judged by a Member State in respect of the same acts*]
    - under_prosecution
    [*the person who is the subject of the European arrest warrant is being prosecuted in the Executing Member State for the same act*]
    - irrevocably_convicted_in_third_state
    [*the requested person has been finally judged by a third State in respect of the same acts*]

- sentence_served(PersonId)[*the sentence has been served*]
- sentence_being_served(PersonId)[*is currently being served*]
- sentence_execution_impossible(PersonId) [*may no longer be executed under the law of the sentencing Member State*]

- person_age(PersonId, Age)
- national_law_not_offence(Offence, ExecutingMemberState)[*the act on which the European arrest warrant is based does not constitute an offence under the law of the executing Member State*]


- executing_proceeding_status(Offence, ExecutingMemberState, statute_barred) [*where the criminal prosecution or punishment of the requested person is statute-barred according to the law of the executing Member State*]

- person_nationality(PersonId, ExecutingMemberState)
- person_residence(PersonId, ExecutingMemberState)

CONDITION 4_6: [*that State undertakes to execute the sentence or detention order in accordance with its domestic law*]

- prosecution_not_allowed(Offence, ExecutingMemberState)
[*the law of the executing Member State does not allow prosecution for the same offences when committed outside its territory*]

- issuing_proceeding_status(Offence, IssuingMemberState, trial_in_absentia) [*if the person did not appear in person at the trial resulting in the decision*]

- issuing_proceeding_event(PersonId, Offence, _):
    - aware_trial
    - informed_of_potential_decision [*was informed that a decision may be handed down if he or she does not appear for the trial*]
    - mandated_legal_defence[*had given a mandate to a legal counsellor, who was either appointed by the person concerned or by the State, to defend him or her at the trial, and was indeed defended by that counsellor at the trial;*]
    - informed_of_right_retrial_appeal [*being expressly informed about the right to a retrial*]
    - does_not_contest_decision [*expressly stated that he or she does not contest the decision*]
    - does_not_request_retrial_appeal [*did not request a retrial or appeal within the applicable time frame*]
    - not_personally_served_decision [*was not personally served with the decision*]
    - will_informed_of_right_retrial_appeal [*will be personally served with it without delay after the surrender and will be expressly informed of his or her right to a retrial, or an appeal, in which the person has the right to participate and which allows the merits of the case, including fresh evidence, to be re-examined, and which may lead to the original decision being reversed*]
    - will_informed_of_timeframe_retrial_appeal [* will be informed of the time frame within which he or she has to request such a retrial or appeal*]

- punishable_by_life_sentence(Offence, IssuingMemberState)
[*the offence on the basis of which the European arrest warrant has been issued is punishable by custodial life sentence or life-time detention order*]

- guarantee(IssuingMemberState, review_clemency_right)
CONDITION 5_2: *subject to the condition that the issuing Member State has provisions in its legal system for a review of the penalty or measure imposed, on request or at the latest after 20 years, or for the application of measures of clemency to which the person is entitled to apply for under the law or practice of the issuing Member State, aiming at a non-execution of such penalty or measure*

- guarantee(PersonId, Offence, return_to_executing_state)
CONDITION 5_3: *the condition that the person, after being heard, is returned to the executing Member State in order to serve there the custodial sentence or detention order passed against him in the issuing Member State.*

## Eaw national laws
- executing_proceeding_status(Offence, ExecutingMemberState, terminated)
[*the offence on the basis of which the warrant is issued has been terminated in the Republic of Bulgaria before reception of the said warrant*;
*the French courts have decided not to institute proceedings or to terminate proceedings*]

Possibile domanda: [*did the authorities of the executing state decided  not to institute proceedings or to terminate proceedings??*]

## Eaw Italy



- person_continuous_residence(PersonId, italy, Time) [* the Court of Appeal may refuse to surrender of the Italian citizen or of a person who lawfully and effectively resides continuously for at least five years on the Italian territory*]
- residence_purpose(PersonId, italy, social_reintegration, article18_2bis) 
CONDITION 18bis_2bis: *the Court of Appeal shall ascertain whether the execution of the sentence or of the security measure on the territory is in fact suitable to enhance the person's chances of social reintegration, taking into account: the duration, nature and modalities of residence; the time elapsed between the commission of the offence on the basis of which the European arrest warrant was issued and the beginning of the period of residence; the commission of offences and the regular fulfilment of social security and tax obligation duties during that period; the compliance with national rules on the entry and residence of foreigners, as well the family ties, linguistic, cultural, social, economic or other ties that the person possesses on Italian territory and any other relevant element. The judgment is null and void if it does not contain the specific indication of the elements referred above and the relevant evaluation criteria*
