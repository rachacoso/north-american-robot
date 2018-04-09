
$( document ).ready(function() {

	setAboutUsTabs();

});

function setAboutUsTabs() {
	$('#about-us-tabs > #team').on('click', function(e){
		e.preventDefault();
		$('div#brand').fadeOut();
		$('div#retail').fadeOut();
		$('div#press').fadeOut();
		$('div#team').fadeIn();		
		$('#about-us-tabs > #team').addClass('selected');
		$('#about-us-tabs > #brand').removeClass('selected');
		$('#about-us-tabs > #retail').removeClass('selected');
		$('#about-us-tabs > #press').removeClass('selected');
	});
	$('#about-us-tabs > #brand').on('click', function(e){
		e.preventDefault();
		$('div#team').fadeOut();
		$('div#brand').fadeIn();
		$('div#retail').fadeOut();
		$('div#press').fadeOut();
		$('#about-us-tabs > #team').removeClass('selected');
		$('#about-us-tabs > #brand').addClass('selected');
		$('#about-us-tabs > #retail').removeClass('selected');
		$('#about-us-tabs > #press').removeClass('selected');
	});
	$('#about-us-tabs > #retail').on('click', function(e){
		e.preventDefault();
		$('div#team').fadeOut();
		$('div#brand').fadeOut();
		$('div#retail').fadeIn();
		$('div#press').fadeOut();
		$('#about-us-tabs > #team').removeClass('selected');
		$('#about-us-tabs > #brand').removeClass('selected');
		$('#about-us-tabs > #retail').addClass('selected');
		$('#about-us-tabs > #press').removeClass('selected');
	});
	$('#about-us-tabs > #press').on('click', function(e){
		e.preventDefault();
		$('div#team').fadeOut();
		$('div#brand').fadeOut();
		$('div#retail').fadeOut();
		$('div#press').fadeIn();
		$('#about-us-tabs > #team').removeClass('selected');
		$('#about-us-tabs > #brand').removeClass('selected');
		$('#about-us-tabs > #retail').removeClass('selected');
		$('#about-us-tabs > #press').addClass('selected');
	});
}