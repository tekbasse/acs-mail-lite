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
            array set params_initial $a_list

            set bools_list [list reprocess_old_p]
            set integer_list [list sredpcs_override max_concurrent \
                             max_blob_chars mpri_min mpri_max]
            set ints_list [list hpri_package_ids lpri_package_idx hpri_party_ids lpri_party_ids hpri_object_ids lpri_object_ids]
            set globs_list [list hpri_subject_glob lpri_subject_glob]
            set bools_v_list [list 0 1 t f true false]
            foreach p [array names params_initial] {
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
                aa_log "Testing change of parameter '${p}' from \
 '$params_initial(${p})' to '${val}'"
                #set params_initial(${p}) $val
                set b_list [acs_mail_lite::sched_parameters $param $val]
                array set params_new $b_list
                foreach ii [array names params_initial] {
                    if { $ii eq $p } {
                        aa_equals "Changed sched_parameter '${ii}' \
  value '$params_initial(${ii})' to '$params_new(${ii})' set" \
                            [template::util::is_true $params_new(${ii})] \
                            [template::util::is_true $params_initial(${ii})]
                    } else {
                        aa_equals "Unchanged sched_parameter '${ii}' same" \
                            [template::util::is_true $params_new(${ii})] \
                            [template::util::is_true $params_initial(${ii})]
                    }
                }
            }

            set instance_id [ad_conn package_id]
            set sysowner_email [ad_system_owner]
            set sysowner_user_id [party::get_by_email -email $sysowner_email]
            set user_id [ad_conn user_id]
            set package_ids [list $instance_id]
            set party_ids [util::randomize_list \
                               [list $user_id $sysowner_user_id]]
            set object_ids [concat $party_ids $package_ids $user_id $sysowner_user_id]
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
                    set b_list [acs_mail_lite::sched_parameters $p $v]
                }

                # set new case of parameters
                set r [randomRange 10000]
                set p_min [expr { $r + 999 } ]
                set p_max [expr { $p_threshold_min * 1000 + $r } ]
                acs_mail_lite::sched_parameters \
                    -mpri_min $p_min \
                    -mpri_max $p_max

                set i 0
                set p_i [lindex $priority_types $i]
                while { $p_i ne $p_type } {
                    # set a random value to be ignored 
                    # with higher significance of p_type value

                    # make low or high?
                    set p [util::random_list_element $lh_list]
                    set pa $p
                    switch -exact -- $p_i {
                        package_ids {
                            append pa "pri_package_ids"
                            set v $package_id
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
                    acs_mail_lite::sched_parameters ${p} $v
                    incr i
                }
                # make four low priority tests
                # two vary in time, two vary in size
                # verify earlier is higher priority 
                # verify larger size is lower priority
                # verify that none hit the range limit

                # make four high priority test
                # two vary in time, two vary in size
                # verify earlier is higher priority 
                # verify larger size is lower priority
                # verify that none hit the range limit


               
            }



        }
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
