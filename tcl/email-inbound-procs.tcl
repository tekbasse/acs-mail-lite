ad_library {

    Provides API for importing email under a varitey of deployment conditions.
    
    @creation-date 19 Jul 2017
    @cvs-id $Id: $

}

namespace eval acs_mail_lite {}

# Although loose dependencies require imap procs right now,
# the inbound email procs are designed to integrate
# other inbound email paradigms with minimal amount
# of re-factoring of code.

# See acs_mail_lite::imap_check_incoming
# for a template for creating a generic version:
# acs_mail_lite::check_incoming

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
        set new_pv_list [array names new]
        if { $changes_p } {
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

                # See acs_mail_lite::imap_check_incoming for usage of:
                nsv_set acs_mail_lite scan_in_configured_p 1
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


ad_proc -public acs_mail_lite::email_type {
    {-subject ""}
    {-from ""}
    {-headers ""}
    {-header_arr_name ""}
    {-reply_too_fast_s "10"}
    {-check_subject_p "0"}
} {
    Scans email's subject, from and headers for actionable type.
    Returns actionable type: 'auto_gen' 'auto_reply', 'bounce', 'in_reply_to' or 
    empty string indicating 'other' type.
    'auto_reply' may be a Delivery Status Notification for example.
    'bounce' is a specific kind of Delivery Status Notification.
    'in_reply_to' is an email reporting to originate from local email,
    which needs to be tested further to see if OpenACS needs to act on
    it versus a reply to a system administrator email for example.
    'auto_gen' is an auto-generated email that does not qualify as 'auto_reply', 'bounce', or 'in_reply_to'
    'other' refers to email that the system does not recognize as a reply
    of any kind.


    If not a qualifying type, returns empty string.


    If headers and header_arr_name provided, only header_arr_name will be used.

    If check_subject_p is set 1, \
    checks for common subjects identifying autoreplies. \
        This is not recommended to rely on exclusively. \
        This feature provides a framework for expaning classification of \
        emails for deployment routing purposes.

    If array includes keys from 'ns_imap struct', such as internaldate.*, \
        then type will also classify quick re-sends (reply or forward) \
        with large content as 'auto_gen'.

    @param subject of email
    @param from of email
    @param headers of email, a block of text containing all headers and values
    @param header_arr_name, the name of an array containing headers.
    @param check_subject_p Set to 1 to check email subject. 
} {
    set ag_p 0
    set an_p 0
    set ar_p 0
    set as_p 0
    set dsn_p 0
    set irt_idx -1
    set or_idx -1
    set pe_p 0
    set ts_p 0
    # header cases:  {*auto-generated*} {*auto-replied*} {*auto-notified*}
    # from:
    # https://www.iana.org/assignments/auto-submitted-keywords/auto-submitted-keywords.xhtml
    # and rfc3834 https://www.ietf.org/rfc/rfc3834.txt

    # Do NOT use x-auto-response-supress
    # per: https://stackoverflow.com/questions/1027395/detecting-outlook-autoreply-out-of-office-emails

    # header cases: 
    # {*x-autoresponder*} {*autoresponder*} {*autoreply*}
    # {*x-autorespond*} {*auto_reply*} 
    # from: 
    # https://github.com/jpmckinney/multi_mail/wiki/Detecting-autoresponders
    # redundant cases are removed from list.
    # auto reply = ar
    set ar_list [list \
                     {auto-replied} \
                     {auto-reply} \
                     {autoreply} \
                     {autoresponder} \
                     {x-autorespond} \
                    ]
    # Theses were in auto_reply, but are not specific to replies:
    #                     {auto-generated} 
    #             {auto-notified} 
    # See section on auto_gen types. (auto-submitted and the like)

    
    if { $header_arr_name ne "" } {
        upvar 1 $header_arr_name h_arr
    } elseif { $headers ne "" } {
        #  To remove subject from headers to search, 
        #  incase topic uses a reserved word,
        #  we rebuild the semblence of array returned by ns_imap headers.
        #  Split strategy from qss_txt_table_stats
        set linebreaks "\n\r\f\v"
        set row_list [split $headers $linebreaks]
        foreach row $row_list {
            set c_idx [string first ":" $row]
            if { $c_idx > -1 } {
                set header [string trim [string range $row 0 $c_idx-1]]
                # following identifies multiline header content to ignore
                if { ![string match {*[;=,]*} $header] } {
                    # list of email headers at:
                    # https://www.cs.tut.fi/~jkorpela/headers.html
                    # Suggests this filter for untrusted input:
                    if { [regsub -all -- {[^a-zA-Z0-9\-]+} $header {} h2 ] } {
                        ns_log Warning "acs_mail_lite:email_type.864: \
 Unexpected header '${header}' changed to '${h2}'"
                        set header $h2
                    }
                    set value [string trim [string range $row $c_idx+1 end]]
                    # string match from proc safe_eval
                    if { ![string match {*[\[;]*} $value ] } {
                        # 'append' is used instead of 'set' in
                        # the rare case that there's a glitch
                        # and there are two or more headers with same name.
                        # We want to examine all values of specific header.
                        append h_arr(${header}) "${value} "
                        ns_log Dev "acs_mail_lite::email_type.984 \
 header '${header}' value '${value}' from text header '${row}'"
                    }
                }
            }
        }
    }
        
    if { [array exists h_arr] } {

        set hn_list [array names h_arr]
        ns_log Dev "acs_mail_lite::email_type.996 hn_list '${hn_list}'"
        # Following checks according to rfc3834 section 3.1 Message header
        # https://tools.ietf.org/html/rfc3834


        # check for in-reply-to = irt
        set irt_idx [lsearch -glob -nocase $hn_list {in-reply-to}]
        # check for message_id = mi
        # This is a new message id, not message id of email replied to
        set mi_idx [lsearch -glob -nocase $hn_list {message-id}]

        # Also per rfc5436 seciton 2.7.1 consider:
        # auto-submitted = as
        
        set as_idx [lsearch -glob -nocase $hn_list {auto-submitted}]
        if { $as_idx > 1 } {
            set as_p 1
            set as_h [lindex $hn_list $as_idx]
            set an_p [string match -nocase $h_arr(${as_h}) {auto-notified}]
            # also check for auto-generated
            set ag_p [string match -nocase $h_arr(${as_h}) {auto-generated}]
        }
        


        ns_log Dev "acs_mail_lite::email_type.1017 as_p ${as_p} an_p ${an_p} ag_p ${ag_p}"

        # If one of the headers contains {list-id} then email
        # is from a mailing list.

        set i 0
        set h [lindex $ar_list $i]
        while { $h ne "" && !$ar_p } {
            #set ar_p sring match -nocase $h $hn

            set ar_idx [lsearch -glob $hn_list $h]
            if { $ar_idx > -1 } {
                set ar_p 1
            }

            incr i
            set h [lindex $ar_list $i]
        }

        ns_log Dev "acs_mail_lite::email_type.1039 ar_p ${ar_p}"

        # get 'from' header value possibly used in a couple checks
        set fr_idx [lsearch -glob -nocase $hn_list {from}]
        set from_email ""
        if { $fr_idx > -1 } {
            set fr_h [lindex $hn_list $fr_idx]
            set from $h_arr(${fr_h})
            set from_email [string tolower \
                                [acs_mail_lite::parse_email_address \
                                     -email $from]]
            set at_idx [string last "@" $from ]
        } else {
            set at_idx -1
        }
        if { $at_idx > -1 } {
            # from_email is not empty string
            set from_host [string trim [string range $from $at_idx+1 end]]
            set party_id [party::get_by_email -email $from_email]
            if { $party_id ne "" } {
                set pe_p 1
            }
        } else {
            set from_host ""
            set party_id ""
        }


        if { !$ar_p && [info exists h_arr(internaldate.year)] \
                 && $from ne "" } {
            # Does response time indicate more likely by a machine?
            # Not by itself. Only if it is a reply of some kind.

            # Response is likely machine if it is fast.
            # If the difference between date and local time is less than 10s
            # and either from is "" or subject matches "return*to*sender"

            # More likely also from machine 
            # if size is more than a few thousand characters in a short time.

            # This is meant to detect more general cases
            # of bounce/auto_reply detection related to misconfiguration
            # of a system.
            # This check is
            # intended to prevent flooding server and avoiding looping
            # that is not caught by standard MTA / smtp servers.
            # An MTA likely checks already for most floods and loops.
            # As well, this check providesy yet another
            # indicator to intervene in uniquely crafted attacks.

            # RFC 822 header required: DATE
            set dt_idx [lsearch -glob -nocase $hn_list {date}]
            # If there is no date. Flag it.
            if { $dt_idx < 0 } {
                set ts_p 1
            } else {
                # Need to check received timestamp vs. when OpenACS
                # or a system hosted same as OpenACS sent it.

                set dt_h [lindex $hn_list $dt_idx]
                set dte_cs [ns_imap parsedate $h_arr(${dt_h})]
                set dti $h_arr(internaldate.year)
                append dti "-" [format "%02u" $h_arr(internaldate.month)]
                append dti "-" [format "%02u" $h_arr(internaldate.day)]
                append dti " " [format "%02u" $h_arr(internaldate.hours)]
                append dti ":" [format "%02u" $h_arr(internaldate.minutes)]
                append dti ":" [format "%02u" $h_arr(internaldate.seconds)] " "
                if { $h_arr(internaldate.zoccident) eq "0" } {
                    # This is essentially iso8601 timezone formatting.
                    append dti "+"
                } else {
                    # Comment from panda-imap/src/c-client/mail.h:
                    # /* non-zero if west of UTC */
                    # See also discussion beginning with:
                    # /* occidental *from Greenwich) timezones */
                    # in panda-imap/src/c-client/mail.c
                    append dti "-"
                }
                append dti [format "%02u" $h_arr(internaldate.zhours)]
                append dti [format "%02u" $h_arr(internaldate.zminutes)] "00"
                if { [catch {
                    set dti_cs [clock scan $dti -format "%Y-%m-%e %H:%M:%S %z"]
                } err_txt ] } {
                    set dti_cs ""
                    ns_log Warning "acs_mail_lite::email_type.1102 \
 clock scan '${dti}' -format %Y-%m-%d %H:%M:%S %z failed. Could not check ts_p case."
                }
                set diff 1000
                if { $dte_cs ne "" && $dti_cs ne "" } {
                    set diff [expr { abs( $dte_cs - $dti_cs ) } ]
                } 
                # If too fast, set ts_p 1
                if { $diff < 11 } {
                    set ts_p 1
                }


                # check from host against acs_mail_lite's host
                # From: header must show same OpenACS domain for bounce
                # and subsequently verified not a user or system recognized
                # user/admin address. 

                # Examples of unrecognized addresses include mailer-daemon@..
                set host [dict get [acs_mail_lite::imap_conn_set] host]
                if { $ts_p && [string -nocase "*${host}*" $from_host] } {
                    if { $from_email eq [ad_outgoing_sender] || !$pe_p } {
                        # This is a stray one. 
                        set ag_p 1
                    }

                }
                    
                # Another possibility is return-path "<>"
                # and Message ID unique-char-ref@bounce-domain

                # Examples might be a bounced email from 
                # a nonstandard web form on site
                # or 
                # a loop where 'from' is
                # a verified user or system recognized address
                # and reply is within 10 seconds
                # and a non-standard acs-mail-lite reply-to address

                # Or multiple emails from same user under 10 seconds
                # but we can't check that from this context.
                # Internal date info can be imported with email
                # for futher filtering after import.
                
            }

        }
        
        # Delivery Status Notifications, see rfc3464
        # https://tools.ietf.org/html/rfc3464
        # Note: original-envelope-id is not same as message-id.
        # original-recipient = or
        set or_idx [lsearch -glob -nocase $hn_list {original-recipient}]
        # action = ac (required for DSN)
        # per fc3464 s2.3.3
        set ac_idx [lsearch -glob -nocase $hn_list {action}]
        if { $ac_idx > -1 } {
            set ac_h [lindex $hn_list $ac_idx]
            set status_list [list failed \
                                 delayed \
                                 delivered \
                                 relayed \
                                 expanded ]
            # Should 'delivered' be removed from status_list?
            # No, just set ar_p 1 instead of dsn_p 1

            set s_i 0
            set status_p 0
            set stat [lindex $status_list $s_i]
            while { $stat ne "" && !$status_p } {
                # What if there are duplicate status values or added junk?
                # Catch it anyway by wrapping glob with asterisks
                if { [string match -nocase "*${stat}*" $h_arr(${ac_h})] } {
                    set status_p 1
                }
                ns_log Dev "acs_mail_lite::email_type.1070 \
 status_p $status_p stat '${stat}' ac_h ${ac_h} h_arr(ac_h) '$h_arr(${ac_h})'"

                incr s_i
                set stat [lindex $status_list $s_i]
            }
            if { $status_p } {
                # status = st (required for DSN)
                # per fc3464 s2.3.4
                set st_idx [lsearch -glob -nocase $hn_list {status}]
                if { $st_idx > -1 } {
                    set st_h [lindex $hn_list $st_idx]
                    set dsn_p [string match {*[0-9][0-9][0-9]*} \
                                   $h_arr(${st_h}) ]
                    ns_log Dev "acs_mail_lite::email_type.1080 \
 dsn_p ${dsn_p} st_h ${st_h} h_arr(st_h) '$h_arr(${st_h})'"
                    if { $st_idx eq 2 || !$dsn_p } {
                       set ar_p 1
                    }
                }
            }
        }

        ns_log Dev "acs_mail_lite::email_type.1089 \
 ar_p ${ar_p} dsn_p ${dsn_p}"

        # if h_arr exists and..
        if { !$ar_p && $check_subject_p } {
            # catch nonstandard cases
            # subject flags
            
            # If 'from' not set. Set here.
            if { $from eq "" } {
                set fr_idx [lsearch -glob -nocase $hn_list {from}]
                if { $fr_idx > -1 } {
                    set from $h_arr(${from})
                }
            }
            # If 'subject' not set. Set here.
            if { $subject eq "" } {
                set fr_idx [lsearch -glob -nocase $hn_list {subject}]
                if { $fr_idx > -1 } {
                    set subject $h_arr(${subject})
                }
            }
            
            set ps1 [string match -nocase {*out of*office*} $subject]
            set ps2 [string match -nocase {*automated response*} $subject]
            set ps3 [string match -nocase {*autoreply*} $subject]
            set ps4 [string match {*NDN*} $subject]
            set ps5 [string match {*\[QuickML\] Error*} $subject]
            # rfc3834 states to NOT rely on 'Auto: ' in subject for detection. 
            #set ps6 \[string match {Auto: *} $subject\]
            
            # from flags = pf
            set pf1 [string match -nocase {*mailer*daemon*} $from]
                
            set ar_p [expr { $ps1 || $ps2 || $ps3 || $ps4 || $ps5 || $pf1 } ]
        }

    }
    ns_log Dev "acs_mail_lite::email_type.1127 ar_p ${ar_p}"


    # Return actionable types:
    # 'auto_gen', 'auto_reply', 'bounce', 'in_reply_to' or '' (other)

    #  a bounce also flags maybe auto_reply, in_reply_to, auto_gen
    # an auto_reply also flags maybe auto_reply, auto_gen, in_reply_to
    # an auto_gen does NOT include an 'in_reply_to'
    # an in_reply_to does NOT include 'auto_gen'. 
    if { $dsn_p || $or_idx > -1 } {
        set type "bounce"
    } elseif { $ar_p || ( $irt_idx > -1 && \
                              ( $ag_p || $as_p || $an_p || $ts_p ) ) } {
        set type "auto_reply"
    } elseif { $ag_p || $as_p || $an_p || $ts_p } {
        set type "auto_gen"
    } elseif { $irt_idx > -1 } {
        set type "in_reply_to"
    } else {
        # other
        set type ""
    }
    
    return $type
}


ad_proc -private acs_mail_lite::queue_inbound_insert {
    -headers_arr_name
    -parts_arr_name
    -files_arr_name
    {-aml_email_id ""}
    {-section_ref ""}
    {-struct_list ""}
    {-error_p "0"}
} {
    Adds a new, actionable incoming email to the queue for
    prioritized processing.

    Returns aml_email_id if successful, otherwise empty string.
} {
    upvar 1 $headers_arr_name h_arr
    upvar 1 $parts_arr_name p_arr
    upvar 1 $files_arr_name f_arr

    # This should remain general enough to import
    # email regardless of its source.

    # Email should already be parsed and in a transferable format
    # in passed arrays

    # Array content should be formatted parallel to the tables:
    # h_arr acs_mail_lite_ie_headers
    # p_arr acs_mail_lite_ie_parts
    # p_arr($section_id,nv_list) acs_mail_lite_part_nv_pairs
    # f_arr acs_mail_lite_ie_files
    # 
    # where index is section_id based on section_ref, and
    # where top most section_ref is empty string.
    # 
    # Specifically,
    # for p_arr, c_type is p_arr($section_id,c_type)
    # for 
    # for f_arr, filename is f_arr($section_id,filename)
    #            c_filepathname is f_arr($section_id,c_filepathname)
    # 


    
    if { !$error_p } {
        
        ##code
        # email goes into queue tables:

        # 
        # acs_mail_lite_ie_headers
        #
        # acs_mail_lite_ie_parts
        # acs_mail_lite_ie_files
    }
    return $error_p
}


ad_proc -private acs_mail_lite::queue_inbound_batch_pull {
} {
    Identifies and processes highest priority inbound email.
} {

    # calls acs_mail_lite::queue_inbound_pull once per email

}



ad_proc -private acs_mail_lite::queue_inbound_pull {
} {
    
    Reads an email from the inbound queue, 
    removes the email from the queue.

} {
    
    ##code
    # an email is pulled from these tables
    # aml_id may not be unique for *_parts or *_files
    # acs_mail_lite_from_external
    # acs_mail_lite_ie_headers
    # acs_mail_lite_ie_parts
    # acs_mail_lite_ie_files

    # email is removed from queue when
    # set acs_mail_lite_from_external.processed_p 1

    # When all the callbacks are processed, 
    # set acs_mail_lite_from_external.release_p 1
}

ad_proc -private acs_mail_lite::queue_release {
} {
    Delete email from queue that have been flagged 'release'.

    This does not affect email via imap.
    
} {
    # To flag 'release', set acs_mail_lite_from_external.release_p 1
    ##code

}

ad_proc -private acs_mail_lite::imap_cache_hit_p {
    email_uid
    imap_uidvalidity
    mailbox_host_name
} {
    Check email unqiue id (UID) against history in table.
    If already exists, returns 1 otherwise 0.
    Adds checked case to cache if not already there.
} {
    set hit_p 0
    set src_ext_id $mailbox_host_name
    append src_ext_id "-" $imap_uidvalidity
    set aml_src_id ""
    db_0or1row acs_mail_lite_email_src_ext_id_map_r1 \
        -cache_key aml_in_src_id_${src_ext_id} {
            select aml_src_id from acs_mal_lite_email_src_ext_id_map
            where src_ext=:src_ext_id }
    if { $aml_src_id eq "" } {
        set aml_src_id [db_nextval acs_mail_lite_in_id_seq]
        db_dml acs_mail_lite_email_src_ext_id_map_c1 {
            insert into acs_mail_lite_src_ext_id_map
            (aml_src_id,src_ext)
            values (:aml_src_id,:src_ext_id)
        }
    }
    set aml_email_id ""
    db_0or1row acs_mail_lite_email_uid_id_map_r1 {
        select aml_email_id from acs_mail_lite_email_uid_id_map
        where uid_ext=:email_uid
        and src_ext_id=:src_ext_id
    }
    if { $aml_email_id eq "" } {
        set aml_email_id [db_nextval acs_mail_lite_in_id_seq]
        db_dml acs_mail_lite_email_uid_id_map_c1 {
            insert into acs_mail_lite_uid_id_map
            (aml_email_id,uid_ext,src_ext_id)
            values (:aml_email_id,:email_uid,:aml_src_id)
        }
    } else {
        set hit_p 1
    }
    return $hit_p
}

ad_proc -private acs_mail_lite::section_ref_of {
    section_id
} {
    Returns section_ref represented by section_id.
    Section_id is an integer. 
    Section_ref has format of counting numbers separated by dot.
    First used here by ns_imap body and adopted for general email part refs.

    Defaults to empty string (top level reference and a log warning) 
    if not found.
} {
    set section_ref ""
    set exists_p 0
    if { [ad_var_type_check_integer_p $section_id] } {
        if { $section_id eq "-1" } {
            set exists_p 1
        } else {
            
            set exists_p [db_0or1row acs_mail_lite_ie_section_rer_map_r_id1 {
                select section_ref 
                from acs_mail_lite_ie_section_ref_map
                where section_id=:section_id
            } ]
        }
    }
    if { !$exists_p } {
        ns_log Warning "acs_mail_lite::section_ref_of '${section_id}' not found."
    }
    return $section_ref
}

ad_proc -private acs_mail_lite::section_id_of {
    section_ref
} {
    Returns section_id representing a section_ref.
    Section_ref has format of counting numbers separated by dot.
    Section_id is an integer. 
    First used here by ns_imap body and adopted for general email part refs.
} {
    set section_id ""
    if { [regexp -- {^[0-9\.]*$} $section_ref ] } {
        # Are dots okay in db cache keys? Assume not? Assume can. Test 2 know
        
        if { $section_ref eq "" } {
            set section_id -1
        } else {
            set ckey aml_section_ref_
            append ckey $section_ref
            set exists_p [db_0or1row -cache_key $ckey \
                              acs_mail_lite_ie_section_ref_map_r1 {
                                  select section_id 
                                  from acs_mail_lite_ie_section_ref_map
                                  where section_ref=:section_ref
                              } ]
            if { !$exists_p } {
                db_flush_cache -cache_key_pattern $ckey
                set section_id [db_nextval acs_mail_lite_in_id_seq]
                db_dml acs_mail_lite_ie_section_ref_map_c1 {
                    insert into acs_mail_lite_ie_section_ref_map
                    (section_ref,section_id)
                    values (:section_ref,:section_id)
                }
            }
        }
    }
    return $section_id
}

#            
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:

