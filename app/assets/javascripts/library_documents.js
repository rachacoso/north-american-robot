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
  $('#library-certification-information-input').change(function() { 
      // select the form and submit
      $('#library-certification-information-form').submit(); 
  });
  $('#library-patent-information-input').change(function() { 
      // select the form and submit
      $('#library-patent-information-form').submit(); 
  });
  $('#library-testing-information-input').change(function() { 
      // select the form and submit
      $('#library-testing-information-form').submit(); 
  });
  $('#library-ingredient-or-materials-list-input').change(function() { 
      // select the form and submit
      $('#library-ingredient-or-materials-list-form').submit(); 
  });

  $('.library-doc-display-name-input').change(function() {
  	$( this ).closest("form").submit();
  });
});