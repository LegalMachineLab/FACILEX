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

% Article 589zj(1)

% 1) the court or prosecutor has not obtained the required authorization to carry out the activities with the participation of the person indicated in the EIO;
mandatory_refusal(article589zj_1_1, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    required_authorization_not_obtained(ExecutingMemberState, PersonId, europeanInvestigationOrder).

% 2) a final judgment has been rendered against the prosecuted person in a member state of the European Union for the same acts indicated in the EIO, and, if convicted of the same acts, the prosecuted person is serving a sentence or has served it, or the sentence cannot be enforced according to the law of the state where the conviction was rendered;
mandatory_refusal(article589zj_1_2, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    person_event(PersonId, finally_judged, Offence),
    (
        sentence_served(PersonId)
    ;   sentence_being_served(PersonId)
    ;   sentence_execution_impossible(PersonId) 
    ).

% 4) the EIO concerns an interrogation in circumstances covered by an absolute prohibition of interrogation;
mandatory_refusal(article589zj_1_4, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    contrast_with(Measure, ExecutingMemberState, prohibition_of_interrogation).

% 5) the execution of the EIO would violate human and civil liberties and rights;
mandatory_refusal(article589zj_1_5, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    proceeding_danger(Measure, ExecutingMemberState, human_rights).

% 6) the requested measure would threaten national security;
mandatory_refusal(article589zj_1_6, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    proceeding_danger(Measure, ExecutingMemberState, national_security).

% Article 589zj(2) - Fully implemented
% 1) the act giving rise to the issuance of the EIO, other than those listed in Article 607w CCP, does not constitute a crime under Polish law;
optional_refusal(article589zj_2_1, ExecutingMemberState, europeanInvestigationOrder):-
    eio_atter(IssuingMemberState, ExecutingMemberState, Measure),
    not_offence(Offence, ExecutingMemberState).

% 2) the act giving rise to the issuance of the EIO under Polish law was committed in whole or in part on the territory of the Republic of Poland or on a Polish ship or aircraft and does not constitute an offense under Polish law;
optional_refusal(article589zj_2_2, ExecutingMemberState, europeanInvestigationOrder):-
    eio_atter(IssuingMemberState, ExecutingMemberState, Measure),
    crime_type(Offence, committed_in(ExecutingMemberState)),
    not_offence(Offence, poland).

% 3) the execution of the EIO would involve the disclosure of classified information obtained in the course of covert activities, as well as related to the conduct of these activities;
optional_refusal(article589zj_2_3, ExecutingMemberState, europeanInvestigationOrder):-
    eio_atter(IssuingMemberState, ExecutingMemberState, Measure),
    proceeding_danger(Measure, ExecutingMemberState, classified_information).

% 4) according to Polish law, the investigative activity to which the EIO relates cannot be carried out in the case of the crime that is the basis for its issuance;
%optional_refusal(article589zj_2_4, ExecutingMemberState, europeanInvestigationOrder):-
%    eio_atter(IssuingMemberState, ExecutingMemberState, Measure),
%    national_law_does_not_authorize(ExecutingMemberState, Measure, Offence).
% TODO 


% 5) according to Polish law, the investigative measure covered by the EIO cannot be carried out in the proceedings in which it was issued;
optional_refusal(article589zj_2_5, ExecutingMemberState, europeanInvestigationOrder):-
    eio_atter(IssuingMemberState, ExecutingMemberState, Measure),
    national_law_does_not_authorize(ExecutingMemberState, Measure).

% 8) EIO concerns the hearing of persons referred to in Articles 179 § 1 or art. 180 § 1 and 2, as to the circumstances specified in these provisions.
optional_refusal(article589zj_2_8, ExecutingMemberState, europeanInvestigationOrder):-
    eio_atter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding_status(IssuingMemberState, Offence, hearing_of_persons_under_art179_1_or_180_1_2)