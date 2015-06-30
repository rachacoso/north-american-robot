
function initConversations() {
	var conversationInfoID = '#conversation-info-' + conversationStage
	var conversationID = '#conversation-' + conversationStage
	$(conversationInfoID).show();
	$(conversationID).show();

	$('#contact-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-info-contact').toggle(1000);
		$('#conversation-contact').toggle(1000);
		$('#conversation-info-prepare').hide(1000);
		$('#conversation-prepare').hide(1000);
		$('#conversation-info-terms').hide(1000);
		$('#conversation-terms').hide(1000);
		$('#conversation-info-order').hide(1000);
		$('#conversation-order').hide(1000);		
	});

	$('#prepare-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-info-contact').hide(1000);
		$('#conversation-contact').hide(1000);
		$('#conversation-info-prepare').toggle(1000);
		$('#conversation-prepare').toggle(1000);
		$('#conversation-info-terms').hide(1000);
		$('#conversation-terms').hide(1000);
		$('#conversation-info-order').hide(1000);
		$('#conversation-order').hide(1000);	
	});

	$('#terms-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-info-contact').hide(1000);
		$('#conversation-contact').hide(1000);
		$('#conversation-info-prepare').hide(1000);
		$('#conversation-prepare').hide(1000);
		$('#conversation-info-terms').toggle(1000);
		$('#conversation-terms').toggle(1000);
		$('#conversation-info-order').hide(1000);
		$('#conversation-order').hide(1000);		
	});

	$('#order-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-info-contact').hide(1000);
		$('#conversation-contact').hide(1000);
		$('#conversation-info-prepare').hide(1000);
		$('#conversation-prepare').hide(1000);
		$('#conversation-info-terms').hide(1000);
		$('#conversation-terms').hide(1000);
		$('#conversation-info-order').toggle(1000);
		$('#conversation-order').toggle(1000);	
	});		

}
