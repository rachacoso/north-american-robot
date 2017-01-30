
$( document ).ready(function() {

	setModalActions();
	shippingtermsControls();

	$('#back-control').on('click', function(e){
		e.preventDefault();
		$('#back-options').toggle();
	});
	$('#back-options').on('mouseleave', function(e) {
		$('#back-options').fadeOut();
	});

});

function setModalActions () {
	$('.overlay#profile-preview-overlay, a#close-profile-preview, a#close-new-info').on('click', function(e){
		e.preventDefault();
		$('#profile-preview').fadeOut();
		$('.overlay').fadeOut();
	});	

	$('.overlay#order-item-overlay, a#close-order-item, a#submit-close').on('click', function(e){
		e.preventDefault();
		$('#order-item').fadeOut();
		$('.overlay').fadeOut();
	});

	$('.overlay#error-modal-overlay, a#close-error-modal, a#close-error-button').on('click', function(e){
		e.preventDefault();
		$('#error-modal').fadeOut();
		$('.overlay').fadeOut();
	});

	$('a#submit-go-and-close').on('click', function(e){
		// e.preventDefault();
		$('#order-item').fadeOut();
		$('.overlay').fadeOut();
	});	

	$('.overlay#order-overlay, a#close-order, a#continue-ordering').on('click', function(e){
		e.preventDefault();
		$('#order').fadeOut();
		$('.overlay').fadeOut();
	});	
}

function shippingtermsControls () {
	$('#retailer_other_terms_switch, #distributor_other_terms_switch').on('click', function(e){
		if (this.checked) {
			$('#other-terms-comments').fadeIn();
			console.log("1");
		} else {
			$('#other-terms-comments').fadeOut();
			console.log("2");
		}
	});
}
