:- include('../utils.pl').

%%Article 1

%The European Investigation Order and obligation to execute it

%1.   A European Investigation Order (EIO) is a judicial decision which has been issued or validated by a judicial authority of a Member State (‘OGthe issuing State’) to have one or several specific investigative measure(s) carried out in another Member State (‘the executing State’) to obtain evidence in accordance with this Directive.
%The EIO may also be issued for obtaining evidence that is already in the possession of the competent authorities of the executing State.

directive_matter(IssuingMemberState, ExecutingMemberState, Measure):-
    issuing_proceeding(IssuingMemberState, _, Offence),
    executing_member_state(ExecutingMemberState, PersonId, Measure),
    (
        art4_a_applies
    ;   art4_b_applies
    ;   art4_c_applies
    ;   art4_d_applies
    ).

%%(c) the EIO has been issued in proceedings referred to in Article 4(b) and (c) and the investigative measure would not be authorised under the law of the executing State in a similar domestic case;

optional_refusal(article11_1_c, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
        art4_b_applies
    ;   art4_c_applies
    ),
    national_law_does_not_authorize(ExecutingMemberState, Measure).

%%Article 694-31(4) - Partially implemented
%The magistrate to whom the case is referred refuses to recognize or execute a European investigation order in any of the following cases:

%4. If the request concerns proceedings referred to in Article 694-29 of this Code that do not relate to a criminal offence, where the measure requested would not be authorised under French law in the context of similar national proceedings;

optional_refusal(article694_31_4, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    art694_29_applies(Measure),
    national_law_does_not_authorize(ExecutingMemberState, Measure).

national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications):-
    %Article 694-28 does not provide a specific ground for refusing the investigative measure where it is not authorised in a similar domestic procedure. However, the provision can be considered as fully transposed, since article 694-38 of the Code of Criminal Procedure provides for the general possibility for the investigating magistrate to refuse to carry out the requested investigative measure where it could not be carried out in similar domestic cases and there is no other investigative measure that would make it possible to obtain the information requested by the issuing authority.
    \+ authority_decision(Measure, investigating_magistrate, ExecutingMemberState).