$( document ).ready(function() {

	setAdminModalActions();

});

$('#orders-search-input-brands').devbridgeAutocomplete({
  serviceUrl: '/admin/orders/search/pre/brands',
  minChars: 0,
  delimiter: ', ',
  showNoSuggestionNotice: true,
  noSuggestionNotice: 'Sorry, no matching results',
  tabDisabled: true,
  triggerSelectOnValidInput: true,
  onSelect: function (suggestion) {
    var thisForm = $(this).parents('form');
    $(thisForm).submit(); 
  }
});

$('#orders-search-input-buyers').devbridgeAutocomplete({
  serviceUrl: '/admin/orders/search/pre/buyers',
  minChars: 0,
  delimiter: ', ',
  showNoSuggestionNotice: true,
  noSuggestionNotice: 'Sorry, no matching results',
  tabDisabled: true,
  triggerSelectOnValidInput: true,  
  onSelect: function (suggestion) {
    var thisForm = $(this).parents('form');
    $(thisForm).submit(); 
    console.log('did it');
  }
});

function setAdminModalActions () {

	$('.overlay#inventory-item-overlay, a#close-inventory-item, a#submit-close').on('click', function(e){
		e.preventDefault();
		$('#inventory-item').fadeOut();
		$('.overlay').fadeOut();
	});

}

function resetSortableTables () {
  var newTables = document.getElementsByClassName('sortable'),
      i = newTables.length;

  while (i--) {
    sorttable.makeSortable(newTable[i]);
    console.log(newTable[i]);
  }
}