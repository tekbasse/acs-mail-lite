ad_library {

    initialization for acs_mail_lite module

    @author Eric Lorenzo (eric@openforce.net)
    @creation-date 22 March, 2002
    @cvs-id $Id: acs-mail-lite-init.tcl,v 1.14.2.1 2015/09/10 08:21:31 gustafn Exp $

}

# Default interval is about one minute (reduce lock contention with other jobs scheduled at full minutes)
ad_schedule_proc -thread t 61 acs_mail_lite::sweeper

set queue_dir [parameter::get_from_package_key -parameter "BounceMailDir" -package_key "acs-mail-lite"]

if {$queue_dir ne ""} {
    # if BounceMailDir is set then handle incoming mail
    ad_schedule_proc -thread t 120 acs_mail_lite::load_mails -queue_dir $queue_dir
}

# check every few minutes for new email to filter and maybe flag for parsing.
#ad_schedule_proc -thread t [acs_mail_lite::get_parameter -name IncomingScanQueue -default 120] acs_mail_lite::scan_replies

# Scan incoming start time in clock seconds.
set scan_in_start_time_cs [clock seconds]
# Scan incoming estimated duration pur cycle in seconds
set scan_in_est_dur_per_cycle_s 120
# check every few minutes for new email to filter and maybe flag for parsing.
##code ad_schedule_proc -thread t [acs_mail_lite::get_parameter -name IncomingScanQueue -default 120] acs_mail_lite::scan_incoming


nsv_set acs_mail_lite send_mails_p 0
nsv_set acs_mail_lite check_bounce_p 0
# Used by incoming email system
nsv_set acs_mail_lite scan_in_start_t_cs $scan_in_start_time_cs
nsv_set acs_mail_lite scan_in_est_dur_p_cycle_s $scan_in_est_dur_per_cycle_s


ad_schedule_proc -thread t \
    $scan_in_est_dur_per_cycle_s acs_mail_lite::imap_check_incoming
# acs_mail_lite::imap_check_incoming was acs_mail_lite::check_bounces:
# ad_schedule_proc -thread t -schedule_proc ns_schedule_daily [list 0 25] acs_mail_lite::check_bounces

if { [db_table_exists acs_mail_lite_ui] } {
    acs_mail_lite::sched_parameters
}


# Redefine ns_sendmail as a wrapper for acs_mail_lite::send
#ns_log Notice "acs-mail-lite: renaming acs_mail_lite::sendmail to ns_sendmail"
#rename ns_sendmail _old_ns_sendmail
#rename acs_mail_lite::sendmail ns_sendmail

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
