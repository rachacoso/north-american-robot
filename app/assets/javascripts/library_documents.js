$( document ).ready(function() {
  $('#library-products-list-input').change(function() { 
      // select the form and submit
      $('#library-products-list-form').submit(); 
  });
  $('#library-fob-pricing-input').change(function() { 
      // select the form and submit
      $('#library-fob-pricing-form').submit(); 
  });
  $('#library-tiered-pricing-schedule-input').change(function() { 
      // select the form and submit
      $('#library-tiered-pricing-schedule-form').submit(); 
  });  

  $('.library-doc-display-name-input').change(function() {
  	$( this ).closest("form").submit();

  });
});