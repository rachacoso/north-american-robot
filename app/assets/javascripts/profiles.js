
$( document ).ready(function() {

	setModalActions();

});

function setModalActions () {
	$('.overlay#profile-preview-overlay, a#close-profile-preview').on('click', function(e){
		e.preventDefault();
		$('#profile-preview').fadeOut();
		$('.overlay').fadeOut();
	});	

	$('.overlay#order-item-overlay, a#close-order-item, a#submit-close').on('click', function(e){
		e.preventDefault();
		$('#order-item').fadeOut();
		$('.overlay').fadeOut();
	});	

	$('.overlay#order-overlay, a#close-order, a#continue-ordering').on('click', function(e){
		e.preventDefault();
		$('#order').fadeOut();
		$('.overlay').fadeOut();
	});	
}