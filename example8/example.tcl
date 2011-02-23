lappend auto_path ../Wub ../tcllib/modules

package require Site

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test_thread { req } {
	return [Httpd Thread {
	    for {set i 0} {$i < 10} {incr i} {
		puts "In Thread @ [clock format [clock seconds]], i = $i"
		after 1000
	    }
	    return [Http NoCache [Http Ok $req "Waiting for thread is over."]]
	} req $req]
    }
    method /test_suspend { req } {
	after 10000 [list $::oodomain resume $req]
	return [Httpd Suspend $req]
    }
    method resume { req } {
	Httpd Resume [Http NoCache [Http Ok $req "Waiting for resume is over."]]
    }
    method / { req } { 
	set content [<p> "Default function for MyOODomain"]
	set ml {}
	foreach m [info object methods [self] -private -all] {
	    if {[string match /* $m]} {
		lappend ml $m /object$m
	    }	    
	}
	append content [Html menulist $ml]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: default"
	return $req
    }
}

set oodomain [MyOODomain new]

package require conversions
set Html::XHTML 1
set ::conversions::htmlhead {<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">}

Site start home . config example.config
