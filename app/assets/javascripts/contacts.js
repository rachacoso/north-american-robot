
$( document ).ready(function() {

	initializeContacts();

});


function initializeContacts () {
	$('.contact-edit-link').on('click', function(e){
		e.preventDefault();
		var linkTo = $( this ).data('link');
		var openThis = "#contact-edit-" + linkTo
		var closeThis = "#contact-view-" + linkTo

		$(openThis).slideToggle();
		$(closeThis).slideToggle();

		// alert(openThis);
		// alert(closeThis);
	});

	$('.contact-update-submit').on('click', function(e){
		e.preventDefault();
		var linkTo = $( this ).data('link');
		var submitThis = "#edit_contact_" + linkTo

		$(submitThis).submit();
		// alert(submitThis);
	});

}
