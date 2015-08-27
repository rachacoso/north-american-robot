$( document ).ready(function() {

	$('#tab-conversation, #tab-profile').click(function() {
		var thisClass = $( this ).attr('class');
		var thisId = $( this ).attr('id');
		var speed = 250;
		if (thisClass != "active") {
			if (thisId == "tab-conversation") {				
				$('#tab-conversation').addClass('active');
				$('#tab-profile').removeClass('active');
				$('#profile-conversation-wrapper').show();
				$('#profile-profile-wrapper').hide();
				// setDivHeight('#profile-conversation-wrapper');
			} else if (thisId == "tab-profile") {
				$('#tab-conversation').removeClass('active');
				$('#tab-profile').addClass('active');
				$('#profile-conversation-wrapper').hide();
				$('#profile-profile-wrapper').show();
				// setDivHeight('#profile-profile-wrapper');
				initFullProfile(true);
			}
		}
	});

	$('.overlay#quick-view-overlay, a#close-quick-view').on('click', function(e){
		e.preventDefault();
		console.log("clicked");
		$('#quick-view').fadeOut();
		$('.overlay').fadeOut();
	});	

});

function initFullProfile(reload) {
	var galleryDiv = ".gallery-" + profileType
	var defaultCollectionDiv = "." + profileType + "-default"
	doBackstretch(galleryDiv, bsPhotos, 3000, 0);
	doBackstretch(defaultCollectionDiv, bsPhotos);
	if (hasConversation && !reload) {
		$('#profile-profile-wrapper').hide();
	}
}