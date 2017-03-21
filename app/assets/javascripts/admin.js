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

$('#orders-search-input-buyers, #orders-search-input-brands').focus(function() {
    var $this = $(this);

    $this.select();

    window.setTimeout(function() {
        $this.select();
    }, 1);

    // Work around WebKit's little problem
    function mouseUpHandler() {
        // Prevent further mouseup intervention
        $this.off("mouseup", mouseUpHandler);
        return false;
    }

    $this.mouseup(mouseUpHandler);
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