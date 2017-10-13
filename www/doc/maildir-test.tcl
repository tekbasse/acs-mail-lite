
set content "www/test/test2.tcl start<br>"

set messages_list [glob "/home/nsadmin/Maildir/new/*"]
set s " : "


set var_list [list msg m_id c_type header_names_list headers_list params_list encoding_list size_list content_list part_ids_list body_parts_list ]

set var2_list [list part_id p_header_names_list p_headers_list p_params_list p_encoding_list p_size_list p_content_list p_property_names_list p_property_list ]

foreach msg $messages_list {
    
    set m_id [mime::initialize -file $msg]

    set header_names_list [mime::getheader $m_id -names]
    # a header returns multiple values in a list, if header element is repeated in email.
    set headers_list [mime::getheader $m_id]
    set params_list [mime::getproperty $m_id params]
    set encoding_list [mime::getproperty $m_id encoding]
    set content_list [mime::getproperty $m_id content]
    ns_log Notice "mtest.tcl content_list '${content_list}'"
    set size_list [mime::getproperty $m_id size]

    if { [string match "multipart/*" $content_list] \
             || [string match -nocase "inline*" $content_list ] } {

        set part_ids_list [mime::getproperty $m_id parts]

    } else {
        # this is a leaf
        set body_parts_list [mime::getbody $m_id]
        set bpl [string range $body_parts_list 0 120]
        lappend bpl ".. .." [string range $body_parts_list 120-end end]
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
            set p_params_list [mime::getproperty $m_id params]
            set p_encoding_list [mime::getproperty $m_id encoding]
            set p_content_list [mime::getproperty $m_id content]
            set p_size_list [mime::getproperty $m_id size]
            if { [string match "multipart/*" $p_content_list] \
                     || [string match -nocase "inline*" $p_content_list ] } {

                set part_ids_list [mime::getproperty $part_id parts]

            } else {
                # this is a leaf
                set body_parts_list [mime::getbody $part_id]
                set bpl [string range $p_body_parts_list 0 120]
                lappend bpl ".. .." [string range $p_body_parts_list 120-end end]
                set body_parts_list $bpl
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