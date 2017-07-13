<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>@title@</h1>
  <p>
    These notes augment nsimap documentation at <a href="https://bitbucket.org/naviserver/nsimap">https://bitbucket.org/naviserver/nsimap</a>.
  </p>
  <p>Get imap from https://github.com/jonabbey/panda-imap</p>
  <p>If there are errors building panda-imap mentioning to use -fPIC. See its use in following examples.
    </p>
  <h2>Notes on installing nsimap on FreeBSD 10.3-STABLE</h2>
  <p>
    Build panda-imap with:
  </p>
  <code>gmake bsf EXTRACFLAGS=-fPIC</code>
  <p>
    Then build nsimap with:
  </p>
  <code>
    gmake NAVISERVER=/usr/local/ns IMAPFLAGS=-I../../panda-imap/c-client/ "IMAPLIBS=../../panda-imap/c-client/c-client.a -L/usr/local/ns/lib -lpam -lgssapi_krb5 -lkrb5"
  </code>
  <p>Note that NaviServer library is referenced in two places in that line,
    in case your local system locates NaviServer's installation directory elsewhere.</p>
  
  <h2>Notes on installing nsimap on Ubuntu 16.04 LTS</h2>
  <p>Install some development libraries:</p>
  <code>apt-get install libssl-dev libpam-unix2 libpam0g-dev libkrb5-dev</code>
  <p>Build panda-imap with:</p>
  <code>make ldb EXTRACFLAGS=-fPIC</code>
  <p>If your system requires ipv4 only, add the flags:
    <code>IP=4 IP6=4 SSLTYPE=nopwd</code> like this:</p>
    <code>make ldb EXTRACFLAGS=-fPIC IP=4 IP6=4 SSLTYPE=nopwd</code>
  <p>Some of these are defaults, but the defaults weren't recognized on the test system,
    so they had to be explicitely invoked in this case.</p>
  <p>
    Then build nsimap with:
  </p>
  <code>
    make NAVISERVER=/usr/local/ns IMAPFLAGS=-I../../panda-imap/c-client "IMAPLIBS=../../panda-imap/c-client/c-client.a -L/usr/local/ns/lib -lpam -lgssapi_krb5 -lkrb5"
  </code>
    <p>Note that NaviServer library is referenced in two places in that line,
    in case your local system locates NaviServer's installation directory elsewhere.</p>
