:- include('../utils.pl').

eio_matter(IssuingMemberState, ExecutingMemberState, Measure):-
    issuing_member_state(IssuingMemberState),
    executing_member_state(ExecutingMemberState),
    issuing_proceeding(IssuingMemberState, _, Measure),
    executing_proceeding(ExecutingMemberState, _, Measure),
    (
        art4_a_applies
    ;   art4_b_applies
    ;   art4_c_applies
    ;   art4_d_applies
    ).

issuing_proceeding(IssuingMemberState, _, Measure):-
    issuing_member_state(IssuingMemberState),
    measure_type(Measure, eio).

executing_proceeding(ExecutingMemberState, _, Measure):-
    executing_member_state(IssuingMemberState),
    measure_type(Measure, eio).



crime_type(Offence, committed_in(CommIn)):-
    offence_type(Offence),
    offence_committed_in(CommIn).

% Fragment of text 1
% 1° If a privilege or immunity is an obstacle to its execution; where such privilege or immunity may be waived by a French authority, recognition and execution of the decision shall be refused only after the Magistrate hearing the case has requested the competent authority without delay to waive the privilege or immunity and it has not been waived; if the French authorities are not competent, the request for waiver shall be left to the issuing State;

mandatory_refusal(article694_31_1, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    contrast_with(Measure, france, immunity_privilege),
    \+ waiver_by_french_authority(Measure).

% Fragment of text 2
% 2° If the request for an investigation is contrary to the provisions relating to the determination of the criminal liability for press offences in the Law of 29 July 1881 on the freedom of the press and Law no. 82-652 of 29 July 1982 on audiovisual communication;

mandatory_refusal(article694_31_2, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    contrast_with(Measure, france, freedom_press).

% Fragment of text 3
% 3° If the decision relates to the transmission of information that has been classified in accordance with the provisions of article 413-9 of the French Criminal Code; in this case, recognition and execution of the decision are refused only after the magistrate to whom the matter has been referred has immediately sent the competent administrative authority a request for declassification and communication of the information in accordance with article L. 2312-4 of the French Defense Code and that this request has not been accepted; if the request for declassification is partially accepted, the recognition and execution of the European Investigation Order may only relate to declassified information;

mandatory_refusal(article694_31_3, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    proceeding_danger(Measure, france, classified_information).

% Fragment of text 4
% 4° If the request concerns proceedings referred to in Article 694-29 of this Code that do not relate to a criminal offence, where the measure requested would not be authorised under French law in the context of similar national proceedings;

mandatory_refusal(article694_31_4, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    \+ relates_to_criminal_offence_articles_694_29,
    national_law_does_not_authorize(france, Measure).

% Fragment of text 5
% 5° If the execution of the investigative decision or the evidence likely to be transferred following its execution could lead to the prosecution or punishment of a person who has already been finally judged, for the acts that are the subject of the decision, by the French judicial authorities or those of another Member State of the European Union when, in the case of a conviction, the sentence has been served, is being served or can no longer be enforced under the laws of the convicting State;

mandatory_refusal(article694_31_5, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    contrary_to_ne_bis_in_idem(france, Measure).

% Fragment of text 6
% 6° If the acts giving rise to the European Investigation Order do not constitute a criminal offence under French law even though they were committed in whole or in part on national territory and there are serious grounds for believing that they were not committed on the territory of the issuing State;

mandatory_refusal(article694_31_6, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_outside_territory),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_inside_executing_ms),
    not_offence(Offence, france).

% Fragment of text 7
% 7° If there are serious grounds for believing that implementation of the investigation measure would be incompatible with France's respect for the rights and freedoms guaranteed by the European Convention for the Protection of Human Rights and Fundamental Freedoms and the Charter of Fundamental Rights of the European Union;

mandatory_refusal(article694_31_7, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    proceeding_danger(Measure, france, incompatible_EU_obligations).

% Fragment of text 8
% 8° If the grounds for the investigation order do not constitute a criminal offence under French law, unless they relate to a category of offences mentioned in Article 694-32 and punished in the issuing State by a custodial sentence or a detention order for a period of at least three years, or unless the measure requested is one of those mentioned in Article 694-33;

mandatory_refusal(article694_31_8, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    not_offence(Offence, france),
    \+ exception(optional_refusal(article11_1_g, france, europeanInvestigationOrder), _).

% Fragment of text 9
% 9° If the measure requested is not authorised by this Code for the offence giving rise to the investigation order, unless it is one of the measures mentioned in Article 694-33.

mandatory_refusal(article694_31_9, france, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, france, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    national_law_does_not_authorize(france, Measure, Offence).