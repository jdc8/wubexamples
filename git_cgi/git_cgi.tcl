if {[file exists [file join [file dirname [info script]] local_setup.tcl]]} {
    source [file join [file dirname [info script]] local_setup.tcl]
}

package require Site
package require CGI

Debug on cgi 5000

Site start home . config git_cgi.config
