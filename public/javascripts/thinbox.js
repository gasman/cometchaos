/*
 * Thickbox 3.1 - One Box To Rule Them All.
 * By Cody Lindley (http://www.codylindley.com)
 * Copyright (c) 2007 cody lindley
 * Licensed under the MIT License: http://www.opensource.org/licenses/mit-license.php
*/

function tb_show(html) {//function called when the user clicks on a thickbox link

	try {
		if (typeof document.body.style.maxHeight === "undefined") {//if IE 6
			jq("body","html").css({height: "100%", width: "100%"});
			jq("html").css("overflow","hidden");
			if (document.getElementById("TB_HideSelect") === null) {//iframe to hide select elements in ie6
				jq("body").append("<iframe id='TB_HideSelect'></iframe><div id='TB_overlay'></div><div id='TB_window'></div>");
				jq("#TB_overlay").click(tb_remove);
			}
		}else{//all others
			if(document.getElementById("TB_overlay") === null){
				jq("body").append("<div id='TB_overlay'></div><div id='TB_window'></div>");
				jq("#TB_overlay").click(tb_remove);
			}
		}
		
		if(tb_detectMacXFF()){
			jq("#TB_overlay").addClass("TB_overlayMacFFBGHack");//use png overlay so hide flash
		}else{
			jq("#TB_overlay").addClass("TB_overlayBG");//use background and opacity
		}

		TB_WIDTH = 320;
		TB_HEIGHT = 160;
		ajaxContentW = TB_WIDTH - 30;
		ajaxContentH = TB_HEIGHT - 45;
			
		jq("#TB_window").append("<div id='TB_title'><div id='TB_closeAjaxWindow'><a href='#' id='TB_closeWindowButton'>close</a></div></div><div id='TB_ajaxContent' style='width:"+ajaxContentW+"px;height:"+ajaxContentH+"px'></div>");
					
		jq("#TB_closeWindowButton").click(tb_remove);
			
		jq("#TB_ajaxContent").append(html);
		tb_position();
		jq("#TB_window").css({display:"block"}); 
			

		document.onkeyup = function(e){ 	
			if (e == null) { // ie
				keycode = event.keyCode;
			} else { // mozilla
				keycode = e.which;
			}
			if(keycode == 27){ // close
				tb_remove();
			}	
		};
		
	} catch(e) {
		//nothing here
	}
}

//helper functions below

function tb_remove() {
	jq("#TB_closeWindowButton").unbind("click");
	jq("#TB_window").fadeOut("fast",function(){jq('#TB_window,#TB_overlay,#TB_HideSelect').trigger("unload").unbind().remove();});
	if (typeof document.body.style.maxHeight == "undefined") {//if IE 6
		jq("body","html").css({height: "auto", width: "auto"});
		jq("html").css("overflow","");
	}
	document.onkeydown = "";
	document.onkeyup = "";
	return false;
}

function tb_position() {
	jq("#TB_window").css({marginLeft: '-' + parseInt((TB_WIDTH / 2),10) + 'px', width: TB_WIDTH + 'px'});
	if ( !(jQuery.browser.msie && jQuery.browser.version < 7)) { // take away IE6
		jq("#TB_window").css({marginTop: '-' + parseInt((TB_HEIGHT / 2),10) + 'px'});
	}
}

function tb_getPageSize(){
	var de = document.documentElement;
	var w = window.innerWidth || self.innerWidth || (de&&de.clientWidth) || document.body.clientWidth;
	var h = window.innerHeight || self.innerHeight || (de&&de.clientHeight) || document.body.clientHeight;
	arrayPageSize = [w,h];
	return arrayPageSize;
}

function tb_detectMacXFF() {
	var userAgent = navigator.userAgent.toLowerCase();
	if (userAgent.indexOf('mac') != -1 && userAgent.indexOf('firefox')!=-1) {
		return true;
	}
}


