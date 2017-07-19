<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>@title@</h1>
<h3>Public API</h3>
<table cellspacing="0" cellpadding="0">
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::address_domain">acs_mail_lite::address_domain</a></strong></td>
    <td>Propose removing. Redundant code. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::autoreply_p">acs_mail_lite::autoreply_p</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Parse the subject, from and body to determin if the email is an auto reply
	Typical autoreplies are &#34;Out of office&#34; messages.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::bounce_address">acs_mail_lite::bounce_address</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Composes a bounce address&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::bouncing_email_p">acs_mail_lite::bouncing_email_p</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Checks if email address is bouncing mail&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::bouncing_user_p">acs_mail_lite::bouncing_user_p</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Checks if email address of user is bouncing mail&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::generate_message_id">acs_mail_lite::generate_message_id</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Generate an id suitable as a Message-Id: header for an email.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::get_package_id">acs_mail_lite::get_package_id</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::get_parameter">acs_mail_lite::get_parameter</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Returns an apm-parameter value of this package&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::parse_bounce_address">acs_mail_lite::parse_bounce_address</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>This takes a reply address, checks it for consistency,
        and returns a list of user_id, package_id and bounce_signature found&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::parse_email">acs_mail_lite::parse_email</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>An email is splitted into several parts: headers, bodies and files lists and all headers directly.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::parse_email_address">acs_mail_lite::parse_email_address</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Extracts the email address out of a mail address (like Joe User &lt;joe@user.com&gt;)&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::record_bounce">acs_mail_lite::record_bounce</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Records that an email bounce for this user&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::scan_replies">acs_mail_lite::scan_replies</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Scheduled procedure that will scan for bounced mails&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::send">acs_mail_lite::send</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Prepare an email to be send with the option to pass in a list
        of file_ids as well as specify an html_body and a mime_type.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::utils::build_body">acs_mail_lite::utils::build_body</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Encode the body using quoted-printable and build the alternative
    part if necessary

    Return a list of message tokens&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::utils::build_date">acs_mail_lite::utils::build_date</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Depending on the available mime package version, it uses either
    the mime::parsedatetime to do it or local code (parsedatetime is
    buggy in mime &lt; 1.5.2 )&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::utils::build_subject">acs_mail_lite::utils::build_subject</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Encode the subject, using quoted-printable, of an email message 
    and trim long lines.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::utils::valid_email_p">acs_mail_lite::utils::valid_email_p</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Checks if the email is valid.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::valid_signature">acs_mail_lite::valid_signature</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Validates if provided signature matches message_id&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=callback::acs_mail_lite::email_form_elements::contract">callback::acs_mail_lite::email_form_elements::contract</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=callback::acs_mail_lite::files::contract">callback::acs_mail_lite::files::contract</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=callback::acs_mail_lite::incoming_email::contract">callback::acs_mail_lite::incoming_email::contract</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Callback that is executed for incoming e-mails if the email is *NOT* like $object_id@servername&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=callback::acs_mail_lite::incoming_email::impl::acs-mail-lite">callback::acs_mail_lite::incoming_email::impl::acs-mail-lite</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Implementation of the interface acs_mail_lite::incoming_email for acs-mail-lite.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=callback::acs_mail_lite::incoming_object_email::contract">callback::acs_mail_lite::incoming_object_email::contract</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Callback that is executed for incoming e-mails if the email is like $object_id@servername&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=callback::acs_mail_lite::send::contract">callback::acs_mail_lite::send::contract</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Callback for executing code after an email has been send using the send mechanism.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=ns_sendmail">ns_sendmail</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Replacement for ns_sendmail for backward compability.&nbsp;</td>
  </tr>
  
</table>

  <h3>Private procs</h3>
  <table cellspacing="0" cellpadding="0">
  
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::after_upgrade">acs_mail_lite::after_upgrade</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>After upgrade callback for acs-mail-lite&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::bounce_prefix">acs_mail_lite::bounce_prefix</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::check_bounces">acs_mail_lite::check_bounces</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Daily proc that sends out warning mail that emails
        are bouncing and disables emails if necessary&nbsp;</td>
  </tr>

  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::get_address_array">acs_mail_lite::get_address_array</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Checks if passed variable is already an array of emails,
        user_names and user_ids.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::load_mails">acs_mail_lite::load_mails</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Scans for incoming email.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::log_mail_sending">acs_mail_lite::log_mail_sending</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Logs mail sending time for user&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::mail_dir">acs_mail_lite::mail_dir</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::message_interpolate">acs_mail_lite::message_interpolate</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Interpolates a set of values into a string.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::send_immediately">acs_mail_lite::send_immediately</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Prepare an email to be send immediately with the option to pass in a list
        of file_ids as well as specify an html_body and a mime_type.&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::smtp">acs_mail_lite::smtp</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Send messages via SMTP&nbsp;</td>
  </tr>
  
  <tr valign="top">
    <td class="wide"><strong><a href="/api-doc/proc-view?source_p=1&version_id=&amp;proc=acs_mail_lite::sweeper">acs_mail_lite::sweeper</a></strong></td>
    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td>Send messages in the acs_mail_lite_queue table.&nbsp;</td>
  </tr>
  
