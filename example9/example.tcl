lappend auto_path ../Wub ../tcllib/modules

package require Site
package require Direct
package require ReCAPTCHA

oo::class create MyOODomain {
    constructor {args} {
    }
    method /test_recaptcha { req } {
	set C ""
	append C [<h1> "Test with ReCAPTCHA"]
	append C [<p> "Enter text, then press <b>Check result</b> below"]
	set oorecaptcha [lindex [info class instances ::ReCAPTCHA] 0]
	append C [$oorecaptcha form class autoform \
		      before "<br>[<text> T size 80]<br><br>" \
		      after "<br>[<hidden> _charset_ {}]<input name='check' type='submit' value='Check result'>" \
		      pass [namespace code {my test_recaptcha_passed}]]
	return [Http NoCache [Http Ok $req $C]]
    }
    method test_recaptcha_passed { req params } {
	return [Http NoCache [Http Ok $req "You passed the reCAPTCHA and entered: [dict get $params T]"]]
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
