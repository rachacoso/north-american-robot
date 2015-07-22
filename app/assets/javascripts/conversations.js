$(window).on('resize', function(){
	// alert(conversationStage);
	initConversations();
});

$( document ).ready(function() {
	$('#contact-start-trigger').on('click', function(e){
		e.preventDefault();
		$('#contact-start').slideToggle(500);
		$(document.body).animate({
		    'scrollTop':   $('#contact-start-trigger').offset().top - 150
		}, 500);

	});
});

function setDivHeight(thisDiv, offset) {
	offset = typeof offset !== 'undefined' ?  offset : 0;
	var viewportHeight = $(window).height(),
	    elementOffset = $(thisDiv).offset().top,
	    height      = (viewportHeight - elementOffset - offset);
	// console.log(thisDiv, "viewport:", viewportHeight, "offset:", elementOffset, "height:", height);
  $(thisDiv).height(height);
  console.log(viewportHeight, elementOffset, thisDiv, height);
}

function initConversations() {

	if (typeof conversationStage !== 'undefined') {
		var conversationID = '#conversation-' + conversationStage + '-wrapper'
		$(conversationID).slideDown();
		setDivHeight('#profile-conversation-wrapper');
		setDivHeight('#profile-profile-wrapper');
		setDivHeight('.conversation-left-info-column');

		// hack to fix bug where map-subhead wasn't being factored in convo block resize
		if (typeof addOffset !== 'undefined') { 
			setDivHeight('.conversation-block', 25 + addOffset);
		} else {
			setDivHeight('.conversation-block', 25);
		}
	}

	var animationSpeed = 500

	$('#propose-action-toggle').on('click', function(e){
		e.preventDefault();
		$('#conversation-wrapper .conversation-left-info-column').removeClass('medium-4').addClass('medium-6');
		$('#conversation-wrapper .conversation-right-message-column').removeClass('medium-8').addClass('medium-6');
		$('.conversation-help').hide(animationSpeed);
		$('.conversation-action#action-one').hide(animationSpeed);
		$('.conversation-action#action-two').show(animationSpeed);
	});		
	$('#propose-action-cancel').on('click', function(e){
		e.preventDefault();
		$('#conversation-wrapper .conversation-left-info-column').removeClass('medium-6').addClass('medium-4');
		$('#conversation-wrapper .conversation-right-message-column').removeClass('medium-6').addClass('medium-8');
		$('.conversation-help').show(animationSpeed);
		$('.conversation-action#action-one').show(animationSpeed);
		$('.conversation-action#action-two').hide(animationSpeed);
	});		

	$('#message-start').on('click', function(){
		$('.conversation-block #view-messages').animate({height:'45%'});
		$('.conversation-block #send-message').animate({height:'50%'});
		// $('.conversation-block #old-messages-indicator').animate({height:'5%'});
		$('.conversation-block #message-input').animate({height:'14em'}, function() {
			$('#message-submit').show();
			$('#message-cancel').show();	
		});
	});

	$('#message-input').on('focus', function(){
		// $('.conversation-block #view-messages').animate({height:'45%'});
		// $('.conversation-block #send-message').animate({height:'50%'});
		// $('.conversation-block #old-messages-indicator').animate({height:'5%'});
		$('.conversation-block #message-input').animate({height:'14em'}, function() {
			$('#message-submit').show();
			$('#message-cancel').show();	
		});
	});
	$('#message-cancel').on('click', function(e){
		e.preventDefault();
		// $('.conversation-block #view-messages').animate({height:'70%'});
		// $('.conversation-block #send-message').animate({height:'25%'});
		// $('.conversation-block #old-messages-indicator').animate({height:'5%'});
		$('.conversation-block #message-input').animate({height:'1em'});
		$('#message-submit').hide();
		$('#message-cancel').hide();
		// $(".conversation-block #top").animate({ scrollTop: $(".conversation-block #top")[0].scrollHeight}, 1000);
	});

}
