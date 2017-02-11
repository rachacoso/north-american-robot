$( document ).ready(function() {
	setComments();
});

function setComments () {
	$('#show-add-comment').on('click', function(e){
		e.preventDefault();
		$('#add-comment-display').slideToggle();
	});
}