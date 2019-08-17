/***
 *                      888    888                                               d8b          
 *                      888    888                                               Y8P          
 *                      888    888                                                            
 *     .d88b.   8888b.  888888 88888b.   8888b.  88888b.  88888b.  888  888     8888 .d8888b  
 *    d8P  Y8b     "88b 888    888 "88b     "88b 888 "88b 888 "88b 888  888     "888 88K      
 *    88888888 .d888888 888    888  888 .d888888 888  888 888  888 888  888      888 "Y8888b. 
 *    Y8b.     888  888 Y88b.  888  888 888  888 888 d88P 888 d88P Y88b 888 d8b  888      X88 
 *     "Y8888  "Y888888  "Y888 888  888 "Y888888 88888P"  88888P"   "Y88888 Y8P  888  88888P' 
 *                                               888      888           888      888          
 *                                               888      888      Y8b d88P     d88P          
 *                                               888      888       "Y88P"    888P"           
 */

/* Pollock, 2015-> */
$(document).ready(function() {
    var $core = $("#eathappy .core"); // NS :)
    // GENERIC 
    // Gives .expander class
    // Bootstrap gives us a pretty nice accordion control but you've got to be able to do a selector
    // and limit it to 
    // <div class="eathappy-expander" data-expander-for-parent=".someclass">
    // Toggles .expand-content
    // Used in -- panel headings
    //         -- subtempalte headings

    $core.find(".eathappy-expander").click(function(e) {
	e.preventDefault();
	var $scope = $(this).parents($(this).data('expander-for-parent')),
	$expandable = $scope.find('.expand-content'),
  	$collapsable = $scope.find('.collapse-content'),
	$toggleable = $expandable.add($collapsable);

	$toggleable.toggle()
	  .filter('.inline:visible').css('display', 'inline'); // because what? Where does jQuery hide .toggle?
    });

    // PRIMARY CATEGORY INDEX - Global expand buton
    var globalExpandedState = true;
    $('#eathappy .index  .expand-toggle').click(function() {
	globalExpandedState = !globalExpandedState;
        $core.find('.toggle').toggle(globalExpandedState);
	$(this).find(".on,.off").toggle(); // switch verbiage
      console.log("EXPAND");
      $(".index .expand-content").toggle(!globalExpandedState);
      $(".index .collapse-content").toggle(globalExpandedState); // hide mostly the toggle control, kind of a grim way to deal..
    });

    // SECONDARY CATEGORY INDEX -- Pull content for subcats
    $("#eathappy .secondary").click(function() {
	var $target = $(this).find('.list-group'),

// TODO:  THEFUCK YIKLES
      dataset = "gramma",

      loaderUrl = "http://billpollock.com/eathappy/list/" + dataset + "/by-secondary/" + encodeURI($(this).data('category')); // aeiii, why is this not secondarycategorydafuck?

      // Don't load if we've already got content loaded and aare like clicking away
      // because that's stupid.
      if (!$(this).hasClass('secondary-content')) {
	$target.html('<span id="category-load-wait" class="glyphicon glyphicon-download-alt"></span>');
	    
	var flashInterval = setInterval(function(){blink($("#category-load-wait"))}, 1000);
	console.log("ROADINJG: " + loaderUrl);
	$target.load(loaderUrl,
		     function (responseText, textStatus, jqXHR ) {
		       //console.log("RESP: " + responseText);
		       //console.log("STAT: " + textStatus);
			 clearInterval(flashInterval);
		       console.log("LOADER: ROADED");
		     });
        
	console.log("LOADER DISPATCH");
      };
      $(this).addClass('secondary-content');
    });
   // Toggle switches
   $(".switch").bootstrapSwitch();
}); /* end ready() */

function blink($elm) {
  $elm.fadeTo(100, 0.1).fadeTo(200, 1.0);
}

function consola(msg) {
    console.log(msg);
}
