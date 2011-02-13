lappend auto_path ../Wub ../tcllib/modules

package require Site

namespace eval MyDirectDomain {
    proc /test { req } {
	dict set req -content "Test for MyDirectDomain"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test with query"
	return $req	
    }
    proc /test_with_query { req A B C } {
	dict set req -content "Test with query for MyDirectDomain A=$A, B=$B, C=$C"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test"
	return $req	
    }
    proc /test_without_armour { req } { 
	dict set req -content "Test without armouring for MyDirectDomain < > ' //"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: non-armour test"
	return $req	
    }
    proc /test_with_armour { req } { 
	dict set req -content [armour "Test with armouring for MyDirectDomain < > ' //"]
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: armour test"
	return $req	
    }
    proc /test_with_armour_in_convert { req } { 
	dict set req -content "Test with armouring using convert for MyDirectDomain < > ' //"
	dict set req content-type x-unarmoured-text/html-fragment
	dict set req -title "MyDirectDomain: armour convert test"
	return $req	
    }
    proc /test_plain_text { req } { 
	dict set req -content "Test with plain text for MyDirectDomain"
	dict set req content-type text/plain
	dict set req -title "MyDirectDomain: plain text test"
	return $req	
    }
    proc /test_css_javascript { req } {
	set C "Test with css and javascript: "
	append C [<div> class red id contents {}]
	append C "<button type='button' onclick='add_contents();'>Add contents</button>"
	dict set req -content "$C"
	dict set req -style [list /css/red.css {}]
	dict set req -script [list /scripts/contents.js {}]
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: css and javascript test"
	return $req	
    }
    proc /default { req } { 
	set content "Default function for MyDirectDomain"
	set ml {}
	foreach m [info command ::MyDirectDomain::/test*] {
	    lappend ml $m /directns[string range $m 18 end]
	}
	append content [Html menulist $ml]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: default"
	return $req
    }
}

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test {req args} {
	dict set req -content "Test for MyOODomain"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: test"
	return $req	
    }
    method /test_with_query {req A B C args} {
	dict set req -content "Test with query for MyOODomain A=$A, B=$B, C=$C"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: test with query"
	return $req	
    }
    method /test_without_armour { req } { 
	dict set req -content "Test without armouring for MyOODomain < > ' //"
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: non-armour test"
	return $req	
    }
    method /test_with_armour { req } { 
	dict set req -content [armour "Test with armouring for MyOODomain < > ' //"]
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: armour test"
	return $req	
    }
    method /test_with_armour_in_convert { req } { 
	dict set req -content "Test with armouring using convert for MyOODomain < > ' //"
	dict set req content-type x-unarmoured-text/html-fragment
	dict set req -title "MyOODomain: armour convert test"
	return $req	
    }
    method /test_plain_text { req } { 
	dict set req -content "Test with plain text for MyOODomain"
	dict set req content-type text/plain
	dict set req -title "MyDirectDomain: plain text test"
	return $req	
    }
    method /test_html_tags { req } { 
	set content ""

	append content [<h1> "Some test with HTML tags"]

	append content [<p> "This is [<b> bold] and this is [<i> italic], this is both [<b> [<i> {bold and italic}]], this is a [<a> href /directoo/test link]"] \n

	append content [<p> "My [<tt> tcl_platform] as unordered list:"] \n
	append content [<ul> [Foreach {k v} [array get ::tcl_platform] {<li>$k=$v</li>}]] \n

	append content [<p> "My [<tt> tcl_platform] as ordered list:"] \n
	append content [<ol> [Foreach {k v} [array get ::tcl_platform] {[<li> "$k=$v"]}]] \n

	append content [<p> "My [<tt> tcl_platform] as table:"] \n
	append content [<table> summary "tcl_platform" [Foreach {k v} [array get ::tcl_platform] {[<tr> "[<td> $k] [<td> $v]"]}]] \n

	append content [<p> "A [<tt> menulist]"] \n
	set ml {}
	foreach m [info object methods [self] -private -all] {
	    if {[string match /* $m]} {
		lappend ml $m /directoo$m
	    }	    
	}
	append content [Html menulist $ml]

	append content [<span> class "plain_span" {Non empty span}] \n
	append content [<span> class "plain_span" {}] \n
	append content [<span>? class "non_empty_span" {Non empty span}] \n
	append content [<span>? class "non_empty_span" {}] \n
	append content [<div> class "test_div" "My test div"] \n

	append content "Using [armour <br>] [<br>] and [armour <hr>] [<hr>] to jump to new lines." \n
	append content [<p> [<img> src /images/pwrdLogo100.gif]] [<hr>] \n

	set headers {}
	lappend headers [<author> "Jos Decoster (jos.decoster@gmail.com)"]
	lappend headers [<description> "A test page for HTML tag commands"]
	lappend headers [<copyright> "2009 Jos Decoster"]
	lappend headers [<generator> "Emacs"]
	lappend headers [<keywords> "Tcl Wub"]
	lappend headers [<meta> name MyMetaTag content "This is my meta tag"]
	lappend headers [<link> rel StyleSheet type text/css media print href /css/sorttable.css]
	lappend headers [<stylesheet> /css/sorttable.css handheld]

	dict set req -content $content
	dict set req -headers $headers
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: HTML tag command tests"
	return $req	
    }
    method /test_text_html { req } { 
	set head [<head>]
	set body [<body> [divs {a b c d e f g} "Deeply nested div"]]
	set content [<html> $head$body]
	dict set req -content $content
	dict set req content-type text/html
	return $req	
    }
    method /test_css_javascript { req } {
	set C "Test with css and javascript: "
	append C [<div> class red id contents {}]
	append C "<button type='button' onclick='add_contents();'>Add contents</button>"
	dict set req -content "$C"
	dict set req -style [list /css/red.css {}]
	dict set req -script [list /scripts/contents.js {}]
	dict set req content-type x-text/html-fragment
	dict set req -title "MyOODomain: css and javascript test"
	return $req	
    }
    method / { req } { 
	set content [<p> "Default function for MyOODomain"]
	set ml {}
	foreach m [info object methods [self] -private -all] {
	    if {[string match /* $m]} {
		lappend ml $m /directoo$m
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

namespace eval ::conversions {
    proc .x-unarmoured-text/html-fragment.x-text/html-fragment { rsp } { 
	set rspcontent [dict get $rsp -content]
	if {[string match "<!DOCTYPE*" $rspcontent]} {
	    # the content is already fully HTML
	    set content $rspcontent
	} else {
	    set content [armour $rspcontent]
	}	
	return [Http Ok $rsp $content x-text/html-fragment]	
    }
}

Site start home . config example.config
