ad_library {

    Provides API for importing email via postfix maildir
    
    @creation-date 12 Oct 2017
    @cvs-id $Id: $

}

namespace eval acs_mail_lite {}



ad_proc -private acs_mail_lite::maildir_email_parse {
    -headers_arr_name
    -parts_arr_name
    -file
    {-struct_list ""}
    {-section_ref ""}
    {-error_p "0"}
} {
    Parse an email from a Postfix maildir into array array_name
    for adding to queue via acs_mail_lite::inbound_queue_insert
    <br><br>
    Parsed data is set in headers and parts arrays in calling environment.
    @param file is filename of one message
} {
    # Put email in a format usable for
    # acs_mail_lite::inbound_queue_insert to insert into queue

    # struct_list expects a nested reference list 
    # consistent with: ns_imap struct conn_id msgno
    
    # We have to generate the references here.

    # <br><pre>
    # Most basic example of part reference:
    # ref    # part
    # 1    #   message text only

    # More complex example. Order is not enforced, only hierarchy.
    # ref    # part
    # 1    #   multipart message
    # 1.1    # part 1 of ref 1
    # 1.2    # part 2 of ref 1
    # 4    #   part 1 of ref 4
    # 3.1    # part 1 of ref 3
    # 3.2    # part 2 of ref 3
    # 3.5    # part 5 of ref 3
    # 3.3    # part 3 of ref 3
    # 3.4    # part 4 of ref 3
    # 2    #   part 1 of ref 2

    # Due to the hierarchical nature of email, this proc is recursive.
    # To see examples of struct list to build, see www/doc/imap-notes.txt

    upvar 1 $headers_arr_name h_arr
    upvar 1 $parts_arr_name p_arr
    upvar 1 __max_txt_bytes __max_txt_bytes
    set has_parts_p 0
    set section_n_v_list [list ]
    if { ![info exists __max_txt_bytes] } {
        set sp_list [acs_mail_lite::sched_parameters]
        set __max_txt_bytes [dict get $sp_list max_blob_chars]
    }
    if { !$error_p } {


        if { $file ne "" } { 
            #This is the first call for this file.
            if {[catch {set mime_id [mime::initialize -file $file]} errmsg] } {
                ns_log Error "maildir_email_parse.71 could not parse \
 message file '${file}'"
                set error_p 1
            } else {
            # get content type (per parse_email)
            set content [mime::getproptery $mime_id content]
            
            # get headers
            set headers_list [mime::getheader $mime_id -names]

            set struct_list [list ]
            # For acs_mail_lite::inbond_cache_hit_p, 
            # make a uid if there is not one. 
            set uid_ref ""
            # Don't use email file's tail, because tail is unique to system
            # not email. See http://cr.yp.to/proto/maildir.html
            foreach h $headers_list {
                set v [mime::getheader $mime_id $h]
                switch -nocase -- $h {
                    uid {
                        if { $h ne "uid" } {
                            lappend struct_list "uid" $v
                        }
                        set uid_ref "uid"
                        set uid_val $v
                    }
                    message-id -
                    msg-id {
                        if { $uid_ref ne "uid"} {
                            if { $uid_ref ne "message-id" } {
                                # message-id is not required
                                # msg-id is an alternate 
                                # Fallback to most standard uid
                                set uid_ref [string tolower $h]
                                set uid_val $v
                            }
                        }
                    }
                    default { 
                        # do nothing
                    }
                }
                lappend struct_list $h $v
            }
            lappend headers_list aml_received_cs [file mtime $file]
            # add parts
            ##code What??
            # need to see what mime procs really return.
            # https://www.tcl.tk/community/tcl2004/Tcl2003papers/kupries-doctools/tcllib.doc/mime/mime.html
            set all_parts_list [list ]
            set section_ref 1
            if { [string first "multipart" $content] != -1 } {
                foreach child_part[mime::getproperty $mime_id parts]
            } else {
                set parts_list [list part.${section_ref} $mime_id]
            }

            foreach part $parts_list {
                if [mime::getproperty $part content] eq "multipart/alternative" } {
                    foreach child_part [mime::getproperty $part parts] {
                        lappend str
            


        if { [string range $section_ref 0 0] eq "." } {
            set section_ref [string range $section_ref 1 end]
        } 
        ns_log Dev "acs_mail_lite::maildir_email_parse.706 \
msgno '${msgno}' section_ref '${section_ref}'"

        # Assume headers and names are unordered
        



        foreach {n v} $struct_list {
            if { [string match {part.[0-9]*} $n] } {
                set has_parts_p 1
                set subref $section_ref
                append subref [string range $n 4 end]
                acs_mail_lite::maildir_email_parse \
                    -headers_arr_name h_arr \
                    -parts_arr_name p_arr \
                    -conn_id $conn_id \
                    -msgno $msgno \
                    -struct_list $v \
                    -section_ref $subref
            } else {
                switch -exact -nocase -- $n {
                    bytes {
                        set bytes $v
                    }
                    disposition.filename {
                        set filename $v
                    }
                    type {
                        set type $v
                    }
                    
                    default {
                        # do nothing
                    }
                }
                if { $section_ref eq "" } {
                    set h_arr(${n}) ${v}
                } else {
                    lappend section_n_v_list ${n} ${v}
                }
            }
        }

        if { $section_ref eq "" && !$has_parts_p } {
            # section_ref defaults to '1'
            set section_ref "1"
        }

        set section_id [acs_mail_lite::section_id_of $section_ref]
        ns_log Dev "acs_mail_lite::maildir_email_parse.746 \
msgno '${msgno}' section_ref '${section_ref}' section_id '${section_id}'"

        # Add content of an email part
        set p_arr(${section_id},nv_list) $section_n_v_list
        set p_arr(${section_id},c_type) $type
        lappend p_arr(section_id_list) ${section_id}

        if { [info exists bytes] && $bytes > $__max_txt_bytes \
                 && ![info exists filename] } {
            set filename "blob.txt"
        }
        
        if { [info exists filename ] } {
            set filename2 [clock microseconds]
            append filename2 "-" $filename
            set filepathname [file join [acs_root_dir] \
                                  acs-mail-lite \
                                  $filename2 ]
            set p_arr(${section_id},filename) $filename
            set p_arr(${section_id},c_filepathname) $filepathname
            if { $filename eq "blob.txt" } {
                ns_log Dev "acs_mail_lite::maildir_email_parse.775 \
 ns_imap body '${conn_id}' '${msgno}' '${section_ref}' \
 -file '${filepathname}'"
                ns_imap body $conn_id $msgno ${section_ref} \
                    -file $filepathname
            } else {
                ns_log Dev "acs_mail_lite::maildir_email_parse.780 \
 ns_imap body '${conn_id}' '${msgno}' '${section_ref}' \
 -file '${filepathname}' -decode"

                ns_imap body $conn_id $msgno ${section_ref} \
                    -file $filepathname \
                    -decode
            } 
        } elseif { $section_ref ne "" } {
            # text content
            set p_arr(${section_id},content) [ns_imap body $conn_id $msgno $section_ref]
            ns_log Dev "acs_mail_lite::maildir_email_parse.792 \
 text content '${conn_id}' '${msgno}' '${section_ref}' \
 $p_arr(${section_id},content)'"
            
        } else {
            set p_arr(${section_id},content) ""
            # The content for this case
            # has been verified to be redundant.
            # It is mostly the last section/part of message.
            #
            # If diagnostics urge examining these cases, 
            # Set debug_p 1 to allow the following code to 
            # to compress a message to recognizable parts without 
            # flooding the log.
            set debug_p 0
            if { $debug_p } {
                set msg_txt [ns_imap text $conn_id $msgno ]
                # 72 character wide lines * x lines
                set msg_start_max [expr { 72 * 20 } ]
                set msg_txtb [string range $msg_txt 0 $msg_start_max]
                if { [string length $msg_txt] \
                         > [expr { $msg_start_max + 400 } ] } {
                    set msg_txte [string range $msg_txt end-$msg_start_max end]
                } elseif { [string length $msg_txt] \
                               > [expr { $msg_start_max + 144 } ] } {
                    set msg_txte [string range $msg_txt end-144 end]
                } else {
                    set msg_txte ""
                }
                ns_log Dev "acs_mail_lite::maildir_email_parse.818 IGNORED \
 ns_imap text '${conn_id}' '${msgno}' '${section_ref}' \n \
 msg_txte '${msg_txte}'"
            } else {
                ns_log Dev "acs_mail_lite::maildir_email_parse.822 ignored \
 ns_imap text '${conn_id}' '${msgno}' '${section_ref}'"
            }
        }

    }
    return $error_p
}


#            
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:


