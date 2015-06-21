$( document ).ready(function() {

	$('#tab-conversation, #tab-profile').click(function() {
		var thisClass = $( this ).attr('class');
		var thisId = $( this ).attr('id');
		var speed = 250;
		if (thisClass != "active") {
			if (thisId == "tab-conversation") {				
				$('#tab-conversation').addClass('active');
				$('#tab-profile').removeClass('active');
				$('#profile-profile-wrapper').hide();
				$('#profile-conversation-wrapper').show();
			} else if (thisId == "tab-profile") {
				$('#tab-conversation').removeClass('active');
				$('#tab-profile').addClass('active');
				$('#profile-conversation-wrapper').hide();
				$('#profile-profile-wrapper').show();
				initFullProfile(true);
			}
		}
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