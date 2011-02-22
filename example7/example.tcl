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
	dict set req -title "MyDirectDomain: test timeentry"
	return $req	
    }
    method /test_accordion { req } {
	set d [dict create]
	set C ""
	foreach img [glob docroot/images/*] {
	    set img [file tail $img]
	    append C [<h3> href \# "$img"]
	    append C [<div> [<img> src /images/$img alt $img title $img]]
	}
	set C [<div> id accordion $C]
	set req [jQ theme $req start]
	set req [jQ accordion $req #accordion]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test accordion"
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
	dict set req -title "MyDirectDomain: test styled table sorter"
	return $req	
	
    }
    method /test_galleria { req } {
	set dl {}
	foreach img [glob docroot/images/*] {
	    set img [file tail $img]
	    lappend dl [dict create image /images/$img thumb /images/$img alt $img title $img]
	}
	lassign [jQ do_galleria $req $dl] req C
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test galleria"
	return $req	
    }

    method /test_ajax { req } { 
	set C [<div> id contents {}]
	append C "<button type='button' onclick='load_contents();'>Reload</button>"
	set req [Html script $req /scripts/ajax.js]
	set req [jQ jquery $req]
	set req [jQ ready $req "load_contents();"]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test post method"
	return $req	
    }
    method /test_ajax_callback { req } { 
	set C [<h1> "Time is: [clock format [clock seconds]]"]
	dict set req -content $C
	dict set req content-type text/html
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
