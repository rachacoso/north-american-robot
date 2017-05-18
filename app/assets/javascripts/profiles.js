
$( document ).ready(function() {

	setModalActions();
	shippingtermsControls();
	setProfileActions();
	setEditProfileTabs();

});

function setEditProfileTabs() {
	$('#profile-edit-tabs > #required').on('click', function(e){
		e.preventDefault();
		$('#form-inputs > .optional').slideUp();
		$('.profile-edit-form.info-panel > div.optional').slideUp();
		$('#form-inputs > .required').slideDown();
		$('.profile-edit-form.info-panel > div.required').slideDown();
		$('#profile-edit-tabs > span#required').addClass('selected');
		$('#profile-edit-tabs > span#optional').removeClass('selected');
		initializeAutoForm();
	});
	$('#profile-edit-tabs > #optional').on('click', function(e){
		e.preventDefault();
		$('#form-inputs > .required').slideUp();
		$('.profile-edit-form.info-panel > div.required').slideUp();
		$('#form-inputs > .optional').slideDown();
		$('.profile-edit-form.info-panel > div.optional').slideDown();
		$('#profile-edit-tabs > span#optional').addClass('selected');
		$('#profile-edit-tabs > span#required').removeClass('selected');
		initializeAutoForm();
	});
}

function setProfileActions() {
	$('#back-control').on('click', function(e){
		e.preventDefault();
		$('#back-options').toggle();
	});
	$('#back-options').on('mouseleave', function(e) {
		$('#back-options').fadeOut();
	});
}
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
		if (typeof reloadLink !== 'undefined') {
			window.location.href = reloadLink;
			window.location.reload(true);
		} else {
			$('#error-modal').fadeOut();
			$('.overlay').fadeOut();
		}
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
