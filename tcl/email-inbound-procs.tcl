ad_library {

    Provides API for reliably importing email.
    
    @creation-date 19 Jul 2017
    @cvs-id $Id: $

}

#package require mime 1.4

namespace eval acs_mail_lite {}

ad_proc -private acs_mail_lite::imap_cache_clear {
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

ad_proc -public acs_mail_lite::sched_parameters {
    -sredpcs_override
    -reprocess_old_p
    -max_concurrent
    -max_blob_chars
    -mpri_min
    -mpri_max
    -hpri_package_ids
    -lpri_package_ids
    -hpri_party_ids
    -lpri_party_ids
    -hpri_subject_glob
    -lpri_subject_glob
    -hpri_object_ids
    -lpri_object_ids
} {
    Returns a name value list of parameters 
    used by ACS Mail Lite scheduled procs.
    If a parameter is passed with value, the value is assigned to parameter.

    @option sched_parameter value

    @param sredpcs_override If set, use this instead of scan_in_est_dur_per_cycle_s. See www/doc/analysis-notes

    @param reprocess_old_p If set, does not ignore prior unread email

    @param max_concurrent Max concurrent processes to import (fast priority)

    @param max_blob_chars Email body parts larger are stored in a file.

    @param mpri_min Minimum threshold integer for medium priority. Smaller is fast High priority.

    @param mpri_max Maximum integer for medium priority. Larger is Low priority.

    @param hpri_package_ids List of package_ids to process at fast priority.

    @param lpri_package_ids List of package_ids to process at low priority.

    @param hpri_party_ids List of party_ids to process at fast/high priority.

    @param lpri_party_ids List of party_ids to process at low priority.
    
    @param hpri_subject_glob When email subject matches, flag as fast priority.

    @param lpri_subject_glob When email subject matches, flag as low priority.

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

    if { !$exists_p } {
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
            set new_pv_list [array names new]
            foreach spn $new_pv_list {
                switch -exact -- $spn {
                    sredpcs_override -
                    max_concurrent -
                    max_blob_chars -
                    mpri_min -
                    mpri_max {
                        set v_p [ad_var_type_check_integer_p $new(${spn})]
                        if { $v_p } {
                            if { $new(${spn}) < 0 } {
                                set v_p 0
                            }
                        }
                        if { $v_p && $spn eq "mpri_min" } {
                            if { $new(${spn}) >= $mpri_max } {
                                set v_p 0
                                ns_log Warning "acs_mail_lite::\
 sched_parameters mpri_min '$new(${spn})' \
 must be less than mpri_max '${mpri_max}'"
                            }
                        }
                        if { $v_p && $spn eq "mpri_max" } {
                            if { $new(${spn}) <= $mpri_min } {
                                set v_p 0
                                ns_log Warning "acs_mail_lite::\
 sched_parameters mpri_min '${mpri_min}' \
 must be less than mpri_max '$new(${spn})'"
                            }
                        }
                    }
                    reprocess_old_p {
                        set v_p [string is boolean -strict $new(${spn}) ]
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
                        if { $new(${spn}) eq "" } {
                            set v_p 1
                        } else {
                            set v_p [regexp -- {^[[:graph:]\ ]+$} $new(${spn})]
                            if { $v_p && \
                                     [string match {*[\[;]*} $new(${spn}) ] } {
                                set v_p 0
                            }
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
        }
            
        if { $validated_p } {
            foreach sp_n $new_pv_list {
                set ${sp_n} $new($sp_n)
            }

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
        set sv [set ${s}]
        lappend s_list ${s} $sv
    }
    return $s_list
}

ad_proc -public acs_mail_lite::prioritize_in {
    -size_chars:required
    -received_cs:required
    -subject:required
    {-package_id ""}
    {-party_id ""}
    {-object_id ""}
} {
    Returns a prioritization number for assigning to an inbound email.
    Another proc processes in order of lowest number first.
    Returns empty string if input values from email are not expected types.

    @param size_chars of email

    @param received_cs seconds since epoch when email received

    @param package_id associated with email (if any)

    @param party_id associated with email (if any)

    @param sujbect of email

    @param object_id associated with email (if any)

} {
    set priority_fine ""
    set input_error_p 0
    # validate email inputs
    if { ! ([string is integer -strict $size_chars] && $size_chars > 0) } {
        set input_error_p 1
        ns_log Warning "acs_mail_lite::prioritize_in.283: \
 size_chars '${size_chars}' is not a natural number."
    }
    if { ! ([string is integer -strict $received_cs] && $received_cs > 0) } {
        set input_error_p 1
        ns_log Warning "acs_mail_lite::prioritize_in.289: \
 received_cs '${received_cs}' is not a natural number."
    }
    if { $input_error_p } {
        return ""
    }

    # *_cs means clock time from epoch in seconds, 
    #      same as returned from tcl clock seconds
    array set params_arr [acs_mail_lite::sched_parameters]

    set priority 2
    # Set general priority in order of least specific first
    if { $package_id ne "" } {
        if { $package_id in $params_arr(hpri_package_ids) } {
            set priority 1
        }
        if { $package_id in $params_arr(lpri_package_ids) } {
            set priority 3
        }
    }

    if { $party_id ne "" } {
        if { $party_id in $params_arr(hpri_party_ids) } {
            set priority 1
        }
        if { $party_id in $params_arr(lpri_party_ids) } {
            set priority 3
        }
    }


    if { [string match $params_arr(hpri_subject_glob) $subject] } {
        set priority 1
    }
    if { [string match $params_arr(lpri_subject_glob) $subject] } {
        set priority 3
    }

    
    if { $object_id ne "" } {
        if { $object_id in $params_arr(hpri_object_ids) } {
            set priority 1
        }
        if { $object_id in $params_arr(lpri_object_ids) } {
            set priority 3
        }
    }
    
    # quick math for arbitrary super max of maxes
    set su_max $params_arr(mpri_max)
    append su_max "00"
    set size_max [ns_config -int -min $su_max -set nssock_v4 maxinput $su_max]

    # add granularity
    switch -exact $priority {
        1 {
            set pri_min 0
            set pri_max $params_arr(mpri_min)
        }
        2 {
            set pri_min $params_arr(mpri_min)
            set pri_max $params_arr(mpri_max)
        }
        3 {
            set pri_min $params_arr(mpri_max)
            set pri_max $size_max
        }
        default {
            ns_log Warning "acs_mail_lite::prioritize_in.305: \
 Priority value not expected '${priority}'"
        }
    }

    ns_log Dev "prioritize_in: pri_max '${pri_max}' pri_min '${pri_min}'"

    set range [expr { $pri_max - $pri_min } ]
    # deviation_max = d_max
    set d_max [expr { $range / 2 } ]
    # midpoint = mp
    set mp [expr { $pri_min + $d_max } ]
    ns_log Dev "prioritize_in: range '${range}' d_max '${d_max}' mp '${mp}'"

    # number of variables in fine granularity calcs: 
    # char_size, date time stamp
    set varnum 2
    # Get most recent scan start time for reference to batch present time
    set start_cs [nsv_get acs_mail_lite scan_in_start_t_cs]
    set dur_s [nsv_get acs_mail_lite scan_in_est_dur_p_cycle_s]
    ns_log Dev "prioritize_in: start_cs '${start_cs}' dur_s '${dur_s}'"

    # Priority favors earlier reception, returns decimal -1. to 0.
    # for normal operation. Maybe  -0.5 to 0. for most.
    set pri_t [expr { ( $received_cs - $start_cs ) / ( 2. * $dur_s ) } ]

    # Priority favors smaller message size. Returns decimal 0. to 1.
    # and for most, somewhere closer to perhaps 0.
    set pri_s [expr { ( $size_chars / ( $size_max + 0. ) ) } ]
    
    set priority_fine [expr { int( ( $pri_t + $pri_s ) * $d_max ) + $mp } ] 
    ns_log Dev "prioritize_in: pri_t '${pri_t}' pri_s '${pri_s}'"
    ns_log Dev "prioritize_in: pre(max/min) priority_fine '${priority_fine}'"
    set priority_fine [f::min $priority_fine $pri_max]
    set priority_fine [f::max $priority_fine $pri_min]

    return $priority_fine
}

ad_proc -private acs_mail_lite::imap_conn_set {
    {-host ""}
    {-password ""}
    {-port ""}
    {-timeout ""}
    {-user ""}
} {
    Returns a name value list of parameters
    used by ACS Mail Lite imap connections

    If a parameter is passed with value, the value is assigned to parameter.
} {
    # See one row table acs_mail_lite_imap_conn
    # imap_conn_ = ic
    set ic_list [list \
                     host \
                     password \
                     port \
                     timeout \
                     user ]
    # ic fields = icf
    set icf_list [list ]
    foreach ic $ic_list {
        set icf [string range $ic 0 1]
        lappend icf_list $icf
        if { [info exists $ic] } {
            set new_arr(${ic}) [set $ic]
        }
    }
    set changes_p [array exists new]
    set exists_p [db_0or1row acs_mail_lite_imap_conn_r {
        select ho,pa,po,ti,us
        from acs_mail_lite_imap_conn limit 1
    } ]

    if { !$exists_p } {
        # set initial defaults
        set mb [ns_config nsimap mailbox ""]
        if { [string match "*@*" $mb] } {
            set mb_list [split $mb "@"]
            set ho [lindex $mb_list end]
        } else {
            set ho [ns_config nssock hostname ""]
            if { $ho eq "" } {
                set ho [ns_config nssock_v4 hostname ""]
            }
            if { $ho eq "" } {
                set ho [ns_config nssock_v6 hostname ""]
            }
        }
        set pa [ns_config nsimap password ""]
        set po [ns_config nsimap port ""]
        set ti [ns_config -int nsimap timeout 1800]
        set us [ns_config nsimap user ""]
    }

    if { !$exists_p || $changes_p } {
        set validated_p 1
        if { $changes_p } {
            # new = n
            set n_pv_list [array names new]
            foreach icn $n_pv_list {
                switch -exact -- $icn {
                    port -
                    timeout {
                        if { $n_arr(${icn}) eq "" } {
                            set v_p 1
                        } else {
                            set v_p [string is digit -strict $n_arr(${icn})]
                            if { $v_p } {
                                if { $n_arr(${icn}) < 0 } {
                                    set v_p 0
                                }
                            }
                        }
                    }
                    host -
                    password -
                    user {
                        if { $n_arr(${icn}) eq "" } {
                            set v_p 1
                        } else {
                            set v_p [regexp -- {^[[:graph:]\ ]+$} $n_arr(${icn})]
                            if { $v_p && \
                                     [string match {*[\[;]*} $n_arr(${icn}) ] } {
                                set v_p 0
                            }
                        }
                    }
                    defaults {
                        ns_log Warning "acs_mail_lite::imap_conn_set \
 No validation check made for parameter '${icn}'"
                    }
                }
                if { !$v_p } {
                    set validated_p 0
                    ns_log Warning "acs_mail_lite::imap_conn_set \
 value '$n_arr(${icn})' for parameter '${icn}' not allowed."
                }
            }
        }
            
        if { $validated_p } {
            foreach ic_n $n_pv_list {
                set ${ic_n} $n_arr($ic_n)
            }

            db_transaction {
                if { $changes_p } {
                    db_dml acs_mail_lite_imap_conn_d {
                        delete from acs_mail_lite_imap_conn
                    }
                }
                db_dml acs_mail_lite_imap_conn_i {
                    insert into acs_mail_lite_imap_conn 
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
    set i_list [list ]
    foreach i $ic_list {
        set svi [string range $i 0 1]
        set sv [set ${svi}]
        lappend i_list ${i} $sv
    }
    return $i_list
}

ad_proc -private acs_mail_lite::imap_conn_go {
    {-conn_id ""}
    {-host ""}
    {-password ""}
    {-port ""}
    {-timeout ""}
    {-user ""}
} {
    Verifies connection (connId) is established.
    Tries to establish a connection if it doesn't exist.

    If -host parameter is supplied, will try connection with supplied params.
    Defaults to use connection info provided by parameters.

    @return connectionId or empty string if unsuccessful.
} {
    imap_conn_go = icg
    imap_conn_set = ics
    if { $host eq "" } {
        set ics_list [acs_mail_lite::imap_conn_set ]
        foreach {n v} $ics_list {
            set $n "${v}"
        }
    }

    set prior_conn_exists_p 0
    if { $conn_id ne "" } {
        # list {id opentime accesstime mailbox} ...
        set id ""
        set opentime ""
        set accesstime ""
        set mailbox ""

        set sessions_list [ns_imap sessions]
        set s_len [llength $sessions_list]
        set i 0
        while { $i < $s_len && $id ne $conn_id }  {
            set s_list [lindex $sessions_list 0]
            set id [lindex $s_list 0]
            if { $id eq $conn_id } {
                set prior_conn_exists_p 1
                set opentime [lindex $s_list 1]
                set accesstime [lindex $s_list 2]
                set mailbox [lindex $s_list 3]
            }
            incr i
        }
    }

    if { $prior_conn_exists_p } {
        # ns_imap status $conn_id
        # if no connection, set prior_conn_exists_p 0
    } 

    # prior_conn_exists_p 0, 
        ##login
        set conn_id ""

}


#
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
