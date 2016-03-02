
$( document ).ready(function() {

	$('.overlay#profile-preview-overlay, a#close-profile-preview').on('click', function(e){
		e.preventDefault();
		$('#profile-preview').fadeOut();
		$('.overlay').fadeOut();
	});	


});