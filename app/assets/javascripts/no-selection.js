(function($){
    
  $.fn.ctrl = function(key, callback) {

    // Hey, this does not work on Mac OsX!
    // On Mac we should capture Cmd key instead.
    // Anyone having time can add the feature.
    // TODO: read this
    // http://stackoverflow.com/questions/3902635/how-does-one-capture-a-macs-command-key-via-javascript

	if (!$.isArray(key)) {
       key = [key];
    }
	callback = callback || function(){ return false; }
    return $(this).keydown(function(e) {

		$.each(key,function(i,k){
			if(e.keyCode == k.toUpperCase().charCodeAt(0) && e.ctrlKey) {
				return callback(e);
			}
		});
		return true;
    });
};


$.fn.disableSelection = function() {

	this.ctrl(['a','s','c']);

    return this.attr('unselectable', 'on')
               .css({'-moz-user-select':'-moz-none',
                     '-moz-user-select':'none',
					 '-o-user-select':'none',
					 '-khtml-user-select':'none',
					 '-webkit-user-select':'none',
					 '-ms-user-select':'none',
					 'user-select':'none'})
	           .bind('selectstart', function(){ return false; });
};

})(jQuery);



$(':not(input,select,textarea)').disableSelection();
