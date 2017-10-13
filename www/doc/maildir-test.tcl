
set content "www/test/test2.tcl start<br>"

set messages_list [glob "/home/nsadmin/Maildir/new/*"]
set s " : "


set var_list [list msg m_id c_type header_names_list headers_list params_list encoding_s size_list content_s part_ids_list body_parts_list ]

set var2_list [list part_id p_header_names_list p_headers_list p_params_list p_encoding_s p_size_s p_content_s p_property_names_list p_property_list ]

foreach msg $messages_list {
    
    set m_id [mime::initialize -file $msg]

    set header_names_list [mime::getheader $m_id -names]
    # a header returns multiple values in a list, if header element is repeated in email.
    set headers_list [mime::getheader $m_id]
    set params_list [mime::getproperty $m_id params]
    set encoding_s [mime::getproperty $m_id encoding]
    set content_s [mime::getproperty $m_id content]
    ns_log Notice "maildir-test.tcl.22 m_id '${m_id}' content_s '${content_s}'"
    set size_list [mime::getproperty $m_id size]

    if { [string match "multipart/*" $content_s] \
             || [string match -nocase "inline*" $content_s ] } {

        set part_ids_list [mime::getproperty $m_id parts]

    } else {
        # this is a leaf
        set body_parts_list [mime::getbody $m_id]
        set bpl [string range $body_parts_list 0 120]
        lappend bpl ".. .." [string range $body_parts_list end-120 end]
        set body_parts_list $bpl
    }




    set property_names_list [mime::getproperty $m_id -names]
    set property_list [mime::getproperty $m_id]



    append content "<br><br>New message<br><br>"
    foreach var $var_list {
        if { [info exists $var] } {
            append content $var $s [set $var] " <br><br>"
        }

    }

    if { [info exists part_ids_list ] } {
        foreach part_id $part_ids_list {
            set p_header_names_list [mime::getheader $part_id -names]
            set p_headers_list [mime::getheader $part_id]
            set p_property_names_list [mime::getproperty $part_id -names]
            set p_property_list [mime::getproperty $part_id ]
            set p_params_list [mime::getproperty $part_id params]
            set p_encoding_s [mime::getproperty $part_id encoding]
            set p_content_s [mime::getproperty $part_id content]
            ns_log Notice "maildir-test.tcl.63 part_id '${part_id}' p_content_s '${p_content_s}'"
            set p_size_s [mime::getproperty $part_id size]
            if { [string match "multipart/*" $p_content_s] \
                     || [string match -nocase "inline*" $p_content_s ] } {

                set p_part_ids_list [mime::getproperty $part_id parts]

            } else {
                # this is a leaf
                set p_body_parts_list [mime::getbody $part_id]
                set bpl [string range $p_body_parts_list 0 120]
                lappend bpl ".. .." [string range $p_body_parts_list end-120 end]
                set p_body_parts_list $bpl
            }
            
            append content "part_id '${part_id}'<br>"
            foreach var $var2_list {
                if { [info exists $var] } {
                    append content $var $s [set $var] " <br><br>"
                }
            }
        }
    }
    # cleanup current message
    foreach var $var_list {
        if { [info exists $var] && $var ne "msg" && $var ne "m_id" } {
            unset $var
        }
    }
    foreach var $var2_list {
        if { [info exists $var] } {
            unset $var
        }
    }
    mime::finalize $m_id -subordinates all


}