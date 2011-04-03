lappend auto_path ../Wub ../tcllib/modules

package require OO
package require Site
package require Cookies
package require Query

package provide FossilProxy 1.0

set ::API(Domains/FossilProxy) {
    {
	A domain to serve as proxy for the 'fossil http' web interface.
    }
    fossil_dir {Directory where fossil repositories are located. The proxy will work for all repositories in this directory which are named *.fossil, where the basename of the repository is part of the URL.}
    fossil_command {Path to fossil command}
}

oo::class create FossilProxy {

    method strip_prefix { path } {
 	variable prefix
 	if {[string length $prefix] && [string match "$prefix*" $path]} {
 	    set path [string range $path [string length $prefix] end]
 	}
	return $path
    }

    method do { r } { 

	variable prefix
	variable fossil_dir
	variable fossil_command

	if {[dict get $r -method] eq "POST"} {
	    set fr "POST [my strip_prefix [dict get $r -path]]"
	    if {[dict exists $r -entity] && [string length [dict get $r -entity]]} {
		append fr "?[dict get $r -entity]"
	    }
	    append fr " HTTP/1.1\n"
	} else {
	    lassign [dict get $r -header] meth url ver
	    set fr "$meth [my strip_prefix $url] $ver\n"
	}
	
	dict for {k v} $r {
	    switch -nocase -glob -- $k {
		-* {}
		default { append fr "$k: $v\n" }
	    }
	}
	if {[dict exists $r -entity]} {
	    append fr \n[dict get $r -entity]
	}
	
	return [Httpd Thread {

	    package require Cookies
	    package require Dict

	    if {[catch {exec $fossil_command http $fossil_dir << $fr} R]} {
		error $R
	    }

	    set n 0
	    set response 404
	    set location ""
	    set content_type "test/html"
	    set content_found 0
	    foreach l [split $R \n] {
		incr n
		if {[string length $l] == 0} {
		    set content_found 1
		    break
		}
		switch -nocase -glob -- $l {
		    "HTTP/*" {
			lassign [split $l] http response
		    }
		    "Content-Type:*" {
			set content_type [string trim [string range $l 13 end]]
		    }
		    "Location:*" {
			set location [string trim [string range $l 9 end]]
		    }
		    "Set-Cookie:*" {
			set cdict [lindex [Cookies parse4client [string trim [string range $l 11 end]]] 1]
			set r [Cookies Add $r -path $prefix[dict get? $cdict -Path] -name [dict get? $cdict -name] -value [dict get? $cdict -value] -expires "next month"]
		    }
		}
	    }
	    
	    set C ""
	    if {$content_found} {
		set C [join [lrange [split $R \n] $n end] \n]
	    }
	    
 	    if {[string length $prefix] && [string match "text/html*" $content_type]} {
 		regsub -all { href=\"\/} $C " href=\"$prefix/" C
 		regsub -all { href=\'\/} $C " href='$prefix/" C
 		regsub -all { src=\"\/} $C " src=\"$prefix/" C
 		regsub -all { src=\'\/} $C " src='$prefix/" C
 	    }

	    switch -exact -- $response {
		200 {
		    return [Http NoCache [Http Ok $r $C $content_type]]
		}
		302 {
		    return [Http Redirect $r $prefix$location]
		}
		404 {
		    return [Http NotFound $r]
		}
		default {
		    return [Http NoCache [Http Ok $r "Dont know what to do with 'fossil http' response:\n$R"]]
		}
	    }

	} r $r fr $fr fossil_dir $fossil_dir fossil_command $fossil_command prefix $prefix]
    }

    constructor {args} {
	variable prefix ""
	variable fossil_command "fossil"
	variable {*}[Site var? FossilProxy] {*}$args ;# allow .ini file to modify defaults
	if {![info exists fossil_dir]} {
	    error "fossil_dir not set"
	}
	catch {next {*}$args}
    }
}

Site start home . config fossil_proxy.config
