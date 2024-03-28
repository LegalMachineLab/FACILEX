:- include('../utils.pl').

%%DIRECTIVES DIRECTIVE 2014/41/EU OF THE EUROPEAN PARLIAMENT AND OF THE COUNCIL of 3 April 2014 regarding the European Investigation Order in criminal matters

%Article 11

%%Grounds for non-recognition or non-execution 

%%1.Without prejudice to Article 1(4), recognition or execution of an EIO may be refused in the executing State where: (a) there is an immunity or a privilege under the law of the executing State which makes it impossible to execute the EIO or there are rules on determination and limitation of criminal liability relating to freedom of the press and freedom of expression in other media, which make it impossible to execute the EIO;

optional_refusal(article11_1_a, MemberState, europeanInvestigationOrder):-
    executing_member_state(_, MemberState),
    proceeding_matter(_, Offence, MemberState),
    proceeding_status(Offence, MemberState, impossible_execute_eio);
    proceeding_status(Offence, MemberState, limitation_criminal_liability).

proceeding_status(Offence, MemberState, impossible_execute_eio):-
    proceeding_danger(_, MemberState, immunity_privilege).

proceeding_status(Offence, MemberState, limitation_criminal_liability):-
        proceeding_danger(_, MemberState, freedom_press)
    ;   proceeding_danger(_, MemberState, freedom_expression_media).

%%(b) in a specific case the execution of the EIO would harm essential national security interests, jeopardise the source of the information or involve the use of classified information relating to specific intelligence activities;

optional_refusal(article11_1_b, MemberState, europeanInvestigationOrder):-
    proceeding_danger(_, MemberState, national_security);
    proceeding_danger(_, MemberState, jeopardise_source_information);
    proceeding_danger(_, MemberState, classified_information_intelligence).

%%(c) the EIO has been issued in proceedings referred to in Article 4(b) and (c) and the investigative measure would not be authorised under the law of the executing State in a similar domestic case;

optional_refusal(article11_1_c, MemberState, europeanInvestigationOrder):-
    article4applies(MemberState),
    national_law_does_not_authorize(MemberState).

%%(d) the execution of the EIO would be contrary to the principle of ne bis in idem;

optional_refusal(article11_1_d, MemberState, europeanInvestigationOrder):-
    contrary_to_ne_bis_in_idem(MemberState).

%% (e) the EIO relates to a criminal offence which is alleged to have been committed outside the territory of the issuing State and wholly or partially on the territory of the executing State, and the conduct in connection with which the EIO is issued is not an offence in the executing State;

optional_refusal(article11_1_e, MemberState, europeanInvestigationOrder):-
    proceeding_matter(_, Offence, MemberState),
    executing_member_state(_, MemberState),
    issuing_member_state(_, IssuingMemberState),
    proceeding_status(Offence, IssuingMemberState, committed_outside_territory),
    proceeding_status(Offence, MemberState, not_offence).

optional_refusal(article11_1_e, MemberState, europeanInvestigationOrder):-
    executing_member_state(_, MemberState),
    proceeding_matter(_, Offence, MemberState),
    proceeding_status(Offence, MemberState, committed_inside_territory),
    proceeding_status(Offence, MemberState, not_offence).

%% (f) there are substantial grounds to believe that the execution of the investigative measure indicated in the EIO would be incompatible with the executing State's obligations in accordance with Article 6 TEU and the Charter;

optional_refusal(article11_1_f, MemberState, europeanInvestigationOrder):-
    proceeding_danger(_, MemberState, incompatible_executing_obligations).

%% (g) the conduct for which the EIO has been issued does not constitute an offence under the law of the executing State, unless it concerns an offence listed within the categories of offences set out in Annex D, as indicated by the issuing authority in the EIO, if it is punishable in the issuing State by a custodial sentence or a detention order for a maximum period of at least three years; or

optional_refusal(article11_1_g, MemberState, europeanInvestigationOrder):-
    proceeding_matter(_, Offence, MemberState),
    national_law_not_offence(Offence, MemberState),
    \+ exception(optional_refusal(article11_1_g, MemberState, europeanInvestigationOrder), _).

%% (h) the use of the investigative measure indicated in the EIO is restricted under the law of the executing State to a list or category of offences or to offences punishable by a certain threshold, which does not include the offence covered by the EIO.

optional_refusal(article11_1_h, MemberState, europeanInvestigationOrder):-
    proceeding_matter(_, Offence, MemberState),
    proceeding_status(Offence, MemberState, restricted_treshold),
    \+ exception(optional_refusal(article11_1_h, MemberState, europeanInvestigationOrder), _).

%% 2.   Paragraphs 1(g) and 1(h) do not apply to investigative measures referred to in Article 10(2).
exception(optional_refusal(article11_1_g, MemberState, europeanInvestigationOrder), article11_2):-
    article10_2Applies(MemberState).
exception(optional_refusal(article11_1_h, MemberState, europeanInvestigationOrder), article11_2):-
    article10_2Applies(MemberState).

%% 3. Where the EIO concerns an offence in connection with taxes or duties, customs and exchange, the executing authority shall not refuse recognition or execution on the ground that the law of the executing State does not impose the same kind of tax or duty or does not contain a tax, duty, customs and exchange regulation of the same kind as the law of the issuing State.

%TODO - Everything shall not apply if tax or etc.?

%% 4. In the cases referred to in points (a), (b), (d), (e) and (f) of paragraph 1 before deciding not to recognise or not to execute an EIO, either in whole or in part the executing authority shall consult the issuing authority, by any appropriate means, and shall, where appropriate, request the issuing authority to supply any necessary information without delay.

%% 5. In the case referred to in paragraph 1(a) and where power to waive the privilege or immunity lies with an authority of the executing State, the executing authority shall request it to exercise that power forthwith. Where power to waive the privilege or immunity lies with an authority of another State or international organisation, it shall be for the issuing authority to request the authority concerned to exercise that power.