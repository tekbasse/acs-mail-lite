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
                    set nums ""
                    for {set i 0} {$i < [randomRange 10] } {
                        append nums " " [randomRange 32767]
                    }
                } 
                set params_initial(${p}) $val
                set b_list [acs_mail_lite::sched_parameters $param $val]
                array set params_new $b_list
                foreach ii [array names params_initial] {
                    if { $ii eq $p } {
                        aa_equal "Changed sched_parameter '${ii}' value set" \
                            $params_new(${ii}) $params_initial(${ii})
                    } else {
                        aa_equal "Unchanged sched_parameter '${ii}' same" \
                            $params_new(${ii}) $params_initial(${ii})
                    }
                }
            }
            # Use default permissions provided by tcl/q-control-init.tcl
            # Yet, users must have read access permissions or test fails
            # Some tests will fail (predictably) in a hardened system

            set instance_id [ad_conn package_id]
        }
}
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
