:- set_prolog_flag(unknown, warning).
:- style_check(-discontiguous).
:- style_check(-singleton).

:- multifile mandatory_refusal/3.
:- multifile optional_refusal/3.
:- multifile proceeding_status/3.
:- multifile exception/2.
:- multifile crime_type/2.
:- multifile executing_proceeding/3.
:- multifile issuing_proceeding/3.
:- multifile eaw_matter/4.
:- multifile art2_4applies/1.
:- multifile eio_matter/3.

:- dynamic guarantee/3.
:- dynamic authority_decision/3.
:- dynamic amnesty/2.
:- dynamic art2_2applies/1.
:- dynamic art2_4applies/1.
:- dynamic art4_a_applies/0.
:- dynamic art4_b_applies/0.
:- dynamic art4_c_applies/0.
:- dynamic art4_d_applies/0.
:- dynamic art694_29_applies/1.
:- dynamic certificate_status/2.
:- dynamic contrary_to_ne_bis_in_idem/2.
:- dynamic contrast_with/3.
:- dynamic crime_constitutes_offence_national_law/2.
:- dynamic executing_member_state/1.
:- dynamic eaw_matter/4.
:- dynamic executing_proceeding/3.
:- dynamic executing_proceeding_purpose/2.
:- dynamic executing_proceeding_status/3.
:- dynamic issuing_authority/2.
:- dynamic issuing_member_state/1.
:- dynamic issuing_proceeding/3.
:- dynamic measure_data/2.
:- dynamic measure_type/2.
:- dynamic national_law_does_not_authorize/2.
:- dynamic national_law_not_offence/2.
:- dynamic offence_committed_in/1.
:- dynamic offence_type/1.
:- dynamic personId/1.
:- dynamic person_age/2.
:- dynamic person_event/3.
:- dynamic person_nationality/2.
:- dynamic person_role/2.
:- dynamic proceeding_actor/2.
:- dynamic proceeding_danger/3.
:- dynamic validating_authority/2.


crime_type(Offence, committed_in(CommIn)):-
    offence_type(Offence),
    offence_committed_in(CommIn).