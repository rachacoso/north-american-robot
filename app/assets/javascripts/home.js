$( document ).ready(function() {

	setOnboardModals();

});


function setOnboardModals () {
	$('a#close-onboard-modal,a#close-onboard-modal-button').on('click', function(e){
		e.preventDefault();
		$('#onboard-modal').fadeOut();
		$('.overlay').fadeOut();
		$('#onboard-modal-next').removeClass('show');
		$('body').removeClass('noscroll');
	});	
}