$(window).on('resize', function(){
	// alert(conversationStage);
	initConversations();
});

function setDivHeight(thisDiv, offset) {
	offset = typeof offset !== 'undefined' ?  offset : 1;
	var viewportHeight = $(window).height(),
	    elementOffset = $(thisDiv).offset().top,
	    height      = (viewportHeight - elementOffset - offset);
	console.log(thisDiv, "viewport:", viewportHeight, "offset:", elementOffset, "height:", height);
  $(thisDiv).height(height);
}

function initConversations() {

	var animationSpeed = 500,
		conversationID = '#conversation-' + conversationStage + '-wrapper',
		conversationMapID = '#conversation-map-' + conversationStage + '-subhead';
	$(conversationID).slideDown();
	$(conversationMapID).slideDown();

	setDivHeight('#profile-conversation-wrapper');
	setDivHeight('#profile-profile-wrapper');
	setDivHeight('.conversation-block', 5);
	setDivHeight('.conversation-left-info-column', 5);

	$('#contact-action-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper .conversation-left-info-column').removeClass('medium-4').addClass('medium-6');
		$('#conversation-contact-wrapper .conversation-right-message-column').removeClass('medium-8').addClass('medium-6');
		$('.conversation-help').hide(animationSpeed);
		$('.conversation-action#contact-one').hide(animationSpeed);
		$('.conversation-action#contact-two').show(animationSpeed);
	});		
	$('#contact-action-cancel').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper .conversation-left-info-column').removeClass('medium-6').addClass('medium-4');
		$('#conversation-contact-wrapper .conversation-right-message-column').removeClass('medium-6').addClass('medium-8');
		$('.conversation-help').show(animationSpeed);
		$('.conversation-action#contact-one').show(animationSpeed);
		$('.conversation-action#contact-two').hide(animationSpeed);
	});		

	$('#message-input').on('focus', function(){
		$('.conversation-block #top').animate({height:'45%'});
		$('.conversation-block #bottom').animate({height:'55%'});
		$('.conversation-block #message-input').animate({height:'15em'}, function() {
			$('#message-submit').show();
			$('#message-cancel').show();	
		});
	});
	$('#message-cancel').on('click', function(e){
		e.preventDefault();
		$('.conversation-block #top').animate({height:'75%'});
		$('.conversation-block #bottom').animate({height:'25%'});
		$('.conversation-block #message-input').animate({height:'5em'});
		$('#message-submit').hide();
		$('#message-cancel').hide();
	});

}
