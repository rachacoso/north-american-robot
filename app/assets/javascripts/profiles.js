
$( document ).ready(function() {

	setModalActions();
	shippingtermsControls ();

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
	$('#retailer_us_shipping_terms, #retailer_us_shipping_terms_Other, #retailer_us_shipping_terms_Brand, #retailer_us_shipping_terms_Retailer').on('change', function(e){
		var terms = $(this).val();
		if (terms == "Other") {
			$('#other-terms-comments').fadeIn();
		} else {
			$('#other-terms-comments').fadeOut();
		}
	});
	$('#distributor_us_shipping_terms, #distributor_us_shipping_terms_Other, #distributor_us_shipping_terms_Brand, #distributor_us_shipping_terms_Retailer').on('change', function(e){
		var terms = $(this).val();
		if (terms == "Other") {
			$('#other-terms-comments').fadeIn();
		} else {
			$('#other-terms-comments').fadeOut();
		}
	});
}