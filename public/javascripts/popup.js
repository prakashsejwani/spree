/***************************/
//@Author: Adrian "yEnS" Mato Gondelle
//@website: www.yensdesign.com
//@email: yensamg@gmail.com
//@license: Feel free to use it, but keep this credits please!					
/***************************/

var $j = jQuery.noConflict();

//SETTING UP OUR POPUP
//0 means disabled; 1 means enabled;
var popupStatus = 0;

	//loading popup with jQuery magic!
	function loadPopup(id){
		//loads popup only if it is disabled
		if (popupStatus == 0) {
			
			$j("#backgroundPopup").css({
				"opacity": "0.7"
			});
			$j("#backgroundPopup").fadeIn("slow");
			$j("#popupContact_" + id).fadeIn("slow");
			popupStatus = 1;
		}
		centerPopup(id);
		
	}
	
	
	
	//disabling popup with jQuery magic!
	function disablePopup(id){
		//disables popup only if it is enabled
		if (popupStatus == 1) {
			$j("#backgroundPopup").fadeOut("slow");
			$j("#popupContact_" + id).fadeOut("slow");
			popupStatus = 0;
		}
	}
	
	//centering popup
	function centerPopup(id){
		//request data for centering
		var windowWidth = document.documentElement.clientWidth;
		var windowHeight = document.documentElement.clientHeight;
		var popupHeight = $j("#popupContact_" + id).height();
		var popupWidth = $j("#popupContact_" + id).width();
		//centering
		$j("#popupContact_" + id).css({
			"position": "absolute",
			"top": windowHeight / 2 - popupHeight / 2,
			"left": windowWidth / 2 - popupWidth / 2
		});
		//only need force for IE6
		
		$j("#backgroundPopup").css({
			"height": windowHeight
		});
		
	}

