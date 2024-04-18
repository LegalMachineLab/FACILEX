:- include('../utils.pl').

%% REGULATION (EU) 2018/1805 OF THE EUROPEAN PARLIAMENT AND OF THE COUNCIL of 14 November 2018 on the mutual recognition of freezing orders and confiscation orders

%%Article 1

regulation_matter(IssuingMemberState, ExecutingMemberState, europeanConfiscationOrder):-
    issuing_proceeding(IssuingMemberState, Offence, europeanConfiscationOrder),
    executing_proceeding(ExecutingMemberState, Offence, europeanConfiscationOrder).
    

regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder):-
    issuing_proceeding(IssuingMemberState, Offence, europeanFreezingOrder),
    executing_proceeding(ExecutingMemberState, Offence, europeanFreezingOrder).


%% Article 8 
% Grounds for non-recognition and non-execution of freezing orders 
% 1.The executing authority may decide not to recognise or execute a freezing order only where:

%%(a) executing the freezing order would be contrary to the principle of ne bis in idem;

optional_refusal(article8_1_a, ExecutingMemberState, europeanFreezingOrder):-
    regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder),
    contrary_to_ne_bis_in_idem(ExecutingMemberState, europeanFreezingOrder).

%%(b) there is a privilege or immunity under the law of the executing State that would prevent the freezing of the property concerned or there are rules on the determination or limitation of criminal liability that relate to the freedom of the press or the freedom of expression in other media that prevent the execution of the freezing order;

optional_refusal(article8_1_b, ExecutingMemberState, europeanFreezingOrder):-
    regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder),
    freezing_prevented(europeanFreezingOrder, ExecutingMemberState).

freezing_prevented(europeanFreezingOrder, ExecutingMemberState):-
    contrast_with(europeanFreezingOrder, ExecutingMemberState, immunity_privilege).
    
freezing_prevented(europeanFreezingOrder, ExecutingMemberState):-
    contrast_with(europeanFreezingOrder, ExecutingMemberState freedom_press)
;   contrast_with(europeanFreezingOrder, ExecutingMemberState, freedom_expression_media).

%%(c) the freezing certificate is incomplete or manifestly incorrect and has not been completed following the consultation referred to in paragraph 2;

optional_refusal(article8_1_c, ExecutingMemberState, europeanFreezingOrder):-
    regulation_matter(IssuingMemberState, ExecutingMemberState, europeanFreezingOrder),
    \+ issuing_proceeding_status(IssuingMemberState, certificate_incomplete_manifestly_incorrect).
    

%%(d) the freezing order relates to a criminal offence committed, wholly or partially, outside the territory of the issuing State and, wholly or partially, in the territory of the executing State and the conduct in connection with which the freezing order was issued does not constitute a criminal offence under the law of the executing State;

optional_refusal(article8_1_d, ExecutingMemberState, europeanFreezingOrder):-
    proceeding_matter(_, Offence, ExecutingMemberState),
    executing_member_state(_, ExecutingMemberState),
    issuing_member_state(_, IssuingMemberState),
    proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, ExecutingMemberState, not_offence).

optional_refusal(article8_1_d, ExecutingMemberState, europeanFreezingOrder):-
    executing_member_state(_, ExecutingMemberState),
    proceeding_matter(_, Offence, ExecutingMemberState),
    proceeding_status(Offence, ExecutingMemberState, committed_inside_territory),
    proceeding_status(Offence, ExecutingMemberState, not_offence).

%%(e) in a case falling under Article 3(2), the conduct in connection with which the freezing order was issued does not constitute a criminal offence under the law of the executing State; however, in cases that involve taxes or duties or customs and exchange regulations, the recognition or execution of the freezing order shall not be refused on the grounds that the law of the executing State does not impose the same kind of taxes or duties or does not provide for the same type of rules as regards taxes and duties or the same type of customs and exchange regulations as the law of the issuing State;

optional_refusal(article8_1_e, ExecutingMemberState, europeanFreezingOrder):-
    art3_2applies(ExecutingMemberState),
    proceeding_matter(_, Offence, ExecutingMemberState),
    national_law_not_offence(Offence, ExecutingMemberState).

