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
    First implementation requires IMAP.
    The code is general enough to be adapted to any email source.
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
