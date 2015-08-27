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
  $(thisDiv).css("min-height", height);
  console.log(viewportHeight, elementOffset, thisDiv, height);
}

function initConversations() {

	if (typeof conversationStage !== 'undefined') {
		var conversationID = '#conversation-' + conversationStage + '-wrapper'
		$(conversationID).slideDown();
		// setDivHeight('#profile-conversation-wrapper');
		// setDivHeight('#profile-profile-wrapper');

		// hack to fix bug where map-subhead wasn't being factored in convo block resize
		// if (typeof addOffset !== 'undefined') { 
		// 	setDivHeight('.conversation-block', addOffset);
		// 	setDivHeight('#conversation-action', addOffset);
		// } else {
		// 	setDivHeight('.conversation-block');
		// 	setDivHeight('#conversation-action');
		// }
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

	$('#view-termsheet').on('click', function(e){
		e.preventDefault();

		var ajaxURL = $(this).data("ajaxurl")

		var getContract = $.get( ajaxURL, function( data ) {
			// alert(ajaxURL);
		  $('#quick-view-data').html(data);
		})
		  .done(function() {
				$('.overlay#quick-view-overlay').fadeIn();
				$('#quick-view').fadeIn();
				
				$(document).foundation('tooltip', 'reflow');

		  })
		  // .fail(function() {
		  //   alert( "error" );
		  // })
		  // .always(function() {
		  //   alert( "finished" );
		  // });
		 
		// Perform other work here ...
		 
		// Set another completion function for the request above
		// getContract.always(function() {
		//   alert( "second finished" );
		// });
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