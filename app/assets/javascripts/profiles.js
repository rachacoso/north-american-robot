
// <a id="view-profile-preview" class="button tiny alert expand" data-ajaxurl="<%= view_contract_url(match) %>">PREVIEW TERM SHEET</a>

$( document ).ready(function() {



	$('.view-profile-preview').on('click', function(e){
		e.preventDefault();

		var ajaxURL = $(this).data("ajaxurl")

		var getPreview = $.get( ajaxURL, function( data ) {
			// alert(ajaxURL);
		  $('#profile-preview-data').html(data);
		})
		  .done(function() {
				$('.overlay#profile-preview-overlay').fadeIn();
				$('#profile-preview').fadeIn();

			  $("#owl-example-preview").owlCarousel({
					lazyLoad : true,
					lazyFollow : true,
					lazyEffect : "fade",
					navigation : true,
					navigationText : [
						"<img src='images/v2/left-arrow.svg'>",
						"<img src='images/v2/right-arrow.svg'>",
					],
					items : 4,
					pagination : false,
					scrollPerPage : false,
				});

				$(document).foundation('tooltip', 'reflow');

		  })

	});


	$('.overlay#profile-preview-overlay, a#close-profile-preview').on('click', function(e){
		e.preventDefault();
		$('#profile-preview').fadeOut();
		$('.overlay').fadeOut();
	});	


});