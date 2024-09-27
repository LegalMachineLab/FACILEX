:- set_prolog_flag(unknown, warning).
:- style_check(-discontiguous).
:- style_check(-singleton).

:- multifile mandatory_refusal/3.
:- multifile optional_refusal/3.
:- multifile proceeding_status/3.
:- multifile exception/2.


crime_type(Offence, committed_in(CommIn)):-
    offence_type(Offence),
    offence_committed_in(CommIn).