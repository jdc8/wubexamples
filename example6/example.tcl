lappend auto_path ../Wub ../tcllib/modules

package require Site

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test_post { req } {
	set a [expr {int(rand()*10) + 1}]
	set b [expr {int(rand()*10) + 1}]
	set C [<form> test method post action /object/test_post_method {
	    What is to answer to $a + $b? [<text> answer title Answer]
	    [<hidden> a $a]
	    [<hidden> b $b]
	}]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test post method"
	return $req	
    }
    method /test_get { req } {
	set a [expr {int(rand()*10) + 1}]
	set b [expr {int(rand()*10) + 1}]
	set C [<form> test method get action /object/test_get_method {
	    What is to answer to $a * $b? [<text> answer title Answer]
	    [<hidden> a $a]
	    [<hidden> b $b]
	}]
	dict set req -content $C
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test get method"
	return $req	
    }
    method /test_post_method { req a b answer } {
	if {[string is integer -strict $answer] && ($a+$b) == $answer} {
	    set content [<h1> Correct!!!!!]
	} else {
	    set content [<h1> Wrong.]
	}
	append content [<a> href /object/test_post Again]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test with query"
	return $req	
    }
    method /test_get_method { req a b answer } {
	if {[string is integer -strict $answer] && ($a*$b) == $answer} {
	    set content [<h1> Correct!!!!!]
	} else {
	    set content [<h1> Wrong.]
	}
	append content [<a> href /object/test_get Again]
	dict set req -content $content
	dict set req content-type x-text/html-fragment
	dict set req -title "MyDirectDomain: test with query"
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
