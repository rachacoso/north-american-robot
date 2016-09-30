$(document).ready(function() {
  initializeArticleImages();
});

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
  params: {
    'article_id': function() {
      return $('#article-id').val();
    }
  },
  onSelect: function (suggestion) {
    $('#fp-id').val(suggestion.data);
  }
});



function initializeArticleImages() {
  $("#article-carousel").owlCarousel({

      loop:true,
      autoPlay: 5000,
      stopOnHover:true,
      slideSpeed : 300,
      paginationSpeed : 400,
      singleItem:true,
      // navigation : true,
      // navigationText : [
      //   "<img src='/images/v2/left-arrow.svg'>",
      //   "<img src='/images/v2/right-arrow.svg'>",
      // ],
      // "singleItem:true" is a shortcut for:
      // items : 1, 
      // itemsDesktop : false,
      // itemsDesktopSmall : false,
      // itemsTablet: false,
      // itemsMobile : false

  });
}
                      