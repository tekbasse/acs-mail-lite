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
    -hpri_package_ids:optional
    -lpri_package_ids:optional
    -hpri_party_ids:optional
    -lpri_party_ids:optional
    -hpri_subject_glob:optional
    -lpri_subject_glob:optional
    -hpri_object_ids:optional
    -lpri_object_ids:optional
} {
    Returns a name value list of parameters used by ACS Mail Lite scheduled procs.
    If a parameter is passed with value, the value is assigned to parameter.

    @option sched_parameter value

    @param sredpcs_override If set, use this value instead of scan_replies_est_dur_per_cycle_s. See www/doc/analysis-notes

    @param reprocess_old_p If set, does not check if unread email was processed before.

    @param max_concurrent Max number of concurrent threads for fast priority importing of email.

    @param max_blob_chars Any incoming email body part over this many characters is stored in a file instead of database. 

    @param mpri_min Minimum threshold integer for medium priority. Below this is fast High priority.

    @param mpri_max Maximum integer for medium priority. Above this is Low priority.

    @param hpri_package_ids List of package_ids to process at fast/high priority.

    @param lpri_package_ids List of package_ids to process at low priority.

    @param hpri_party_ids List of party_ids to process at fast/high priority.

    @param lpri_party_ids List of party_ids to process at low priority.
    
    @param hpri_subject_glob A glob searching subjects to flag as fast/high priority.

    @param lpri_subject_glob A glob searching subjects to flag as low priority.   

    @param hpri_object_ids List of object_ids to process at fast/high priority.

    @param lpri_object_ids List of object_ids to process at low priority.

} {
    # See one row table acs_mail_lite_ui
    # sched_parameters sp
    set sp_list [list \
                     sredpcs_override \
                     reprocess_old_p \
                     max_concurrent \
                     max_blob_chars \
                     mpri_min \
                     mpri_max \
                     hpri_package_ids \
                     lpri_package_ids \
                     hpri_party_ids \
                     lpri_party_ids \
                     hpri_subject_glob \
                     lpri_subject_glob \
                     hpri_object_ids \
                     lpri_object_ids ]
    foreach sp $sp_list {
        if { [info exists $sp] } {
            set new(${sp}) [set $sp]
        }
    }
    set changes_p [array exists new]
    set exists_p [db_0or1row acs_mail_lite_ui_r {
        select sredpcs_override,
        reprocess_old_p,
        max_concurrent,
        max_blob_chars,
        mpri_min,
        mpri_max,
        hpri_package_ids,
        lpri_package_ids,
        hpri_party_ids,
        lpri_party_ids,
        hpri_subject_glob,
        lpri_subject_glob,
        hpri_object_ids,
        lpri_object_ids 
        from acs_mail_lite_ui limit 1
    } ]

    if { $exists_p } {
        if { $changes_p } {
            set new_pv_list [array names new]
            foreach sp_n $new_pv_list {
                set ${sp_n} $new($sp_n)
            }
        }
    } else {
        # set initial defaults
        set sredpcs_override 0
        set reprocess_old_p "f"
        set max_concurrent 6
        set max_blob_chars 32767
        set mpri_min "999"
        set mpri_max "99999"
        set hpri_package_ids ""
        set lpri_package_ids ""
        set hpri_party_ids ""
        set lpri_party_ids ""
        set hpri_subject_glob ""
        set lpri_subject_glob ""
        set hpri_object_ids ""
        set lpri_object_ids ""
    }

    if { !$exists_p || $changes_p } {
        set validated_p 1
        if { $changes_p } {
            foreach spn $new_pv_list {
                switch -exact -- $spn {
                    sredpcs_override -
                    max_concurrent -
                    max_blob_chars -
                    mpri_min -
                    mpri_max {
                        set v_p [ad_var_type_check_integer_p $new(${spn})]
                    }
                    reprocess_old_p {
                        if { $new(${spn}) eq \
                                 [template::util::is_true $new(${spn}) ] } {
                            set v_p 1
                        } else {
                            set v_p 0
                        }
                    }
                    hpri_package_ids -
                    lpri_package_ids -
                    hpri_party_ids -
                    lpri_party_ids -
                    hpri_object_ids -
                    lpri_object_ids {
                        set v_p [ad_var_type_check_integerlist_p $new(${spn})]
                    }
                    hpri_subject_glob -
                    lpri_subject_glob {
                        set v_p [regexp -- {^[[:graph:]\ ]+$} $new(${spn})] scratch
                        if { $v_p && [string match {*[\[;]*} $new(${spn}) ] } {
                            set v_p 0
                        }
                    }
                    defaults {
                        ns_log Warning "acs_mail_lite::sched_parameters \
 No validation check made for parameter '${spn}'"
                    }
                }
                if { !$v_p } {
                    set validated_p 0
                    ns_log Warning "acs_mail_lite::sched_parameters \
 value '$new(${spn})' for parameter '${spn}' not allowed."
            }
        }
        if { $validated_p } {
            db_transaction {
                if { $changes_p } {
                    db_dml acs_mail_lite_ui_d {
                        delete from acs_mail_lite_ui
                    }
                }
                db_dml acs_mail_lite_ui_i {
                    insert into acs_mail_lite_ui 
                    (sredpcs_override,
                     reprocess_old_p,
                     max_concurrent,
                     max_blob_chars,
                     mpri_min,
                     mpri_max,
                     hpri_package_ids,
                     lpri_package_ids,
                     hpri_party_ids,
                     lpri_party_ids,
                     hpri_subject_glob,
                     lpri_subject_glob,
                     hpri_object_ids,
                     lpri_object_ids)
                    values 
                    (:sredpcs_override,
                     :reprocess_old_p,
                     :max_concurrent,
                     :max_blob_chars,
                     :mpri_min,
                     :mpri_max,
                     :hpri_package_ids,
                     :lpri_package_ids,
                     :hpri_party_ids,
                     :lpri_party_ids,
                     :hpri_subject_glob,
                     :lpri_subject_glob,
                     :hpri_object_ids,
                     :lpri_object_ids
                     )
                }
            }
        } 
    }
    set s_list [list ]
    foreach s $sp_list {
        lappend s_list $s [set $s]
    }
    return $s_list
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
