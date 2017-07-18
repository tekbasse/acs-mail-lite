-- acs-mail-lite/sql/postgresql/upgrade/upgrade-5.9.1b3-5.9.1b4.sql
--
-- Add Incoming Mail Processing
--

-- New tables

create table acs_mail_lite_from_external (
       aml_id               integer primary key not null DEFAULT nextval ('acs_mail_lite_id_seq'), 
       -- using varchar instead of text for indexing
       to_email_addrs       varchar(1000),
       from_email_addrs     text,
       subject              text,
       party_id             integer,
       object_id            integer,
       package_id           integer
                            constraint amlq_package_id_fk
                            references apm_packages,
       aml_processed_p      boolean,
       release_for_delete_p boolean
);

-- Some services are offered between sessions of importing incoming email.
-- A unique ID provided by acs_mail_lite_email_uid_map.uid_ext is designed to
-- support UIDs for each email that are consistent between import sessions
-- from external source, such as specified by IMAP4 rfc3501 
-- https://tools.ietf.org/html/rfc3501
-- It is also expected that each mailbox.host, mailbox and user are
-- consistent for duration of the service.
-- And yet, experience knows that sometimes email servers change
-- and UIDs for an email change with it.
-- Users switching email servers of an email account using a IMAP4 client 
-- might hassle with moving email, but
-- in the process they generally know what is happening. They don't re-read
-- all the email. 
-- We want to avoid this server re-reading and processing email 
-- that has already been processed, when the UID of emails change.
-- The Questions become:

-- What scenarios might we run into?
-- Another  user reseting flags.
-- A server migration or restore with some conflicting UIDs.

-- Can we recognize a change in server?
-- If so, can we signal ACS Mail Lite to ignore existing email 
-- in a new environment?
-- Also, we should have a manual override to not ignore or ignore
-- in case of false positive and false negative triggers.

-- Can we recognize if another user accesses the same email account
-- and arbitrarily selects some prior messages to unread?
-- Yes. The purpose of acs_mail_lite_uid_map is to act as a log 
-- of prior processed messages.
-- If total new messages is a significant percentage of all messages
-- and service has been working for a week or more,
-- use statistics to generate a reasonable trigger.
-- Weekly produce a revised distribution curve of weekly counts of incoming.
-- If percentile is over 200%.. ie twice the weekly maximum..
-- Also, test, for example, if new message count is less than
-- prior total, there's more of a chance that they are new messages;
-- Maybe check for one or two duplicates.
-- If new message count is over the total prior messsage count, flag a problem.
-- rfc3501 2.3.1.1.  ..A client can only assume.. at the time
--        that it obtains the next unique identifier value.. that
--        messages arriving after that time will have a UID greater
--        than or equal to that value...


-- Can we recognize a change in server?
-- rfc3501 does not specify a unqiue server id
-- It specifies a unique id for a mailbox: UIDVALIDITY
-- UIDVALIDITY is optional, quite useful.
-- Rfc3501 specifies a unique id for each email: UID.
-- We can assign each email a more unique reference:
-- mailbox.host + mailbox.name + UIDVALIDITY (of mailbox) + UID.
-- We are more specific so that we detect more subtle cases of 
-- server change, where checks by UID and UIDVALIDITY may not.


-- For example, when migrating email service and
-- and the new system initially restores the UIVALIDITY and message UID,
-- but references a different state of each email. The cause
-- of such cases are reasonable. For example, restoring 
-- from backup to a new email host or restoring
-- before some batch event changed a bunch of things. So,
-- src_ext = mailbox.host + (user?) + mailbox.name + UIDVALIDITY
-- Leave user out for now..
-- Priority is to have a robust way to ignore 
-- prior messages recognized as 'new' messages.

create table acs_mail_lite_email_uid_map (
       aml_id  integer not null,
       --uisng varchar instead of text for indexing purposes
       -- Each UID externally defined such as from imap4 server
       uid_ext varchar(3000) not null,
       -- Each external source may apply a different uid.
       -- This is essentialy an arbitrary constant frame reference between 
       -- connecting sessions with external server in most scenarios.
       -- For IMAP4v1 rfc3501  2.3.1.1. item 4 ..combination of
       -- mailbox.name, UIDVALIDITY, and UID must refer to a single 
       -- immutable message on that server forever. 
       -- default is: 
       -- ExternalSource parameter mailbox.name  UIDVALIDITY with dash as delimiter
       -- where ExternalSource parameter is either blank or maybe mailbox.host for example.
       -- external source reference  
       src_ext varchar(1000) not null
);

create index acs_mail_lite_email_uid_map_uid_ext on acs_mail_lite_email_uid_map (uid_ext);
create index acs_mail_lite_email_uid_map_src_ext on acs_mail_lite_email_uid_map (src_ext);

-- Packages that are services, such as ACS Mail Lite, do not have a web UI.
-- Scheduled procs cannot read changes in values of package parameters
-- or get updates via web UI connections, or changes in tcl via apm.
-- Choices are updates via nsv variables and database value updates.
-- Choices via database have persistence across server restarts.
create table acs_mail_lite_ui (
       -- scan_replies_est_dur_per_cycle_s_override
       sredpcs_override integer,
       reprocess_old boolean default 'f'
);