<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>@title@</h1>
  <p>
    Incoming email can come from a variety of sources. 
    Currently there are these distinct paradigms for setting up return email:
    </p>
  <ol>
    <li>
      A fixed outbound email address. FixedSenderEmail parameter defines
      the email address used. Each package sending email can create
      and set its own FixedSenderEmail parameter. The default
      is to use ACS-Mail-Lite's parameter. 
      As an originating smtp agent, orignator is set to the
      ACS-Mail-Lite's parameter, if it is not empty.
      The replying email's message-id is used to reference any mapped
      information about the email, such as package_id or object_id.
      The message-id includes a signed signature to detect and reject
      a tampered message-id.
    </li><li>
      A dynamic originator address that results in a custom return
      email address for each outbound email. 
      This provides an alternate way to supply the original message_id key, 
      if the message_id key is altered.
    </li>
  </ol>
  <p>
  <h3>IMAP</h3>
  <p>After <a href="imap-install">installing nsimap</a>, setup consists of filling out the relevant parameters in the acs-mail-lite package, mainly: BounceDomain, FixedSenderEmail and the IMAP section.
</p>
  <h3>postfix MailDir on Linux OS</h3>
  <p>
    Here is a how-to guide setting up a system using postfix in a Linux OS.
  </p>

  <p>
    First, one must have an understanding of postfix basics. See <a  href='http://www.postfix.org/BASIC_CONFIGURATION_README.html'>http://www.postfix.org/BASIC_CONFIGURATION_README.html</a>.
  </p>

  <p>
    These instructions use the following example values:
  </p>

  <ul>
	<li>hostname: www.yourserver.com</li>
	<li>oacs user: service0</li>
	<li>OS: Linux</li>
	<li>email user: service0</li>
	<li>email&#39;s home dir: /home/service0</li>
	<li>email user&#39;s mail dir: /home/service0/MailDir</li>
  </ul>

  <p>
    Important: The email user service0 does not have a &quot;.forward&quot; file. This user is only used for running the OpenACS website. Follow careful use of email rules by following strict guidelines to avoid email looping back unchecked.
  </p>

  <p>
    For postfix, the email user and oacs user do not have to be the same. Furthermore, postfix makes distinctions between <a  href='http://www.postfix.org/VIRTUAL_README.html'>virtual users and user aliases</a>.  Future versions of this documentation should use examples with different names to help distinguish between <a  href='http://www.postfix.org/STANDARD_CONFIGURATION_README.html'>standard configuration examples</a> and the requirements of ACS Mail Lite package.
  </p>

  <p>
    Postfix configuration parameters:
  </p>

  <pre>
    myhostname=www.yourserver.com

    myorigin=$myhostname

    inet_interfaces=$myhostname, localhost

    mynetworks_style=host

    <a  href='http://www.postfix.org/postconf.5.html#virtual_alias_domains'>virtual_alias_domains</a> = www.yourserver.com

    <a  href='http://www.postfix.org/postconf.5.html#virtual_maps'>virtual_maps</a>=regexp:/etc/postfix/virtual

    home_mailbox=MailDir/</pre>




  <p>
    Here is the sequence to follow if installing email service on system for first time. If your system already has email service, adapt these steps accordingly:
  </p>

  <ol>
	<li>Install postfix</li>
	<li>Install smtp (for postfix)</li>
	<li>Install metamail (for acs-mail-lite)</li>
	<li>Edit /etc/postfix/main.cf
      <ul><li>Set "recipient_delimiter" to " - "</li>
        <li>Set "home_mailbox" to "Maildir/"
        </li>
        <li>Make sure that /etc/postfix/aliases is hashed for the alias database
        </li>
      </ul>
    </li>
    <li>Edit /etc/postfix/aliases. Redirect all mail to "bounce". If you're only running one server, using user "nsadmin" maybe more convenient.
      In case of multiple services on one system, create a bounce email for each of them by changing "bounce" to "bounce_service1", bounce_service2 et cetera.
      Create a new user that runs the NaviServer process for each of them.
      You do not want to have service1 deal with bounces for service2.

    </li>
    <li>Edit <a  href='http://www.postfix.org/virtual.5.html'>/etc/postfix/virtual</a>.
      Add a regular expression to filter relevant incoming emails for processing by OpenACS. 
	  <code>@www.yourserver.com service0</code>
	</li>
	<li>Edit /etc/postfix/master.cf
      Uncomment this line so postfix listens to emails from internet:
	  <code>smtp inet n - n - - smtpd</code>
	</li>
	<li>Create a mail directory as service0
	  <code>mkdir /home/service0/mail</code>
	</li>
	<li>Configure ACS Mail Lite parameters
	  <code>BounceDomain: www.yourserver.com<br />
	    BounceMailDir: /home/service0/MailDir<br />
	    EnvelopePrefix: bounce<br />
	    <br />
	    The EnvelopePrefix is for bounce e-mails only.<br />
	    <br />
	    NOTE: Parameters should be renamed: <br />
	    BounceDomain to IncomingDomain<br />
	    BounceMailDir to IncomingMaildir<br />
	    EnvelopePrefix to BouncePrefix<br />
	    ..to reflect that acs-mail-lite is capable of dealing with other types of incoming e-mail.<br />
	    <br />
	    Furthermore, setting IncomingMaildir parameter clarifies that incoming email handling is setup. This is useful for other packages to determine if they can rely on incoming e-mail working (e.g. to set the reply-to email to an  e-mail address which actually works through a callback if the IncomingMaildir parameter is enabled).</code>
	</li>
	<li>Configure Notifications parameters
	  <code>EmailReplyAddressPrefix: notification<br />
	    EmailQmailQueueScanP: 0<br />
	    <br />
	    We want acs-mail-lite incoming handle the Email Scanning, not each package separately.</code>
	  Configure other packages likewise<br />
	</li>
	<li>Invoke postmap in OS shell to recompile virtual db:
	  <code>postmap /etc/postfix/virtual</code>
	</li>
	<li>Restart Postfix. 
	  <code>/etc/init.d/postfix restart</code>
	</li>
	<li>Restart OpenACS</li>
  </ol>

