$(document).ready(function() {

	var gallerypage = 2;

	if (document.getElementById('gallery-list')) {
		var waypoint = new Waypoint({
		  element: document.getElementById('gallery-list'),
		  handler: function(direction) {
		    if (direction == "down") {

					var gReq = $.get( "/gallerynext?page=" + gallerypage, function() {
						
					})
						.done(function(data) {
							gallerypage += 1;
							$('#gallery-list').append(data);
							Waypoint.refreshAll();
						})
						.fail(function() {
							alert( "Failed to load. Please try again." );
						})
						.always(function() {
							// alert( "finished" );
						});

		    	
		    }
		    // console.log('Basic waypoint triggered')
		    // console.log(gallerypage)
		    // console.log(direction)
		  },
		  offset: 'bottom-in-view'
		})
	}


});


