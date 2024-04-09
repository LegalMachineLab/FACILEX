:- include('../utils.pl').


%%Article 1

%The European Investigation Order and obligation to execute it

%1.   A European Investigation Order (EIO) is a judicial decision which has been issued or validated by a judicial authority of a Member State (‘OGthe issuing State’) to have one or several specific investigative measure(s) carried out in another Member State (‘the executing State’) to obtain evidence in accordance with this Directive.
%The EIO may also be issued for obtaining evidence that is already in the possession of the competent authorities of the executing State.

eio_matter(IssuingMemberState, ExecutingMemberState):-
    issuing_proceeding(IssuingMemberState, PersonId, Offence),
    executing_member_state(ExecutingMemberState, PersonId, Offence).