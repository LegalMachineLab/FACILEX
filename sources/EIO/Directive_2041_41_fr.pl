:- include('../utils.pl').

%%Article 694-29 - Fully implemented
%Any European investigation order transmitted to the French authorities must be issued or validated by a judicial authority. This decision may concern, in the issuing State, either criminal proceedings or proceedings which do not relate to criminal offences but which are brought against natural or legal persons by administrative or judicial authorities for acts which are punishable in the issuing State by infringements of the rules of law and by a decision which may give rise to proceedings before a court having jurisdiction, in particular in criminal matters.


%%Article 694-31(4) - Partially implemented
%The magistrate to whom the case is referred refuses to recognize or execute a European investigation order in any of the following cases:

%4. If the request concerns proceedings referred to in Article 694-29 of this Code that do not relate to a criminal offence, where the measure requested would not be authorised under French law in the context of similar national proceedings;


optional_refusal(article694_31_4, ExecutingMemberState, europeanInvestigationOrder):-
    eio_matter(IssuingMemberState, ExecutingMemberState, Measure),
    (
        art694-29_applies
    ),
    national_law_does_not_authorize(ExecutingMemberState, Measure).


national_law_does_not_authorize(ExecutingMemberState, Measure):-
    
