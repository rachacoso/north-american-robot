
function initConversations() {
	var conversationID = '#conversation-' + conversationStage + '-wrapper'
	$(conversationID).show();

	$('#contact-toggle').on('click', function(e){
		e.preventDefault();

		$('#conversation-contact-wrapper').show(1000);
		$('#conversation-prepare-wrapper').hide(1000);
		$('#conversation-terms-wrapper').hide(1000);
		$('#conversation-order-wrapper').hide(1000);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-contact').addClass('viewing');
	});

	$('#prepare-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper').hide(1000);
		$('#conversation-prepare-wrapper').show(1000);
		$('#conversation-terms-wrapper').hide(1000);
		$('#conversation-order-wrapper').hide(1000);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-prepare').addClass('viewing');
	});

	$('#terms-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper').hide(1000);
		$('#conversation-prepare-wrapper').hide(1000);
		$('#conversation-terms-wrapper').show(1000);
		$('#conversation-order-wrapper').hide(1000);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-terms').addClass('viewing');
	});

	$('#order-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper').hide(1000);
		$('#conversation-prepare-wrapper').hide(1000);
		$('#conversation-terms-wrapper').hide(1000);
		$('#conversation-order-wrapper').show(1000);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-order').addClass('viewing');
	});		

}
