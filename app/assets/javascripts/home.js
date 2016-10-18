$( document ).ready(function() {

	setOnboardModals();

});


function setOnboardModals () {
	$('a#close-onboard-modal').on('click', function(e){
		e.preventDefault();
		$('#onboard-modal').fadeOut();
		$('.overlay').fadeOut();
	});	

	// $('.overlay#order-item-overlay, a#close-order-item, a#submit-close').on('click', function(e){
	// 	e.preventDefault();
	// 	$('#order-item').fadeOut();
	// 	$('.overlay').fadeOut();
	// });

}