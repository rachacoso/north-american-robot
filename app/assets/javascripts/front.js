$(document).ready(function() {
 
  $("#owl-front-carousel").owlCarousel({
		// navigation : true, // Show next and prev buttons
		loop:true,
		slideSpeed : 300,
		autoPlay: 5000,
		stopOnHover:true,
		paginationSpeed : 400,
		singleItem:true
  });

  $("#new-brand-carousel").owlCarousel({
		// navigation : true, // Show next and prev buttons
		loop:true,
		slideSpeed : 300,
		autoPlay: 5000,
		stopOnHover:true,
		paginationSpeed : 400,
		singleItem:true
  });

  $("input[type='radio']#user_type_brand, input[type='radio']#user_type_retailer, input[type='radio']#user_type_distributor").on('change', function (e) {
  	if ($(this).val()=="brand")
  	{
  		$('#brand-subscription-info').css("visibility", "visible").hide().fadeIn('slow');
  	}
	else 
	{
		$('#brand-subscription-info').css("visibility", "hidden");
	}
  });

});