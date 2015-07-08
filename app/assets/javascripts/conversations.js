$(window).on('resize', function(){
	initConversations();
});

function setDivHeight(thisDiv, offset) {
	offset = typeof offset !== 'undefined' ?  offset : 1;

	var viewportHeight = $(window).height(),
	    elementOffset = $(thisDiv).offset().top,
	    height      = (viewportHeight - elementOffset - offset);
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

}

$( document ).ready(function() {
		var animationSpeed = 500

	$('#contact-toggle').on('click', function(e){
		e.preventDefault();

		$('#conversation-contact-wrapper').slideDown(animationSpeed);
		$('#conversation-prepare-wrapper').slideUp(animationSpeed);
		$('#conversation-terms-wrapper').slideUp(animationSpeed);
		$('#conversation-order-wrapper').slideUp(animationSpeed);

		$('#conversation-map-contact-subhead').show(animationSpeed);
		$('#conversation-map-prepare-subhead').hide(animationSpeed);
		$('#conversation-map-terms-subhead').hide(animationSpeed);
		$('#conversation-map-order-subhead').hide(animationSpeed);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-contact').addClass('viewing');
	});

	$('#prepare-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper').slideUp(animationSpeed);
		$('#conversation-prepare-wrapper').slideDown(animationSpeed);
		$('#conversation-terms-wrapper').slideUp(animationSpeed);
		$('#conversation-order-wrapper').slideUp(animationSpeed);

		$('#conversation-map-contact-subhead').hide(animationSpeed);
		$('#conversation-map-prepare-subhead').show(animationSpeed);
		$('#conversation-map-terms-subhead').hide(animationSpeed);
		$('#conversation-map-order-subhead').hide(animationSpeed);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-prepare').addClass('viewing');
	});

	$('#terms-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper').slideUp(animationSpeed);
		$('#conversation-prepare-wrapper').slideUp(animationSpeed);
		$('#conversation-terms-wrapper').slideDown(animationSpeed);
		$('#conversation-order-wrapper').slideUp(animationSpeed);

		$('#conversation-map-contact-subhead').hide(animationSpeed);
		$('#conversation-map-prepare-subhead').hide(animationSpeed);
		$('#conversation-map-terms-subhead').show(animationSpeed);
		$('#conversation-map-order-subhead').hide(animationSpeed);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-terms').addClass('viewing');
	});

	$('#order-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper').slideUp(animationSpeed);
		$('#conversation-prepare-wrapper').slideUp(animationSpeed);
		$('#conversation-terms-wrapper').slideUp(animationSpeed);
		$('#conversation-order-wrapper').slideDown(animationSpeed);

		$('#conversation-map-contact-subhead').hide(animationSpeed);
		$('#conversation-map-prepare-subhead').hide(animationSpeed);
		$('#conversation-map-terms-subhead').hide(animationSpeed);
		$('#conversation-map-order-subhead').show(animationSpeed);

		$('.convo-map').removeClass('viewing');
		$('#conversation-map-order').addClass('viewing');
	});		

	$('#contact-action-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper .conversation-left-info-column').removeClass('medium-4').addClass('medium-6');
		$('#conversation-contact-wrapper .conversation-right-message-column').removeClass('medium-8').addClass('medium-6');
		$('.conversation-action#contact-one').hide(animationSpeed);
		$('.conversation-action#contact-two').show(animationSpeed);
	});		
	$('#contact-action-cancel').on('click', function(e){
		e.preventDefault();
		$('#conversation-contact-wrapper .conversation-left-info-column').removeClass('medium-6').addClass('medium-4');
		$('#conversation-contact-wrapper .conversation-right-message-column').removeClass('medium-6').addClass('medium-8');
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

});
