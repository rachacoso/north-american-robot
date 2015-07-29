$(window).on('resize', function(){
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
  $(thisDiv).height(height);
  console.log(viewportHeight, elementOffset, thisDiv, height);
}

function initConversations() {

	if (typeof conversationStage !== 'undefined') {
		var conversationID = '#conversation-' + conversationStage + '-wrapper'
		$(conversationID).slideDown();
		setDivHeight('#profile-conversation-wrapper');
		setDivHeight('#profile-profile-wrapper');

		// hack to fix bug where map-subhead wasn't being factored in convo block resize
		if (typeof addOffset !== 'undefined') { 
			setDivHeight('.conversation-block', 20 + addOffset);
			setDivHeight('#conversation-action', 20 + addOffset);
		} else {
			setDivHeight('.conversation-block', 20);
			setDivHeight('#conversation-action', 20);
		}
	}

	var animationSpeed = 500

	$('#conversation-action-toggle').on('click', function(e){
		e.preventDefault();
		$('.overlay#action-two').show();
		$('.conversation-action-tile#action-two').show(animationSpeed);
	});		
	$('#conversation-action-cancel, .overlay#action-two').on('click', function(e){
		e.preventDefault();
		$('.overlay#action-two').hide();
		$('.conversation-action-tile#action-two').hide(animationSpeed);
	});		

	$('#message-input').on('focus', function(){
		$('.conversation-block #message-input').animate({height:'14em'}, function() {
			$('#message-submit').show();
			$('#message-cancel').show();	
		});
	});
	$('#message-cancel').on('click', function(e){
		e.preventDefault();
		$('.conversation-block #message-input').animate({height:'1em'});
		$('#message-submit').hide();
		$('#message-cancel').hide();
	});

	$('.testing-selector').on('change', function(e){
		id = $(this).data("testing");
		thisOne = "#testing-" + id + "-text";
    if($(this).is(':checked')) {
    	$(thisOne).prop('disabled', false);
      $(thisOne).show(500);
    } else {
    	$(thisOne).prop('disabled', true);
			$(thisOne).hide(500);
    }
	});


}