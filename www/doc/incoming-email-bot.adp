<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>@title@</h1>

  <p>
    Incoming E-Mail Bot is designed to handle more email faster.
    It prioritizes incoming email from a variety of sources 
    into a queue for processing and triggering callbacks.
  </p>
  <p>
    Incoming E-mail Bot works with the latest version of acs-mail-lite
    in a general fashion using callbacks.
  </p>
  <p>IMAP is required to use the first implementation of E-Mail Bot.
    See 
    <a href="/api-doc/proc-view?proc=acs_mail_lite::imap_check_incoming&source_p=1">acs_mail_lite::imap_check_incoming</a> 
    for details.
    The code is designed to be general enough to adapt to any email source.
    It's anticipated that
    <code>acs_mail_lite::imap_check_incoming</code>
    will be replaced with a more general
    <code>acs_mail_lite::inbound_check</code>
    as more sources are integrated.
  </p>
  <p>
    New email can be processed by setting the package parameter 
    <code>IncomingFilterProcName</code> to
    the name of a custom filter that examines headers 
    of each email and assigns a
    <code>package_id</code> based on custom criteria.
  </p>
  <p>
    Incoming attachments are placed in folder acs_root_dir/acs-mail-lite
    since emails are queued. 
    Attachments might need to persist passed a system reset, 
    which may clear a standard system tmp directory used by ad_tmpdir.
    Note that this is different than value provided by parameter
    FilesystemAttachmentsRoot. 
    FilesystemAttachmentsRoot is for outbound attachments.
  </p>
  <p>
    A callback is subsequently triggered. Packages with a 
    registered callback process the email.
  </p>
  <p>
    When callbacks are finished, email is marked for removal
    at a regular interval.
  </p>
