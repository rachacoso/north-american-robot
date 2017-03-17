$( document ).ready(function() {

	setAdminModalActions();

});

$('#orders-search-input').devbridgeAutocomplete({
  serviceUrl: '/admin/orders/search/pre',
  minChars: 0,
  delimiter: ', ',
  showNoSuggestionNotice: false,
  // noSuggestionNotice: 'Sorry, no matching results',
  triggerSelectOnValidInput: false,
  tabDisabled: true
  // onSelect: function (suggestion) {
  //   $('#fb-id').val(suggestion.data);
  // }
});

function setAdminModalActions () {

	$('.overlay#inventory-item-overlay, a#close-inventory-item, a#submit-close').on('click', function(e){
		e.preventDefault();
		$('#inventory-item').fadeOut();
		$('.overlay').fadeOut();
	});

}