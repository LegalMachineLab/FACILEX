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

%%%%    *TODO*: 
%%      VEDERE SE ART. 10(1) è motivo di rifiuto e di conseguenza art. 10(2) eccezione

%Article 11

%%Grounds for non-recognition or non-execution 

%%1.Without prejudice to Article 1(4), recognition or execution of an EIO may be refused in the executing State where:(a) there is an immunity or a privilege under the law of the executing State which makes it impossible to execute the EIO or there are rules on determination and limitation of criminal liability relating to freedom of the press and freedom of expression in other media, which make it impossible to execute the EIO;

optional_refusal(article11_1_a, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    eio_execution_impossible(Measure, ExecutingMemberState).

eio_execution_impossible(Measure, ExecutingMemberState):-
    contrast_with(Measure, ExecutingMemberState, immunity_privilege).

eio_execution_impossible(Measure, ExecutingMemberState):-
    contrast_with(Measure, ExecutingMemberState freedom_press)
;   contrast_with(Measure, ExecutingMemberState, freedom_expression_media).

%%(b) in a specific case the execution of the EIO would harm essential national security interests, jeopardise the source of the information or involve the use of classified information relating to specific intelligence activities;

optional_refusal(article11_1_b, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
    proceeding_danger(Measure, ExecutingMemberState, national_security);
    proceeding_danger(Measure, ExecutingMemberState, jeopardise_source_information);
    proceeding_danger(Measure, ExecutingMemberState, classified_information_intelligence)
    ).

%%(c) the EIO has been issued in proceedings referred to in Article 4(b) and (c) and the investigative measure would not be authorised under the law of the executing State in a similar domestic case;

optional_refusal(article11_1_c, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
        art4_b_applies
    ;   art4_c_applies
    ),
    national_law_does_not_authorize(ExecutingMemberState, Measure).

%%(d) the execution of the EIO would be contrary to the principle of ne bis in idem;

optional_refusal(article11_1_d, MemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    contrary_to_ne_bis_in_idem(ExecutingMemberState, Measure).

%% (e) the EIO relates to a criminal offence which is alleged to have been committed outside the territory of the issuing State and wholly or partially on the territory of the executing State, and the conduct in connection with which the EIO is issued is not an offence in the executing State;

optional_refusal(article11_1_e, MemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_outside_territory),
    issuing_proceeding_status(IssuingMemberState, Offence, committed_inside_executing_ms),
    not_offence(Offence, ExecutingMemberState).


%% (f) there are substantial grounds to believe that the execution of the investigative measure indicated in the EIO would be incompatible with the executing State's obligations in accordance with Article 6 TEU and the Charter;

optional_refusal(article11_1_f, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    proceeding_danger(Measure, ExecutingMemberState, incompatible_EU_obligations).


%% (g) the conduct for which the EIO has been issued does not constitute an offence under the law of the executing State, unless it concerns an offence listed within the categories of offences set out in Annex D, as indicated by the issuing authority in the EIO, if it is punishable in the issuing State by a custodial sentence or a detention order for a maximum period of at least three years; or

optional_refusal(article11_1_g, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    not_offence(Offence, ExecutingMemberState),
    \+ exception(optional_refusal(article11_1_g, ExecutingMemberState, europeanInvestigationOrder), _).


%% (h) the use of the investigative measure indicated in the EIO is restricted under the law of the executing State to a list or category of offences or to offences punishable by a certain threshold, which does not include the offence covered by the EIO.

optional_refusal(article11_1_h, ExecutingMemberState, europeanInvestigationOrder):-
    directive_matter(IssuingMemberState, ExecutingMemberState, Measure),
    issuing_proceeding(IssuingMemberState, _, Offence),
    national_law_does_not_authorize(ExecutingMemberState, Measure, Offence).
