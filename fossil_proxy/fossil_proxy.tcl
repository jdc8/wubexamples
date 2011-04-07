if {[file exists [file join [file dirname [info script]] local_setup.tcl]]} {
    source [file join [file dirname [info script]] local_setup.tcl]
}

package require Site

Site start home . config fossil_proxy.config
