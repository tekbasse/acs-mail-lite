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
  <p>
    Check nsv_set acs_mail_lite_scan_replies_active_p when running new cycle.
    Also set replies_next_start_est to clock seconds for use with time calcs later in cycle.
    If already running, wait a second, check again.. until 90% of duration has elapsed.
    If still running, log a message and quit in time for next event.
  </p>
  <p>
    Each scheduled event should also use as much time as it needs up to the cut-off at the next scheduled event.
    Ideally, it needs to forecast if it is going to go overtime with processing of the next email, and quit just before it does.
  </p>
  <p>
    One could track the duration of each process of most recent (up to) 1000 emails with persistence via nsv_lappend duration_list.
    Use the info to determine a time adjustment for quiting before next cycle:
    nsv_set acs_mail_lite_scan_replies_est_dur_per_cycle
  </p>
  <p>
    And yet, predicting the duration of the future process is difficult.
    What if the email is 10MB and needs parsed, whereas all prior emails were less then 10kb?
  </p>
  <p>
    If next cylce starts and current cycle is still running,
    set acs_mail_lite_scan_replies_est_dur_per_cycle_override to actual wait time the current cycle has to wait.
  </p>
  <p>
    Each subsquent cycle moves toward renormalization by adjusting acs_mail_lite_scan_replies_est_dur_per_cycle_override toward acs_mail_lite_scan_replies_est_dur_per_cycle
    by one acs_mail_lite_scan_replies_est_dur_per_cycle, with min at acs_mail_lite_scan_replies_est_dur_per_cycle.
  </p>
  <p>
    For acs_mail_lite::scan_replies,
  </p>
  <p>
    When quitting current scheduled event, don't log out if all processes are not done, or imaptimeout is greater than duration to estimate of next event.
   
    Stay logged in for next cycle.
  </p>
  <p>
    
