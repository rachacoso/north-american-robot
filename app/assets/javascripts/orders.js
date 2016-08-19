$( document ).ready(function() {

	initializeShipCancel();

});

function initializeShipCancel() {
	$("#ship-date-form input[type=text]").change(function(){
		$("#ship-date-form").submit();
	});

	$("#cancel-date-form input[type=text]").change(function(){
		$("#cancel-date-form").submit();
	});

	$("#shipping-address-form input[type=text]").change(function(){
		$("#shipping-address-form").submit();
	});
}