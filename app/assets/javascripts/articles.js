
$('#article-featured-brands-input').devbridgeAutocomplete({
  serviceUrl: '/brands/list',
  minChars: 0,
  delimiter: ', ',
  showNoSuggestionNotice: true,
  noSuggestionNotice: 'Sorry, no matching results',
  triggerSelectOnValidInput: true,
  tabDisabled: true,
  onSelect: function (suggestion) {
    $('#fb-id').val(suggestion.data);
  }
});

$('#article-featured-products-input').devbridgeAutocomplete({
  serviceUrl: '/products/list',
  minChars: 0,
  delimiter: ', ',
  showNoSuggestionNotice: true,
  noSuggestionNotice: 'Sorry, no matching results',
  triggerSelectOnValidInput: true,
  tabDisabled: true,
  onSelect: function (suggestion) {
    $('#fp-id').val(suggestion.data);
  }
});