ad_library {
    Automated tests for acs-mail-lite/tcl/email-inbound
    @creation-date 2017-07-19
}

aa_register_case -cats {api smoke} acs_mail_lite_inbound_procs_check {
    Test acs-mail-lite procs in email-inbound-procs.tcl 
} {
    aa_run_with_teardown \
        -rollback \
        -test_code {

           ns_log Notice "aa_register_case:acs_mail_lite_inbound_procs_check"

            set a_list [acs_mail_lite::sched_parameters]
            array set params_def $a_list

            set bools_list [list reprocess_old_p]
            set integer_list [list sredpcs_override max_concurrent \
                             max_blob_chars mpri_min mpri_max]
            set ints_list [list hpri_package_ids lpri_package_idx hpri_party_ids lpri_party_ids hpri_object_ids lpri_object_ids]
            set globs_list [list hpri_subject_glob lpri_subject_glob]
            set bools_v_list [list 0 1 t f true false]
            foreach p [array names params_def] {
                # test setting of each parameter separately
                set param "-"
                append param $p
                if { $p in $bools_list } {
                    set val_idx [randomRange 5]
                    set val [lindex $bools_v_list $val_idx]
                } elseif { $p in $integer_list } {
                    set val [randomRange 32767]
                } elseif { $p in $ints_list } {
                    set nums_list [list]
                    set up_to_10 [randomRange 10]
                    for {set i 0} {$i < $up_to_10 } {incr i} {
                        lappend nums_list [randomRange 32767]
                    }
                    set val [join $nums_list " "]
                } 
                aa_log "r41. Testing change of parameter '${p}' from \
 '$params_def(${p})' to '${val}'"
                
                set b_list [acs_mail_lite::sched_parameters $param $val]
                aa_log "param $param val $val b_list $b_list"
                array unset params_new
                array set params_new $b_list
                foreach pp [array names params_def] {
                    if { $pp eq $p } {
                        if { $pp in $bools_list } {
                            aa_equals "r48 Changed sched_parameter '${pp}' \
  value '$params_def(${pp})' to '${val}' set" \
                                [template::util::is_true $params_new(${pp})] \
                                [template::util::is_true $val]
                        } else {
                            if { $params_new(${pp}) eq $params_def(${pp}) } {
                                if { $pp eq "mpri_max" \
                                         && $val < $params_def(mpri_min) } {
                                    aa_log "r54 mpri_max<mpri_min no change"
                                } elseif { $pp eq "mpri_min" \
                                               && $val > $params_def(mpri_max) } {
                                    aa_log "r55 mpri_min>mpri_max no change."
                                }
                            } else {
                                aa_equals "r56 Changed sched_parameter \
 '${pp}' value '$params_def(${pp})' to '${val}' set" $params_new(${pp}) $val
                                
                            }
                        }
                    } else {
                        if { $pp in $bools_list } {
                            aa_equals "r62 Unchanged sched_parameter '${pp}' \
  value '$params_def(${pp})' to '$params_new(${pp})' set" \
                                [template::util::is_true $params_new(${pp})] \
                                [template::util::is_true $params_def(${pp})]
                        } else {
                            aa_equals "r67 Unchanged sched_parameter '${pp}' \
  value '$params_def(${pp})' to '$params_new(${pp})' set" \
                                $params_new(${pp}) $params_def(${pp})
                        }
                    }
                }
                array set params_def $b_list
            }

            set instance_id [ad_conn package_id]
            set sysowner_email [ad_system_owner]
            set sysowner_user_id [party::get_by_email -email $sysowner_email]
            set user_id [ad_conn user_id]
            set package_ids [list $instance_id]
            set party_ids [util::randomize_list \
                               [list $user_id $sysowner_user_id]]
            set object_ids [concat \
                                $party_ids \
                                $package_ids \
                                $user_id \
                                $sysowner_user_id]
            set priority_types [list \
                                    package_ids \
                                    party_ids \
                                    glob_str \
                                    object_ids]
            set lh_list [list l h]
            set subject [ad_generate_random_string]
            set su_glob "*"
            append su_glob [string range $subject [randomRange 8] end]
 
            foreach p_type $priority_types {

                # reset prameters
                foreach {n v} $a_list {
                    #set $n $v
                    set p "-"
                    append p $n
                    aa_log "r106 resetting p '${p}' to v '${v}'"
                    set b_list [acs_mail_lite::sched_parameters $p $v]
                }

                # set new case of parameters
                set r [randomRange 10000]
                set p_min [expr { $r + 999 } ]
                set p_max [expr { $p_min * 1000 + $r } ]
                set su_max $p_max
                append su_max "00"

                set c_list [acs_mail_lite::sched_parameters \
                                -mpri_min $p_min \
                                -mpri_max $p_max]
                array set c_arr $c_list
                set p_min $c_arr(mpri_min)
                set p_max $c_arr(mpri_max)

                aa_log "r115 p_min '${p_min}' p_max '${p_max}'"


                set i 0
                set p_i [lindex $priority_types $i]
                while { $p_i ne $p_type && $i < 100 } {
                    # set a random value to be ignored 
                    # with higher significance of p_type value

                    # make low or high?
                    set p [util::random_list_element $lh_list]
                    set pa "-"
                    append pa $p
                    switch -exact -- $p_i {
                        package_ids {
                            append pa "pri_package_ids"
                            set v $instance_id
                        }
                        party_ids {
                            append pa "pri_party_ids"
                            set v [join $party_ids " "]
                        }
                        glob_str {
                            append pa "pri_subject_glob"
                            set v $su_glob
                        }
                        object_ids {
                            append pa "pri_object_ids"
                            set v [join $object_ids " "]
                        }
                    }
                    aa_log "r148: pa '${pa}' v '${v}' gets overridden"
                    acs_mail_lite::sched_parameters ${pa} $v

                    incr i
                    set p_i [lindex $priority_types $i]
                }
                # What priority are we testing?
                set p [util::random_list_element $lh_list]
                aa_log "r163: Testing priority '${p}' for '${p_type}'"

                set pa "-"
                append pa $p
                switch -exact -- $p_type {
                    package_ids {
                        append pa "pri_package_ids"
                        set v $instance_id
                    }
                    party_ids {
                        append pa "pri_party_ids"
                        set v [join $party_ids " "]
                    }
                    glob_str {
                        append pa "pri_subject_glob"
                        set v $su_glob
                    }
                    object_ids {
                        append pa "pri_object_ids"
                        set v [join $object_ids " "]
                    }
                }
                aa_log "r185: pa '${pa}' v '${v}'"
                acs_mail_lite::sched_parameters ${pa} $v


                # make four tests for each priority p_arr
                # two vary in time, t1, t2
                # two vary in size, s1, s2

                set t0 [nsv_get acs_mail_lite scan_in_start_t_cs]
                set dur_s [nsv_get acs_mail_lite scan_in_est_dur_p_cycle_s]
                set s0 [ns_config -int -set -min $su_max nssock_v4 maxinput $su_max]
                aa_log "r161 given: t0 '${t0}' dur_s '${dur_s}' s0 '${s0}'"

                set t1 [expr { int( $t0 - $dur_s * 1.9 * [random]) } ]
                set t2 [expr { int( $t0 - $dur_s * 1.9 * [random]) } ]
                set s1 [expr { int( $s0 * 0.9 * [random]) } ]
                set s2 [expr { int( $s0 * 0.9 * [random]) } ]
                aa_log "r167 priorities: t1 '${t1}' t2 '${t2}' s1 '${s1}' s2 '${s2}'"
                if { $t1 < $t2 } {
                    set t $t1
                    # first in chronology = f1
                    # second in chronology = f2
                    set f1 t1
                    set f2 t2
                } else {
                    set t $t2
                    set f1 t2
                    set f2 t1
                }

                if { $s1 < $s2 } {
                    set s $s1
                    # first in priority for size = z1
                    # second in priority for size = z2
                    set z1 s1
                    set z2 s2
                } else {
                    set s $s2
                    set z1 s2
                    set z2 s1
                }
                
                set p_arr(t1) [acs_mail_lite::prioritize_in \
                                       -size_chars $s \
                                       -received_cs $t1 \
                                       -subject $subject \
                                       -package_id $instance_id \
                                       -party_id $user_id \
                                       -object_id $instance_id]
                aa_log "p_arr(t1) = '$p_arr(t1)'"

                set p_arr(t2) [acs_mail_lite::prioritize_in \
                                   -size_chars $s \
                                   -received_cs $t2 \
                                   -subject $subject \
                                   -package_id $instance_id \
                                   -party_id $user_id \
                                   -object_id $instance_id]
                aa_log "p_arr(t2) = '$p_arr(t2)'"

                set p_arr(s1) [acs_mail_lite::prioritize_in \
                                   -size_chars $s1 \
                                   -received_cs $t \
                                   -subject $subject \
                                   -package_id $instance_id \
                                   -party_id $user_id \
                                   -object_id $instance_id]
                aa_log "p_arr(s1) = '$p_arr(s1)'"

                set p_arr(s2) [acs_mail_lite::prioritize_in \
                                   -size_chars $s2 \
                                   -received_cs $t \
                                   -subject $subject \
                                   -package_id $instance_id \
                                   -party_id $user_id \
                                   -object_id $instance_id]
                
                aa_log "p_arr(s2) = '$p_arr(s2)'"

                # verify earlier is higher priority 
                if { $p_arr(${f1}) < $p_arr(${f2}) } {
                    set cron_p 1
                } else {
                    set cron_p 0
                }
                aa_true "earlier email assigned first \
 ${f1} '$p_arr(${f1})' < ${f2} '$p_arr(${f2})' " $cron_p

                # verify larger size has slower priority
                if { $p_arr(${z1}) < $p_arr(${z2}) } {
                    set size_p 1
                } else {
                    set size_p 0
                }
                aa_true "smaller email assigned first \
 ${z1} '$p_arr(${z1})' < ${z2} '$p_arr(${z2})' " $size_p

                # verify that none hit or exceed the range limit
                if { $p eq "l" } {
                    foreach j [list t1 t2 s1 s2] {
                        if { $p_arr($j) > $p_max && $p_arr($j) < $s0 } {
                            set within_limits_p 1
                        } else {
                            set within_limits_p 0
                        }
                        aa_true "r266; prioirty for case '${j}' '${p_max}' < \
  '$p_arr(${j})' < '${s0}' is within limits." $within_limits_p
                    }
                } elseif { $p eq "h" } {
                    foreach j [list t1 t2 s1 s2] {
                        if { $p_arr($j) > 0 && $p_arr($j) < $p_min } {
                            set within_limits_p 1
                        } else {
                            set within_limits_p 0
                        }
                        aa_true "r276: prioirty for case '${j}' '0' < \
  '$p_arr(${j})' < '${p_min}' is within limits." $within_limits_p
                    }


                }
            }

           set ho "localhost"
           set na "mail/INBOX"
           set ssl_p 0
           set t1 [acs_mail_lite::imap_mailbox_join \
                       -host $ho -name $na -ssl_p $ssl_p]
           set t2 {{localhost}mail/INBOX}
           aa_equals "Test acs_mail_lite::imap_mailbox_join" $t1 $t2

           set t2_list [acs_mail_lite::imap_mailbox_split $t2]
           set t1_list [list $ho $na $ssl_p]
           aa_equals "Test acs_mail_lite::imap_mailbox_split" $t1_list $t2_list


           aa_log "Testing imap open/close via default connection params"
           set conn_id [acs_mail_lite::imap_conn_close -conn_id "all"]
           set es ""

           aa_log "Following three tests pass when no imap sessions open."
           aa_false "acs_mail_lite::imap_conn_close -conn_id 'all'" $conn_id

           set conn_id [randomRange 1000]
           set t3 [acs_mail_lite::imap_conn_close -conn_id $conn_id]
           aa_false "acs_mail_lite::imap_conn_close -conn_id '${conn_id}'" $t3

           set conn_id ""
           set t3 [acs_mail_lite::imap_conn_close -conn_id $conn_id]
           aa_false "acs_mail_lite::imap_conn_close -conn_id '${conn_id}'" $t3

           aa_log "Following tests various session cases with open/close"
           aa_log "Some will fail if a session cannot be established."

           set sid [acs_mail_lite::imap_conn_go]
           set sid_p [ad_var_type_check_integer_p $sid]
           aa_true "acs_mail_lite::imap_conn_go" $sid_p

           set sid2 [acs_mail_lite::imap_conn_close -conn_id $sid]
           aa_true "acs_mail_lite::imap_conn_close -conn_id '${sid}'" $sid2

           set sid3 [acs_mail_lite::imap_conn_go -conn_id $sid]
           set sid3_p [ad_var_type_check_integer_p $sid3]
           aa_false "acs_mail_lite::imap_conn_go -conn_id '${sid}'" $sid3_p

           set sid4 [acs_mail_lite::imap_conn_go -conn_id ""]
           set sid4_p [ad_var_type_check_integer_p $sid4]
           aa_true "acs_mail_lite::imap_conn_go -conn_id ''" $sid4_p

           set sid5 "all"
           set closed_p [acs_mail_lite::imap_conn_close -conn_id $sid5]
           aa_true "acs_mail_lite::imap_conn_close -conn_id '${sid5}'" $closed_p

           aa_log "Testing for auto replies"
           aa_true "acs_mail_lite::is_autoreply_q \
 -subject '${su}' -from '${fr}' -headers '${he} 


# see Example of an IMAP LIST in rfc6154: 
# https://tools.ietf.org/html/rfc6154#page-7
# ns_imap list $conn_id $mailbox pattern(* or %) substr


#set list [ns_imap list $conn_id $mailbox_host {}]
# returns: '{} noselect'  When logged in is not successful..
# set list [ns_imap list $conn_id $mailbox_host {*}]
# returns 'INBOX {} INBOX.Trash {} INBOX.sent-mail {}' when really logged in
# and mailbox_name part of mailbox is "", and mailbox is in form {{mailbox_host}}
# set list [ns_imap list $conn_id $mailbox_host {%}]
# returns 'INBOX {}' when really logged in
# and mailbox_name part of mailbox is ""
# If mailbox_name exists and is included in mailbox_host, returns '' 
# If mailbox_name separate from mailbox_host, and exists and in place of %, returns 'mailbox {}'
# for example 'INBOX.Trash {}'





       }
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