%% (f) in exceptional situations, there are substantial grounds to believe, on the basis of specific and objective evidence, that the execution of the freezing order would, in the particular circumstances of the case, entail a manifest breach of a relevant fundamental right as set out in the Charter, in particular the right to an effective remedy, the right to a fair trial or the right of defence.

optional_refusal(article8_1_f, ExecutingMemberState, europeanFreezingOrder):-
    proceeding_danger(_, ExecutingMemberState, breach_fundamental_rights).

%% 2. In any of the cases referred to in paragraph 1, before deciding not to recognise or execute the freezing order, whether wholly or partially, the executing authority shall consult the issuing authority by any appropriate means and where appropriate, shall request the issuing authority to supply any necessary information without delay.

%% 3. Any decision not to recognise or execute the freezing order shall be taken without delay and notified immediately to the issuing authority by any means capable of producing a written record.

%% 4. Where the executing authority has recognised a freezing order, but it becomes aware, during the execution thereof, that one of the grounds for non-recognition or non-execution applies, it shall immediately contact the issuing authority by any appropriate means in order to discuss the appropriate measures to take. On that basis, the issuing authority may decide to withdraw the freezing order. If, following such discussions, no solution has been reached, the executing authority may decide to stop the execution of the freezing order.

%% Article 19
% Grounds for non-recognition and non-execution of confiscation orders
% 1.   The executing authority may decide not to recognise or execute a confiscation order only where:

%%(a) executing the confiscation order would be contrary to the principle of ne bis in idem;

optional_refusal(article19_1_a, ExecutingMemberState, europeanConfiscationOrder):-
    contrary_to_ne_bis_in_idem(ExecutingMemberState).

%%(b) there is a privilege or immunity under the law of the executing State that would prevent the confiscation of the property concerned or there are rules on the determination or limitation of criminal liability that relate to the freedom of the press or the freedom of expression in other media that prevent the execution of the confiscation order;

optional_refusal(article19_1_b, ExecutingMemberState, europeanConfiscationOrder):-
    executing_member_state(_, ExecutingMemberState),
    proceeding_matter(_, Offence, ExecutingMemberState),
    proceeding_status(Offence, ExecutingMemberState, impossible_freeze_property);
    proceeding_status(Offence, ExecutingMemberState, limitation_criminal_liability).

proceeding_status(Offence, ExecutingMemberState, impossible_freeze_property):-
    proceeding_danger(_, ExecutingMemberState, immunity_privilege).

proceeding_status(Offence, ExecutingMemberState, limitation_criminal_liability):-
    proceeding_danger(_, ExecutingMemberState, freedom_press)
;   proceeding_danger(_, ExecutingMemberState, freedom_expression_media).

%%(c) the confiscation certificate is incomplete or manifestly incorrect and has not been completed following the consultation referred to in paragraph 2;

optional_refusal(article19_1_c, ExecutingMemberState, europeanConfiscationOrder):-
   proceeding_status(Offence, ExecutingMemberState, certificate_incomplete_manifestly_incorrect).

%%(d) the confiscation order relates to a criminal offence committed, wholly or partially, outside the territory of the issuing State and, wholly or partially, in the territory of the executing State and the conduct in connection with which the confiscation order was issued does not constitute a criminal offence under the law of the executing State;

optional_refusal(article19_1_d, ExecutingMemberState, europeanConfiscationOrder):-
    proceeding_matter(_, Offence, ExecutingMemberState),
    executing_member_state(_, ExecutingMemberState),
    issuing_member_state(_, IssuingMemberState),
    proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, ExecutingMemberState, not_offence).

optional_refusal(article19_1_d, ExecutingMemberState, europeanConfiscationOrder):-
    executing_member_state(_, ExecutingMemberState),
    proceeding_matter(_, Offence, ExecutingMemberState),
    proceeding_status(Offence, ExecutingMemberState, committed_inside_territory),
    proceeding_status(Offence, ExecutingMemberState, not_offence).

%%(e) the rights of affected persons would make it impossible under the law of the executing State to execute the confiscation order, including where that impossibility is a consequence of the application of legal remedies in accordance with Article 33;

optional_refusal(article19_1_e, ExecutingMemberState, europeanConfiscationOrder):-
    executing_member_state(_, ExecutingMemberState),
    proceeding_matter(_, Offence, ExecutingMemberState),
    proceeding_status(Offence, ExecutingMemberState, rights_person_impossible_execute_eco).

%%(f) in a case falling under Article 3(2), the conduct in connection with which the confiscation order was issued does not constitute a criminal offence under the law of the executing State; however, in cases that involve taxes or duties or customs and exchange regulations, the recognition or execution of the confiscation order shall not be refused on the grounds that the law of the executing State does not impose the same kind of taxes or duties or does not provide for the same type of rules as regards taxes and duties or the same type of customs and exchange regulations as the law of the issuing State;

optional_refusal(article19_1_f, ExecutingMemberState, europeanConfiscationOrder):-
    art3_2applies(ExecutingMemberState),
    proceeding_matter(_, Offence, ExecutingMemberState),
    national_law_not_offence(Offence, ExecutingMemberState).

%%(g) according to the confiscation certificate, the person against whom the confiscation order was issued did not appear in person at the trial that resulted in the confiscation order linked to a final conviction, unless the confiscation certificate states that, in accordance with further procedural requirements defined in the law of the issuing State, the person:

optional_refusal(article19_1_g, ExecutingMemberState, europeanConfiscationOrder):-
    person_role(PersonId, subject_confiscation_order),
    executing_member_state(PersonId, ExecutingMemberState),
    proceeding_status(Offence, IssuingMemberState, trial_in_absentia),
    issuing_member_state(PersonId, IssuingMemberState),
    \+ exception(optional_refusal(article19_1_g, ExecutingMemberState, europeanConfiscationOrder), _).

%%(i) was summoned in person in due time and was thereby informed of the scheduled date and place of the trial that resulted in the confiscation order, or actually received, by other means, official information of the scheduled date and place of that trial in such a manner that it was established unequivocally that that person was aware of the scheduled trial, and was informed in due time that such a confiscation order could be handed down if that person did not appear at the trial;

exception(optional_refusal(article19_1_g, ExecutingMemberState, europeanConfiscationOrder), article19_1_g_i):-
    person_event(PersonId, aware_trial, Offence),
    person_event(PersonId, informed_decision, Offence).

%%(ii) being aware of the scheduled trial, had given a mandate to a lawyer, who was either appointed by the person concerned or by the State, to defend that person at the trial and was actually defended by that lawyer at the trial; or

exception(optional_refusal(article19_1_g, ExecutingMemberState, europeanConfiscationOrder), article19_1_g_ii):-
    person_event(PersonId, presence_legal_defence, Offence).

%%(iii) after having been served with the confiscation order and having been expressly informed of the right to a retrial or an appeal, in which the person would have the right to participate and which would allow a re-examination of the merits of the case including an examination of fresh evidence, and which could lead to the original confiscation order being reversed, expressly stated that he or she did not contest the confiscation order, or did not request a retrial or appeal within the applicable time limits;

exception(optional_refusal(article19_1_g, ExecutingMemberState, europeanConfiscationOrder), article19_1_g_iii):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_contest_decision, Offence).

exception(optional_refusal(article19_1_g, ExecutingMemberState, europeanConfiscationOrder), article19_1_g_iii):-
    person_event(PersonId, informed_of_right_retrial_appeal, Offence),
    person_event(PersonId, does_not_request_retrial_appeal, Offence).

%%(h) in exceptional situations, there are substantial grounds to believe, on the basis of specific and objective evidence, that the execution of the confiscation order would, in the particular circumstances of the case, entail a manifest breach of a relevant fundamental right as set out in the Charter, in particular the right to an effective remedy, the right to a fair trial or the right of defence.

optional_refusal(article19_1_h, ExecutingMemberState, europeanConfiscationOrder):-
    proceeding_danger(_, ExecutingMemberState, breach_fundamental_rights).

%%2. In any of the cases referred to in paragraph 1, before deciding not to recognise or execute the confiscation order, whether wholly or partially, the executing authority shall consult the issuing authority by any appropriate means and, where appropriate, shall request the issuing authority to supply any necessary information without delay.

%%3. Any decision not to recognise or execute the confiscation order shall be taken without delay and notified immediately to the issuing authority by any means capable of producing a written record.