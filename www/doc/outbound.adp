<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>@title@</h1>

  <p>
    Email is sent via sendmail or SMTP. If SMTP is not configured,
    sendmail is assumed.
  </p><p>
    A bounce management system is available for tracking accounts with
    email that have issues receiving email. 
  </p><p>
    Email can be sent immediately
    or placed in an outgoing queue that
    is processed at regular intervals.
    Package parameter <code>sendImmediatelyP</code> sets the default.
  </p><p>
    If sending fails, mail to send is put in the outgoing queue
    again. The queue is processed every few minutes.
  </p><p>
    Each outbound email contains an
    "<code>X-Envelope-From &lt;address@IncomingDomain&gt;</code>" header.
    The address part consists of values from package parameter
    <code>EvenlopePrefix</code>
    followed by the email sender's <code>user_id</code>, a hashkey,
    and the <code>package_id</code> of the
    package instance that is sending the email.
    The address components are separated by a dash ("-").
    <code>IncomingDomain</code> refers to the value of package parameter <code>IncomingDomain</code>.
  </p>
