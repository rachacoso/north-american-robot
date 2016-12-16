$( document ).ready(function() {

	setAdminModalActions();

});

function setAdminModalActions () {

	$('.overlay#inventory-item-overlay, a#close-inventory-item, a#submit-close').on('click', function(e){
		e.preventDefault();
		$('#inventory-item').fadeOut();
		$('.overlay').fadeOut();
	});

}