</table>

  <h3>New procs</h3>
  <p>For imap, each begin of a process should not assume a connection exists or doesn't exist. Check connection using 'imap ping' before login.
    This should help re-correct any connection drop-outs due to intermittent or one-time connection issues.
  </p>
  <p>Each scheduled event should quit in time for next process, so that imap info being processed is always nearly up-to-date.
    This is important in case a separate manual imap process is working in tandem and changing circumstances.
    This is equally important to quit in time, because imap references relative sequences of emails.
    Two concurrent connections would likely have different and overlapping references.
    The overlapping references would likely cause issues, since each connection would expect to process
    the duplicates as if they are not duplicates.
  </p>
  <h4>nsv inter-procedure array acs_mail_lite indexes</h4>
  <pre>example usage:
    nsv_set acs_mail_lite scan_replies_active_p 0
  </pre>
<h3>variables useful while exploring new processes like forecasting and scheduling</h3>
  <dl>
    <dt>scan_replies_active_p</dt>
    <dd>Answers question. Is a proc currently scanning replies?</dd>

    <dt>replies_est_next_start</dt>
    <dd>Approx value of [clock seconds] next scan is expected to begin</dd>

    <dt>duration_ms_list</dt>
    <dd>Tracks duration of processing of each email in ms of most recent process, appended as a list.
      When a new process starts processing email, the list is reset to only include the last 100 emails. That way, there is always rolling statistics for forecasting process times.</dd>

    <dt>scan_replies_est_dur_per_cycle_s</dt>
    <dd>Estimate of duration of current cycle</dd>

    <dt>scan_replies_est_quit_time_cs</dt>
    <dd>When the current cycle should quit based on [clock seconds]</dd>

    <dt>scan_replies_start_time_cs</dt>
    <dd>When the current cycle started scanning based on [clock seconds]</dd>

    <dt>cycle_start_time_cs</dt>
    <dd>When the current cycle started (pre IMAP authorization etc) based on [clock seconds]</dd>

    <dt>cycle_est_next_start_time_cs</dt>
    <dd>When the next cycle is to start (pre IMAP authorization etc) based on [clock seconds]</dd>

    <dt>parameter_val_changed_p</dt>
    <dd>If related parameters change, performance tuning underway. Reset statistics.</dd>

    <dt>scan_replies_est_dur_per_cycle_s_override</dt>
    <dd>If this value is set, use it instead of the <code>scan_replies_est_dur_per_cycle_s</code></dd>

    <dt>accumulative_delay_cycles</dt>
    <dd>Number of cycles that have been skipped 100% due to ongoing process (in cycles).</dd>
      
    
  </dl>
  <p>
    Check <code>scan_replies_active_p</code> when running new cycle.
    Also set <code>replies_est_next_start</code> to clock seconds for use with time calcs later in cycle.
    If already running, wait a second, check again.. until 90% of duration has elapsed.
    If still running, log a message and quit in time for next event.
  </p>
  <p>
    Each scheduled procedure should also use as much time as it needs up to the cut-off at the next scheduled event.
    Ideally, it needs to forecast if it is going to go overtime with processing of the next email, and quit just before it does.
  </p>
  <p>
    Use <code>duration_ms_list</code> to determine a time adjustment for quiting before next cycle:
    <code>scan_replies_est_dur_per_cycle_s</code> + <code>scan_repies_start_time</code> =
    <code>scan_replies_est_quit_time_cs</code>
  </p>
  <p>
    And yet, predicting the duration of the future process is difficult.
    What if the email is 10MB and needs parsed, whereas all prior emails were less then 10kb?
    What if one of the callbacks converts a pdf into a png and annotates it for a web view and takes a few minutes?
    What if the next 5 emails have callbacks that take 5 to 15 minutes to process each waiting on an external service?
  </p>
  <p>The process needs to be split into at least two to handle all cases. Using this paradigm, parallel processes could be invoked without significantly changing the paradigm.
  </p><p>
    The first process collects incoming email and puts it into a system standard format with a minimal amount of effort sufficient for use by callbacks. The goal of this process is to keep up with incoming email to all mail available to the system at the earliest possible moment.
  </p><p>
    The second process should render a prioritized stack of imported email that have not been processed. First prioritizing new entries, perhaps re-prioritizing any callbacks that error or sampling re-introducing prior errant callbacks etc. then continuing to process the stack. 
  </p>
  <p>To reduce overhead on low volume systems, these processes should be scheduled to minimize concurrent operation.
  </p>
  <p>Priorities should offer 3 levels of performance. Colors designate priority to discern from other email priority schemes:</p>
  <ul><li>
      High (abbrev: hpri, Fast Priority, a priority value 1 to mpri_min  (default 999): allow concurrent processes. That is, when a new process starts, it can also process unprocessed cases. As the stack grows, processes run in parallel to reduce stack up to acs_mail_lite_ui.max_concurrent.
    </li><li>
      Med (abbrev: mpri, Standard Priority, a priority mpri_min to mpri_max (default 9999)): Process one at a time with casual overlap. (Try to) quit before next process starts. It's okay if there is a little overlapping.
    </li><li>
      Low (abbrev: lpri, Low Priority, a priority value over mpri_max): Process one at a time only. If a new cycle starts and the last is still running, wait for it to quit (or quit before next cycle).
  </li></ul>

<p>Priority is calculated based on timing and file size</p>
<pre> 
set max_min_diff priority_max - priority_min
set range { ($max_min_diff / 2 }
set midpoint { priority_min + $range }
time_priority =  $range (  clock seconds of received datetime - scan_replies_start_time_cs ) / 
            ( 2 * scan_replies_est_dur_per_cycle_s )
if { expr abs(time_priority) > $range } { set time_priority priority_midpoint +  sign($time_priority) *$range }

size_priority = 
   $range * ((  (size of email in characters)/(config.tcl's max_file_upload_mb *1000000) ) - 0.5)

set equation = int( $midpoint + ($time_priority + size_priority) / 2)
</pre>
<p>Average of time and file size priorities. </p>
<p>hpri_pkg_ids and lpri_pkg_ids and hpri_party_ids and lpri_party_ids and mpri_min and mpri_max and hpri_subject_glob and lpri_subject_glob are defined in acs_maile_lite_ui, so they can be tuned without restarting server. ps. Code should check if user is banned before parsing any further.</p>
<p>A proc should be available to recalculate existing email priorities. This means more info needs to be added to table acs_mail_lite_from_external (including size_chars)</p>
  <h3>Import Cycle</h3>
  <p>This scheduling should be simple.  Maybe check if a new process wants to take over. If so, quit.</p>
  
  <h3>Prioritized stack processing cycle</h3>
  <p>
    If next cylce starts and current cycle is still running,
    set <code>scan_replies_est_dur_per_cycle_s_override</code> to actual wait time the current cycle has to wait including any prior cycle wait time --if the delays exceed one cycle (<code>accumulative_delay_cycles</code>.
  </p>
  <pre>From acs-tcl/tcl/test/ad-proc-test-procs.tcl
    # This example gets list of implimentations of a callback: (so they could be triggered one by one)
     ad_proc -callback a_callback { -arg1 arg2 } { this is a test callback } -
    set callback_procs [info commands ::callback::a_callback::*]
    
  </pre>
  <p>
    Each subsquent cycle moves toward renormalization by adjusting
    <code>scan_replies_est_dur_per_cycle_s_override</code> toward value of
    <code>scan_replies_est_dur_per_cycle_s</code> by one
    <code>replies_est_dur_per_cycle</code> with minimum of
    <code>scan_replies_est_dur_per_cycle_s</code>.
    Changes are exponential to quickly adjust to changing dynamics.
  </p>
  <p>
    For acs_mail_lite::scan_replies,
  </p><p>
    Keep track of email flags while processing.<br/>
    Mark /read when reading.<br/>
    Mark /replied if replying.
  </p>
  <p>
    When quitting current scheduled event, don't log out if all processes are not done.
    Also, don't logout if <code>imaptimeout</code> is greater than duration to <code>cycle_est_next_start_time_cs</code>.
   
    Stay logged in for next cycle.
  </p>
  <p>
    Delete processed messages when done with a cycle?
    No. What if message is used by a callback with delay in processing?
    Move processed emails in a designated folder ProcessFolderName parameter.
    Designated folder may be Trash.
    Set ProcessFolderName by parameter If empty, Default is hostname of ad_url ie:
    [util::split_location [ad_url] protoVar ProcessFolderName portVar]
    If folder does not exist, create it. ProcessFolderName only needs checked if name has changed.
    </p>

  <h4>
    Email attachments
    </h4>
  <p>
   Since messages are not immediately deleted, create a table of attachment url references. Remove attachments older than AttachmentLife parameter seconds.
   Set default to 30 days old (2592000 seconds).
   Unless ProcessFolderName is Trash, email attachments can be recovered by original email in ProcessFolderName.
    </p>
