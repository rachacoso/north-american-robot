$( document ).ready(function() {

	$('#tab-conversation, #tab-profile, #tab-contract').click(function() {
		var thisClass = $( this ).attr('class');
		var thisId = $( this ).attr('id');
		var speed = 250;
		if (thisClass != "active") {
			if (thisId == "tab-conversation") {				
				$('#tab-conversation').addClass('active');
				$('#tab-profile').removeClass('active');
				$('#profile-conversation-wrapper').show();
				$('#profile-profile-wrapper').hide();
				if ($('#tab-contract').length) {
					$('#tab-contract').removeClass('active');
					$('#profile-contract-wrapper').hide();
				}
				setDivHeight('#profile-conversation-wrapper');
			} else if (thisId == "tab-profile") {
				$('#tab-conversation').removeClass('active');
				$('#tab-profile').addClass('active');
				$('#profile-conversation-wrapper').hide();
				$('#profile-profile-wrapper').show();
				if ($('#tab-contract').length) {
					$('#tab-contract').removeClass('active');
					$('#profile-contract-wrapper').hide();
				}
				setDivHeight('#profile-profile-wrapper');
				initFullProfile(true);
			} else if (thisId == "tab-contract") {

				var ajaxURL = $(this).data("ajaxurl")

				var getContract = $.get( ajaxURL, function( data ) {
					// alert(ajaxURL);
				  $('#profile-contract-data').html(data);
				})
				  .done(function() {

						$('#tab-conversation').removeClass('active');
						$('#tab-profile').removeClass('active');
						$('#tab-contract').addClass('active');
						$('#profile-conversation-wrapper').hide();
						$('#profile-profile-wrapper').hide();
						$('#profile-contract-wrapper').show();
						setDivHeight('#profile-contract-wrapper');

				  })
				  // .fail(function() {
				  //   alert( "error" );
				  // })
				  // .always(function() {
				  //   alert( "finished" );
				  // });
				 
				// Perform other work here ...
				 
				// Set another completion function for the request above
				// getContract.always(function() {
				//   alert( "second finished" );
				// });

			}
		}
	});

	// $('#close-quick-view').on('click', function(e){
	// 	// e.preventDefault();
	// 	$('#quick-view').hide();
	// 	$('.overlay').hide();
	// });

	$('.overlay#quick-view-overlay, a#close-quick-view').on('click', function(e){
		e.preventDefault();
		console.log("clicked");
		$('#quick-view').fadeOut();
		$('.overlay').fadeOut();
	});	

});

function initFullProfile (reload) {
	var galleryDiv = ".gallery-" + profileType
	var defaultCollectionDiv = "." + profileType + "-default"
	doBackstretch(galleryDiv, bsPhotos, 3000, 0);
	doBackstretch(defaultCollectionDiv, bsPhotos);
	if (hasConversation && !reload) {
		$('#profile-profile-wrapper').hide();
	}
}