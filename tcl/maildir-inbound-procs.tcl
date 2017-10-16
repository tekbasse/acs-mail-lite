ad_library {

    Provides API for importing email via postfix maildir
    
    @creation-date 12 Oct 2017
    @cvs-id $Id: $

}

namespace eval acs_mail_lite {}

ad_proc -private acs_mail_lite::maildir_check_incoming {
} {
    Checks for new, actionable incoming email via Postfix MailDir standards.
    Email is actionable if it is identified by acs_mail_lite::email_type.

    When actionable, email is buffered in table acs_mail_lite_from_external
    and callbacks are triggered.

    @see acs_mail_lite::email_type

} {
    set error_p 0
    set mail_dur_fullpath [acs_mail_lite::mail_dir]
    if { $mail_dir_fullpath ne "" } { 

        set newdir $mail_dir_fullpath
        if { ![string match {/new/*} $newdir] } {
            append newdir "/new/*"
        } else {
            # Make mail_dir_fullpath generic for later /cur/.
            set mail_dir_fullpath [string range $mail_dir_fullpath 0 end-5]
        }
        
        set messages_list [glob -nocomplain $newdir]
        
        foreach msg $messages_list {
            set error_p [acs_mail_lite::maildir_email_parse \
                             -headers_arr_name hdrs_arr \
                             -parts_arr_name parts_arr \
                             -message_filepath $msg]

        }

        ##code above is maildir, below is imap.. gets translated.

    if { [nsv_exists acs_mail_lite si_configured_p ] } {
        set si_configured_p [nsv_get acs_mail_lite si_configured_p]
    } else {
        set si_configured_p 1
        # Try to connect at least once
    }
    # This proc is called by ad_schedule_proc regularly

    # scan_in_ = scan_in_est_ = scan_in_estimate = si_
    if { $si_configured_p } {
        set cycle_start_cs [clock seconds]
        nsv_lappend acs_mail_lite si_actives_list $cycle_start_cs
        set si_actives_list [nsv_get acs_mail_lite si_actives_list]
        
        set si_dur_per_cycle_s \
            [nsv_get acs_mail_lite si_dur_per_cycle_s]
        set per_cycle_s_override [nsv_get acs_mail_lite \
                                      si_dur_per_cycle_s_override]
        set si_quit_cs \
            [expr { $cycle_start_cs + int( $si_dur_per_cycle_s \
                                               * .8 ) } ]
        if { $per_cycle_s_override ne "" } {
            set si_quit_cs [expr { $si_quit_cs - $per_cycle_s_override } ]
            # deplayed
        } else {
            set per_cycle_s_override $si_dur_per_cycle_s
        }
        
        
        set active_cs [lindex $si_actives_list end]
        set concurrent_ct [llength $si_actives_list]
        # pause is in seconds
        set pause_s 10
        set pause_ms [expr { $pause_s * 1000 } ]
        while { $active_cs eq $cycle_start_cs \
                    && [clock seconds] < $si_quit_cs \
                    && $concurrent_ct > 1 } {

            incr per_cycle_s_override $pause_s
            nsv_set acs_mail_lite si_dur_per_cycle_s_override \
                $per_cycle_s_override
            set si_actives_list [nsv_get acs_mail_lite si_actives_list]
            set active_cs [lindex $si_actives_list end]
            set concurrent_ct [llength $si_actives_list]
            ns_log Notice "acs_mail_lite::imap_check_incoming.1198. \
 pausing ${pause_s} seconds for prior invoked processes to stop. \
 si_actives_list '${si_actives_list}'"
            after $pause_ms
        }

        if { [clock seconds] < $si_quit_cs \
                 && $active_cs eq $cycle_start_cs } {
            
            set cid [acs_mail_lite::imap_conn_go ]
            if { $cid eq "" } {
                set error_p 1
            }

            if { !$error_p } {

                array set conn_arr [acs_mail_lite::imap_conn_set]
                unset conn_arr(password)
                set mailbox_host_name "{{"
                append mailbox_host_name $conn_arr(host) "}" \
                    $conn_arr(name_mb) "}"

                set status_list [ns_imap status $cid]
                if { ![f::even_p [llength $status_list]] } {
                    lappend status_list ""
                }
                array set status_arr $status_list
                set uidvalidity $status_arr(Uidvalidity)
                if { [info exists status_arr(Uidnext) ] \
                         && [info exists status_arr(Messages) ] } {

                    set aml_package_id [apm_package_id_from_key "acs-mail-lite"]
                    set filter_proc [parameter::get -parameter "IncomingFilterProcName" \
                                         -package_id $aml_package_id]
                    #
                    # Iterate through emails
                    #
                    # ns_imap search should be faster than ns_imap sort
                    set m_list [ns_imap search $cid ""]

                    foreach msgno $m_list {
                        set struct_list [ns_imap struct $cid $msgno]

                        # add struct info to headers for use with ::email_type
                        # headers_arr = hdrs_arr
                        array set hdrs_arr $struct_list
                        set uid $hdrs_arr(uid)

                        set processed_p [acs_mail_lite::inbound_cache_hit_p \
                                             $uid \
                                             $uidvalidity \
                                             $mailbox_host_name ]

                        if { !$processed_p } {
                            set headers_list [ns_imap headers $cid $msgno]
                            array set hdrs_arr $headers_list
                            
                            set type [acs_mail_lite::email_type \
                                          -header_arr_name hdrs_arr ]
                            

                            # Create some standardized header indexes aml_*
                            # with corresponding values 
                            set size_idx [lsearch -nocase -exact \
                                              $headers_list size]
                            set sizen [lindex $headers_list $size_idx]
                            if { $sizen ne "" } {
                                set hdrs_arr(aml_size_chars) $hdrs_arr(${sizen})
                            } else {
                                set hdrs_arr(aml_size_chars) ""
                            }
                            
                            if { [info exists hdrs_arr(received_cs)] } {
                                set hdrs_arr(aml_received_cs) $hdrs_arr(received_cs)
                            } else {
                                set hdrs_arr(aml_received_cs) ""
                            }
                            
                            set su_idx [lsearch -nocase -exact \
                                            $headers_list subject]
                            if { $su_idx > -1 } {
                                set sun [lindex $headers_list $su_idx]
                                set hdrs_arr(aml_subject) [ad_quotehtml $hdrs_arr(${sun})]
                            } else {
                                set hdrs_arr(aml_subject) ""
                            }
                            
                            set to_idx [lsearch -nocase -exact \
                                            $headers_list to]
                            if { ${to_idx} > -1 } {
                                set ton [lindex $headers_list $to_idx]
                                set hdrs_arr(aml_to) [ad_quotehtml $hdrs_arr(${ton}) ]
                            } else {
                                set hdrs_arr(aml_to) ""
                            }
                            
                            acs_mail_lite::inbound_email_context \
                                -header_array_name hdrs_arr \
                                -headers_list $headers_list
                            
                            acs_mail_lite::inbound_prioritize \
                                -header_array_name hdrs_arr
                            
                            set error_p [acs_mail_lite::imap_email_parse \
                                             -headers_arr_name hdrs_arr \
                                             -parts_arr_name parts_arr \
                                             -conn_id $cid \
                                             -msgno $msgno \
                                             -struct_list $struct_list]

                            if { !$error_p && [string match {[a-z]*_[a-z]*} $filter_proc] } {
                                set hdrs_arr(aml_package_ids_list) [safe_eval ${filter_proc}]
                            }
                            if { !$error_p } {
                                
                                set id [acs_mail_lite::inbound_queue_insert \
                                            -parts_arr_name parts_arr 
                                        \
                                            -headers_arr_name hdrs_arr \
                                            -error_p $error_p ]
                                ns_log Notice "acs_mail_lite::imap_check_incoming \
 inserted to queue aml_email_id '${id}'"
                            }

                        }
                    }
                } else {
                    ns_log Warning "acs_mail_lite::imap_check_incoming.1274. \
 Unable to process email. \
 Either Uidnext or Messages not in status_list: '${status_list}'"
                }

                if { [expr { [clock seconds] + 65 } ] < $si_quit_cs } {
                    # Regardless of parameter SMPTTimeout,
                    # if there is more than 65 seconds to next cycle,
                    # close connection
                    acs_mail_lite::imap_conn_close -conn_id $cid
                }
                
            }
            # end if !$error
            
        } else {
            nsv_set acs_mail_lite si_configured_p 0
        }
        # acs_mail_lite::imap_check_incoming should quit gracefully 
        # when not configured or there is error on connect.

    }
    return $si_configured_p
}

ad_proc -private acs_mail_lite::imap_email_parse {
    -headers_arr_name
    -parts_arr_name
    -conn_id
    -msgno
    -struct_list
    {-section_ref ""}
    {-error_p "0"}
} {
    Parse an email from an imap connection into array array_name
    for adding to queue via acs_mail_lite::inbound_queue_insert

    Parsed data is set in headers and parts arrays in calling environment.

    struct_list expects output list from ns_imap struct conn_id msgno
} {
    # Put email in a format usable for
    # acs_mail_lite::inbound_queue_insert to insert into queue

    # for format this proc is to generate.

    # Due to the hierarchical nature of email and ns_imap struct 
    # this proc is recursive.
    upvar 1 $headers_arr_name h_arr
    upvar 1 $parts_arr_name p_arr
    upvar 1 __max_txt_bytes __max_txt_bytes
    set has_parts_p 0
    set section_n_v_list [list ]
    if { ![info exists __max_txt_bytes] } {
        set sp_list [acs_mail_lite::sched_parameters]
        set __max_txt_bytes [dict get $sp_list max_blob_chars]
    }
    if { !$error_p } {

        if { [string range $section_ref 0 0] eq "." } {
            set section_ref [string range $section_ref 1 end]
        } 
        ns_log Dev "acs_mail_lite::imap_email_parse.706 \
msgno '${msgno}' section_ref '${section_ref}'"

        # Assume headers and names are unordered

        foreach {n v} $struct_list {
            if { [string match {part.[0-9]*} $n] } {
                set has_parts_p 1
                set subref $section_ref
                append subref [string range $n 4 end]
                acs_mail_lite::imap_email_parse \
                    -headers_arr_name h_arr \
                    -parts_arr_name p_arr \
                    -conn_id $conn_id \
                    -msgno $msgno \
                    -struct_list $v \
                    -section_ref $subref
            } else {
                switch -exact -nocase -- $n {
                    bytes {
                        set bytes $v
                    }
                    disposition.filename {
                        set filename $v
                    }
                    type {
                        set type $v
                    }
                    
                    default {
                        # do nothing
                    }
                }
                if { $section_ref eq "" } {
                    set h_arr(${n}) ${v}
                } else {
                    lappend section_n_v_list ${n} ${v}
                }
            }
        }

        if { $section_ref eq "" && !$has_parts_p } {
            # section_ref defaults to '1'
            set section_ref "1"
        }

        set section_id [acs_mail_lite::section_id_of $section_ref]
        ns_log Dev "acs_mail_lite::maildir_email_parse.746 \
msgno '${msgno}' section_ref '${section_ref}' section_id '${section_id}'"

        # Add content of an email part
        set p_arr(${section_id},nv_list) $section_n_v_list
        set p_arr(${section_id},c_type) $type
        lappend p_arr(section_id_list) ${section_id}

        if { [info exists bytes] && $bytes > $__max_txt_bytes \
                 && ![info exists filename] } {
            set filename "blob.txt"
        }
        
        if { [info exists filename ] } {
            set filename2 [clock microseconds]
            append filename2 "-" $filename
            set filepathname [file join [acs_root_dir] \
                                  acs-mail-lite \
                                  $filename2 ]
            set p_arr(${section_id},filename) $filename
            set p_arr(${section_id},c_filepathname) $filepathname
            if { $filename eq "blob.txt" } {
                ns_log Dev "acs_mail_lite::maildir_email_parse.775 \
 ns_imap body '${conn_id}' '${msgno}' '${section_ref}' \
 -file '${filepathname}'"
                ns_imap body $conn_id $msgno ${section_ref} \
                    -file $filepathname
            } else {
                ns_log Dev "acs_mail_lite::imap_email_parse.780 \
 ns_imap body '${conn_id}' '${msgno}' '${section_ref}' \
 -file '${filepathname}' -decode"

                ns_imap body $conn_id $msgno ${section_ref} \
                    -file $filepathname \
                    -decode
            } 
        } elseif { $section_ref ne "" } {
            # text content
            set p_arr(${section_id},content) [ns_imap body $conn_id $msgno $section_ref]
            ns_log Dev "acs_mail_lite::imap_email_parse.792 \
 text content '${conn_id}' '${msgno}' '${section_ref}' \
 $p_arr(${section_id},content)'"
            
        } else {
            set p_arr(${section_id},content) ""
            # The content for this case
            # has been verified to be redundant.
            # It is mostly the last section/part of message.
            #
            # If diagnostics urge examining these cases, 
            # Set debug_p 1 to allow the following code to 
            # to compress a message to recognizable parts without 
            # flooding the log.
            set debug_p 0
            if { $debug_p } {
                set msg_txt [ns_imap text $conn_id $msgno ]
                # 72 character wide lines * x lines
                set msg_start_max [expr { 72 * 20 } ]
                set msg_txtb [string range $msg_txt 0 $msg_start_max]
                if { [string length $msg_txt] \
                         > [expr { $msg_start_max + 400 } ] } {
                    set msg_txte [string range $msg_txt end-$msg_start_max end]
                } elseif { [string length $msg_txt] \
                               > [expr { $msg_start_max + 144 } ] } {
                    set msg_txte [string range $msg_txt end-144 end]
                } else {
                    set msg_txte ""
                }
                ns_log Dev "acs_mail_lite::imap_email_parse.818 IGNORED \
 ns_imap text '${conn_id}' '${msgno}' '${section_ref}' \n \
 msg_txte '${msg_txte}'"
            } else {
                ns_log Dev "acs_mail_lite::imap_email_parse.822 ignored \
 ns_imap text '${conn_id}' '${msgno}' '${section_ref}'"
            }
        }

    }
    return $error_p
}

ad_proc -private acs_mail_lite::maildir_email_parse {
    -headers_arr_name
    -parts_arr_name
    {-message_fpn ""}
    {-part_id ""}
    {-section_ref ""}
    {-error_p "0"}
} {
    Parse an email from a Postfix maildir into array array_name
    for adding to queue via acs_mail_lite::inbound_queue_insert
    <br><br>
    Parsed data is set in headers and parts arrays in calling environment.
    @param message_fpn is absolute file path and name of one message
} {
    # Put email in a format usable for
    # acs_mail_lite::inbound_queue_insert to insert into queue

    # We have to generate the references for MailDir..

    # <br><pre>
    # Most basic example of part reference:
    # ref    # part
    # 1    #   message text only

    # More complex example. Order is not enforced, only hierarchy.
    # ref    # part
    # 1    #   multipart message
    # 1.1    # part 1 of ref 1
    # 1.2    # part 2 of ref 1
    # 4    #   part 1 of ref 4
    # 3.1    # part 1 of ref 3
    # 3.2    # part 2 of ref 3
    # 3.5    # part 5 of ref 3
    # 3.3    # part 3 of ref 3
    # 3.4    # part 4 of ref 3
    # 2    #   part 1 of ref 2

    # Due to the hierarchical nature of email, this proc is recursive.
    # To see examples of struct list to build, see www/doc/imap-notes.txt
    # and www/doc/maildir-test.tcl
    # reference mime procs:
    # https://www.tcl.tk/community/tcl2004/Tcl2003papers/kupries-doctools/tcllib.doc/mime/mime.html

    upvar 1 $headers_arr_name h_arr
    upvar 1 $parts_arr_name p_arr
    upvar 1 __max_txt_bytes __max_txt_bytes
    set has_parts_p 0
    set section_n_v_list [list ]
    # rfc 822 date time format regexp expression
    set r822 {[^a-z]([a-z][a-z][a-z][ ,]+[0-9]+ [a-z][a-z][a-z][ ]+[0-9][0-9][0-9][0-9][ ]+[0-9][0-9][:][0-9][0-9][:][0-9][0-9][ ]+[\+\-][0-9]+)[^0-9]}

    if { ![info exists __max_txt_bytes] } {
        set sp_list [acs_mail_lite::sched_parameters]
        set __max_txt_bytes [dict get $sp_list max_blob_chars]
    }
                
    if {[catch {set m_id [mime::initialize -file $message_fpn errmsg] } ] } {
        ns_log Error "maildir_email_parse.71 could not parse \
 message file '${msg}'"
        set error_p 1
    } else {
        # For acs_mail_lite::inbond_cache_hit_p, 
        # make a uid if there is not one. 
        set uid_ref ""
        # Do not use email file's tail, 
        # because tail is unique to system not email.
        # See http://cr.yp.to/proto/maildir.html
        
        # A header returns multiple values in a list
        # if header name is repeated in email.
        set h_list [mime::getheader $m_id]
        # headers_list 
        set headers_list [list ]
        foreach {h v} $h_list {
            switch -nocase -- $h {
                uid {
                    if { $h ne "uid" } {
                        lappend struct_list "uid" $v
                    }
                    set uid_ref "uid"
                    set uid_val $v
                }
                message-id -
                msg-id {
                    if { $uid_ref ne "uid"} {
                        if { $uid_ref ne "message-id" } {
                            # message-id is not required
                            # msg-id is an alternate 
                            # Fallback to most standard uid
                            set uid_ref [string tolower $h]
                            set uid_val $v
                        }
                    }
                }
                received {
                    if { [llength $v ] > 1 } {
                        set v0 [lindex $v 0]
                    } else {
                        set v0 $v
                    }
                    if { [regexp -nocase -- $re822 $v0 match r_ts] } {
                        set age_s [mime::parsedatetime $r_ts rclock]
                        set dt_cs [expr { [clock seconds] - $age_s } ]
                        lappend headers_list "aml_datetime_cs" $dt_cs
                    }
                }
                default { 
                    # do nothing
                }
            }
            lappend headers_list $h $v
        }
        lappend headers_list "aml_received_cs" [file mtime $file]
        lappend headers_list "uid" $uid_val
        
        # Append property_list to to headers_list
        set prop_list [mime::getproperty $m_id]
        #set prop_names_list /mime::getproperty $m_id -names/
        foreach {n v} $prop_list {
            switch -nocase -exact -- $n {
                params {
                    # extract name as header filename
                    foreach {m w} {
                        if { [string -nocase match "*name"] } {
                            regsub -all -nocase -- {[^0-9a-zA-Z-.,\_]} $w {_} w
                            if { $w eq "" } {
                                set w "untitled"
                            } 
                            set filename $w
                            lappend headers_list "filename" $w
                        } else {
                            lappend headers_list $m $w
                        }
                    }
                }
                default {
                    lappend headers_list $n $v
                }
            }
        }
        if { $section_ref eq "" } {
            set section_ref 1
        }
        set subref_ct 0
        set type ""
        # Assume headers and names are unordered
        foreach {n v} $headers_list {
            if { [string -nocase match {parts} $n] } {
                set has_parts_p 1
                foreach part_id $v {
                    incr subref_ct
                    set subref $section_ref
                    append subref "." $subref_ct
                    acs_mail_lite::maildir_email_parse \
                        -headers_arr_name h_arr \
                        -parts_arr_name p_arr \
                        -part_id $part_id \
                        -section_ref $subref
                }
            } else {
                switch -exact -nocase -- $n {
                    size {
                        set bytes $v
                    }
                    # content-type
                    content {
                        set type $v
                    }
                    default {
                        # do nothing
                    }
                }
                if { $section_ref eq "1" } {
                    set h_arr(${n}) ${v}
                } else {
                    lappend section_n_v_list ${n} ${v}
                }
            }
        }
        
        set section_id [acs_mail_lite::section_id_of $section_ref]
        ns_log Dev "acs_mail_lite::maildir_email_parse.746 \
msg '${msg}' section_ref '${section_ref}' section_id '${section_id}'"
        
        # Add content of an email part
        set p_arr(${section_id},nv_list) $section_n_v_list
        set p_arr(${section_id},c_type) $type
        lappend p_arr(section_id_list) ${section_id}
        
        if { [info exists bytes] && $bytes > $__max_txt_bytes \
                 && ![info exists filename] } {
            set filename "blob.txt"
        }
        
        if { [info exists filename ] } {
            set filename2 [clock microseconds]
            append filename2 "-" $filename
            set filepathname [file join [acs_root_dir] \
                                  acs-mail-lite \
                                  $filename2 ]
            set p_arr(${section_id},filename) $filename
            set p_arr(${section_id},c_filepathname) $filepathname
            if { $filename eq "blob.txt" } {
                ns_log Dev "acs_mail_lite::maildir_email_parse.775 \
 msg '${m_id}' '${section_ref}' \
 -file '${filepathname}'"
                set txtfileId [open $filepathname "w"]
                puts -nonewline $txtfileId [mime::getbody $m_id]
                close $txtfileId
            } else {
                ns_log Dev "acs_mail_lite::maildir_email_parse.780 \
 mime::getbody '${m_id}' '${section_ref}' \
 -file '${filepathname}' -decode"
                set binfileId [open $filepathname "w"]
                chan configure $binfileId -translation binary
                puts -nonewline $binfileId [mime::getbody $m_id -decode ]
                close $binfileId
            } 
        } elseif { $section_ref ne "" } {
            # text content
            set p_arr(${section_id},content) [mime::buildmessage $m_id]
            ns_log Dev "acs_mail_lite::maildir_email_parse.792 \
 text msg '${msg}' '${section_ref}': \
 $p_arr(${section_id},content)'"
            
        } else {
            set p_arr(${section_id},content) ""
            # The content for this case
            # has been verified to be redundant.
            # It is mostly the last section/part of message.
            #
            # If diagnostics urge examining these cases, 
            # Set debug_p 1 to allow the following code to 
            # to compress a message to recognizable parts without 
            # flooding the log.
            set debug_p 0
            if { $debug_p } {
                set msg_txt [mime::buildmessage $m_id]
                # 72 character wide lines * x lines
                set msg_start_max [expr { 72 * 20 } ]
                set msg_txtb [string range $msg_txt 0 $msg_start_max]
                if { [string length $msg_txt] \
                         > [expr { $msg_start_max + 400 } ] } {
                    set msg_txte [string range $msg_txt end-$msg_start_max end]
                } elseif { [string length $msg_txt] \
                               > [expr { $msg_start_max + 144 } ] } {
                    set msg_txte [string range $msg_txt end-144 end]
                } else {
                    set msg_txte ""
                }
                ns_log Dev "acs_mail_lite::maildir_email_parse.818 IGNORED \
 text '${msg}' '${section_ref}' \n \
 msg_txte '${msg_txte}'"
            } else {
                ns_log Dev "acs_mail_lite::maildir_email_parse.822 ignored \
 text '${msg}' '${section_ref}'"
            }
        }
    }
        return $error_p
}


                #            
                # Local variables:
                #    mode: tcl
                #    tcl-indent-level: 4
                #    indent-tabs-mode: nil
                # End:


