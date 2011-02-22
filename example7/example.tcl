lappend auto_path ../Wub ../tcllib/modules

package require Site
package require jQ
package require Icons

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test_timeentry { req } {
	puts "timeentry"
	set C [<p> [<input> type text id myTimeEntry size 10 {}]]
	append C [<p> [<input> type text id myTimeEntry2 size 10 {}]]
	set req [jQ theme $req start]
	set req [jQ timeentry $req #myTimeEntry]
	set req [jQ timeentry $req #myTimeEntry2 show24Hours true showSeconds true]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test post method"
	return $req	
    }
    method /test_accordion { req } {
	set d [dict create]
	set C ""
	set C [<div> id accordion [subst {
	    [<h3> href \# "Section A"]
	    [<div> "Contents for A"]
	    [<h3> href \# "Section B"]
	    [<div> "Contents for B"]
	    [<h3> href \# "Section C"]
	    [<div> "Contents for C"]
	}]]
	set req [jQ theme $req start]
	set req [jQ accordion $req #accordion]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test post method"
	return $req	
    }
    method /test_table_sorter { req } {
	set cvs {last name,first name,email,due,web site
	    Smith,John,jsmith@gmail.com,$50.00,http://www.jsmith.com
	    Bach,Frank,fbach@yahoo.com,$50.00,http://www.frank.com
	    Doe,Jason,jdoe@hotmail.com,$100.00,http://www.jdoe.com,
	    Conway,Tim,tconway@earthlink.net,$50.00,http://www.timconway.com
	}
	set C [Report html {*}[Report csv2dict $cvs] class tablesorter sortable 0 evenodd 0]
	set req [jQ tablesorter $req "table"]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test table sorter"
	return $req	
    }
    method /test_styled_table_sorter { req } {
	set cvs {last name,first name,email,due,web site
	    Smith,John,jsmith@gmail.com,$50.00,http://www.jsmith.com
	    Bach,Frank,fbach@yahoo.com,$50.00,http://www.frank.com
	    Doe,Jason,jdoe@hotmail.com,$100.00,http://www.jdoe.com,
	    Conway,Tim,tconway@earthlink.net,$50.00,http://www.timconway.com
	}
	set C [Report html {*}[Report csv2dict $cvs] class tablesorter sortable 0 evenodd 0]
	set req [jQ tablesorter $req "table"]
	dict set req -style [list /css/tablesorter.css {}]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test table sorter"
	return $req	
	
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
