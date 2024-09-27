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

% Article 22(1)(a)
%The conduct for which the EIO has been issued does not constitute a criminal offence or an offence of a different character under the law of the executing State, unless it concerns an offence listed within the categories of offences set out in Annex IV of this Statute, of which it forms an integral part, and provided that it is punishable in the issuing State by a penalty or a security measure consisting of deprivation of liberty for a maximum period of at least three years, as indicated by the issuing authority in the EIO.

optional_refusal(article22_1_a, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    not_offence(Offence, ExecutingMemberState),
    \+ exception(optional_refusal(article22_1_a, ExecutingMemberState, europeanInvestigationOrder), _).

% Article 22(1)(b)
%The execution of the EIO is impossible because there is a secret, immunity or privilege under the national law of the executing State or there are rules on determination and limitation of criminal liability relating to freedom of the press and freedom of expression in other media.

optional_refusal(article22_1_b, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    eio_execution_impossible(Measure, ExecutingMemberState).

eio_execution_impossible(Measure, ExecutingMemberState):-
    contrast_with(Measure, ExecutingMemberState, immunity_privilege).

eio_execution_impossible(Measure, ExecutingMemberState):-
    contrast_with(Measure, ExecutingMemberState freedom_press)
;   contrast_with(Measure, ExecutingMemberState, freedom_expression_media).

% Article 22(1)(c)
%The execution of the EIO may harm to essential national security interests, jeopardise the source of the information or involve the use of classified information relating to specific intelligence activities.

optional_refusal(article22_1_c, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
    proceeding_danger(Measure, ExecutingMemberState, national_security);
    proceeding_danger(Measure, ExecutingMemberState, jeopardise_source_information);
    proceeding_danger(Measure, ExecutingMemberState, classified_information)
    ).

% Article 22(1)(d)
%The EIO has been issued in the context of proceedings referred to in Article 5(b) and (c) and the investigative measure would not be admitted in similar domestic proceedings.

optional_refusal(article22_1_d, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
        art4_b_applies
    ;   art4_c_applies
    ),
    national_law_does_not_authorize(ExecutingMemberState, Measure).

% Article 22(1)(e)
%The execution of the EIO is contrary to the principle of ne bis in idem.

optional_refusal(article22_1_e, MemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    contrary_to_ne_bis_in_idem(ExecutingMemberState, Measure).

% Article 22(1)(f)
%The EIO relates to a criminal offence which is alleged to have been committed outside the territory of the issuing State and wholly or partially on the territory of the executing State, and the conduct that caused the issuing of the EIO does not constitute an offence in the executing State.

optional_refusal(article22_1_f, MemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_outside_territory),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_inside_executing_ms),
    not_offence(Offence, ExecutingMemberState).

% Article 22(1)(g)
%There are substantial grounds to believe that the execution of the indicated investigative measure is incompatible with the executing State's obligations in accordance with Article 6 TEU and the Charter of Fundamental Rights of the European Union.

optional_refusal(article22_1_g, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    proceeding_danger(Measure, ExecutingMemberState, incompatible_EU_obligations).

% Article 22(1)(h)
%The investigative measure at issue is only admissible under the law of the executing State for offences sanctioned with penalties that meet certain thresholds or for certain categories of offences that do not include the offence covered by the EIO.

optional_refusal(article22_1_h, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    national_law_does_not_authorize(ExecutingMemberState, Measure, Offence).

optional_refusal(article188, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, interception_of_telecommunications),
    national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications).

national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications):-
    \+ authority_decision(interception_of_telecommunications, investigating_magistrate, ExecutingMemberState).