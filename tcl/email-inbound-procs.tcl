ad_library {

    Provides API for reliably importing email.
    
    @creation-date 19 Jul 2017
    @cvs-id $Id: $

}

#package require mime 1.4

namespace eval acs_mail_lite {}

ad_proc acs_mail_lite::imap_cache_clear {
} {
    Clears table of all email uids for all imap history.
    All unread input emails will be considered new and reprocessed.
    To keep history, just temporarily forget it,
    append a revision date to acs_mail_lite_email_src_ext_id_map.src_ext instead.
    <br/><br/>
    If you are not sure if this will do what you want, try setting
    reprocess_old_p to '1'.
    @see acs_mail_lite::sched_parameters
    
} {
    db_dml acs_mail_lite_email_uid_map_d {
        update acs_mail_lite_email_uid_map {
            delete from acs_mail_lite_email_uid_map
            
        }
    }
    return 1
}

ad_proc acs_mail_lite::sched_parameters {
    -sredpcs_override:optional
    -reprocess_old_p:optional
    -max_concurrent:optional
    -max_blob_chars:optional
    -mpri_min:optional
    -mpri_max:optional
    -hpri_pkg_ids:optional
    -lpri_pkg_ids:optional
    -hpri_party_ids:optional
    -lpri_party_ids:optional
    -hpri_subject_glob:optional
    -lpri_subject_glob:optional
} {
    Returns a name value list of parameters used by ACS Mail Lite scheduled procs.
    If a parameter is passed with value, the value is assigned to parameter.

    @option sched_parameter value

    @param sredpcs_override If set, use this value instead of scan_replies_est_dur_per_cycle_s. See www/doc/analysis-notes

    @param reprocess_old_p If set, does not check if unread email was processed before.

    @param max_concurrent Max number of concurrent threads for fast priority importing of email.

    @param max_blob_chars Any incoming email body part over this many characters is stored in a file instead of database. 

    @
} {
    # See one row table acs_mail_lite_ui

    if { [db_table_exists acs_mail_lite_ui] } {
    set sredpcs_override 0
    set reprocess_old_p "f"
    set max_concurrent 6
    set max_blob_chars 32767
        db_0or1row acs_mail_lite_ui_r {
        select sredpcs_override,reprocess_old_p,max_concurrent
        from acs_mail_lite_ui limit 1
        }
        db_dml acs_mail_lite_ui_w {
        insert into acs_mail_lite_ui 
        (sredpcs_override,reprocess_old_p,max_concurrent)
            values (:sredpcs_override,:reprocess_old_p,:max_concurrent);
        }
    }




}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
