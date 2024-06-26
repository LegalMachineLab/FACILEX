:- include('../utils.pl').

%%In Portugal, the interception of communications requires the authorisation of a judge (Articles 188-189 Code of Criminal Procedure);

optional_refusal(article188, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    directive_matter(IssuingMemberState, ExecutingMemberState, interception_of_telecommunications),
    national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications).

national_law_does_not_authorize(ExecutingMemberState, interception_of_telecommunications):-
    \+ authority_decision(interception_of_telecommunications, investigating_magistrate, ExecutingMemberState).