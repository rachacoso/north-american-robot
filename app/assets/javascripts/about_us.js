
$( document ).ready(function() {

	setAboutUsTabs();

});

function setAboutUsTabs() {
	$('#about-us-tabs > #team').on('click', function(e){
		e.preventDefault();
		$('div#brand').hide();
		$('div#retail').hide();
		$('div#press').hide();
		$('div#team').show();		
		$('#about-us-tabs > #team').addClass('selected');
		$('#about-us-tabs > #brand').removeClass('selected');
		$('#about-us-tabs > #retail').removeClass('selected');
		$('#about-us-tabs > #press').removeClass('selected');
	});
	$('#about-us-tabs > #brand').on('click', function(e){
		e.preventDefault();
		$('div#team').hide();
		$('div#brand').show();
		$('div#retail').hide();
		$('div#press').hide();
		$('#about-us-tabs > #team').removeClass('selected');
		$('#about-us-tabs > #brand').addClass('selected');
		$('#about-us-tabs > #retail').removeClass('selected');
		$('#about-us-tabs > #press').removeClass('selected');
	});
	$('#about-us-tabs > #retail').on('click', function(e){
		e.preventDefault();
		$('div#team').hide();
		$('div#brand').hide();
		$('div#retail').show();
		$('div#press').hide();
		$('#about-us-tabs > #team').removeClass('selected');
		$('#about-us-tabs > #brand').removeClass('selected');
		$('#about-us-tabs > #retail').addClass('selected');
		$('#about-us-tabs > #press').removeClass('selected');
	});
	$('#about-us-tabs > #press').on('click', function(e){
		e.preventDefault();
		$('div#team').hide();
		$('div#brand').hide();
		$('div#retail').hide();
		$('div#press').show();
		$('#about-us-tabs > #team').removeClass('selected');
		$('#about-us-tabs > #brand').removeClass('selected');
		$('#about-us-tabs > #retail').removeClass('selected');
		$('#about-us-tabs > #press').addClass('selected');
	});
}