
$( document ).ready(function() {

	$('.overlay#profile-preview-overlay, a#close-profile-preview').on('click', function(e){
		e.preventDefault();
		$('#profile-preview').fadeOut();
		$('.overlay').fadeOut();
	});	

	$('.overlay#order-item-overlay, a#close-order-item').on('click', function(e){
		e.preventDefault();
		$('#order-item').fadeOut();
		$('.overlay').fadeOut();
	});	

});