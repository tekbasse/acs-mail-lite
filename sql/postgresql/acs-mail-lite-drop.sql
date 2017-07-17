--
-- A simple mail queue
--
-- @author <a href="mailto:eric@openforce.net">eric@openforce.net</a>
-- @version $Id: acs-mail-lite-drop.sql,v 1.6 2009/03/18 22:41:15 emmar Exp $
--

drop table acs_mail_lite_queue;

drop table acs_mail_lite_mail_log; 
drop table acs_mail_lite_bounce; 
drop table acs_mail_lite_bounce_notif;

drop index acs_mail_lite_email_uid_map_uid_ext;
drop index acs_mail_lite_email_uid_map_src_ext;

drop table acs_mail_lite_email_uid_map;

drop table acs_mail_lite_from_external;


drop sequence acs_mail_lite_id_seq;