var hasBG = typeof bgImage != 'undefined';
var bgDefaultColor = "#FFFFFF";


function doBackstretch (location, photos, durationTime, fadeTime) {
   durationTime = typeof durationTime !== 'undefined' ? durationTime : 3000;
   fadeTime = typeof fadeTime !== 'undefined' ? fadeTime : 750;
  $(location).backstretch(
    photos
   , {duration: durationTime, fade: fadeTime});
}

$( document ).ready(function() {

// DROPDOWN MENU
$('.dropmenu').dropit();

// ADJUST HEIGHT OF PROFILE GALLERY AND INFO

  // profileGalleryHeight(); 



// MODIFICATIONS FOR NO SVG SUPPORT
  if(!Modernizr.svg) {
    /* swap png for svgs */
    $('img[src*="svg"]').attr('src', function () {
    return $(this).attr('src').replace('.svg', '.png');
    });
  }


// for background map on matches
  var divWidth = $('#match-map-container').width();
  var setHeight = divWidth / 1.9;
  $('#match-map-container').height( setHeight );

  // // set min height for content area
  // var sideWidth = $('#side-nav-content').width();
  // var sideHeight = sideWidth / 1.9;
  // $('#side-nav-content').css('min-height' , sideHeight );

  $(window).on('resize', function(e){
    var divWidth = $('#match-map-container').width();
    var setHeight = divWidth / 1.9;
    $('#match-map-container').height( setHeight );    
  });




// for autocomplete
  var countriesArray = $.map(countries, function (value, key) { return { value: value, data: key }; });

// Background Img
	if (hasBG) {
		$.backstretch( bgImage, {fade: 500});	
	} else {
		var bg = (typeof bgColor != 'undefined') ? bgColor : bgDefaultColor
		$( 'body' ).css( "background", bg );
	};

  // FOR FORM COUNTRY AND DATE FIELDS
  initialize();


	$('#login').on('click', Foundation.utils.debounce(function(e){
	  $("#loginform").fadeToggle();
	}, 300, true));



// Sector/Channel - Select All & Other functionality

	// Sector

  $('#selectallsectors').click(function(event) {  //on click 
      if(this.checked) { // check select status
	      	$('#sectors_other').each(function() { //loop through each checkbox
              this.checked = false; //deselect checkboxes with id "sectors_other"                       
          });
          $('.sectors').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "sectors"               
          });
          
      }else{
          $('.sectors').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "sectors"                       
          });         
      }
  });

  $('.sectors').click(function(event) {  //on click of ANY SECTOR - make sure OTHER & SELECT ALL deselected
      if(this.checked) { // check select status
      	$('#sectors_other').each(function() { //loop through each checkbox
            this.checked = false; //deselect all checkboxes with id "sectors_other"                       
        });        
      }
    	$('#selectallsectors').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });
    
  $('#sectors_other').click(function(event) {  //on click of 'OTHER' SECTOR
      if(this.checked) { // check select status
          $('.sectors,#selectallsectors').each(function() { //loop through each checkbox
              this.checked = false;  //select all checkboxes with class "sectors"               
          });
      }
  });

  // Channels

  $('#selectallchannels').click(function(event) {  //on click 
      if(this.checked) { // check select status
          $('.channels').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "checkbox1"               
          });
      }else{
          $('.channels').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "checkbox1"                       
          });         
      }
  });

  $('.channels').click(function(event) {  //on click of ANY CHANNEL - make sure SELECT ALL deselected
    	$('#selectallchannels').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });



  // MATCHING FILTERS



  //Countries
  $('#selectallcountries').click(function(event) {  //on click 
      if(this.checked) { // check select status
          $('.mfcountry').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "checkbox1"               
          });
      }else{
          $('.mfcountry').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "checkbox1"                       
          });         
      }
  });

  $('.mfcountry').click(function(event) {  //on click of ANY CHANNEL - make sure SELECT ALL deselected
    	$('#selectallcountries').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });

  //Countries of Distribution
  $('#selectallcountriesofdistro').click(function(event) {  //on click 
      if(this.checked) { // check select status
          $('.mfcountryofdistro').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "checkbox1"               
          });
      }else{
          $('.mfcountryofdistro').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "checkbox1"                       
          });         
      }
  });

  $('.mfcountryofdistro').click(function(event) {  //on click of ANY CHANNEL - make sure SELECT ALL deselected
      $('#selectallcountriesofdistro').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });

  //Sizes
  $('#selectallsizes').click(function(event) {  //on click 
      if(this.checked) { // check select status
          $('.mfsize').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "checkbox1"               
          });
      }else{
          $('.mfsize').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "checkbox1"                       
          });         
      }
  });

  $('.mfsize').click(function(event) {  //on click of ANY CHANNEL - make sure SELECT ALL deselected
    	$('#selectallsizes').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });

  //Sectors
  $('#selectallsectors').click(function(event) {  //on click 
      if(this.checked) { // check select status
          $('.mfsector').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "checkbox1"               
          });
      }else{
          $('.mfsector').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "checkbox1"                       
          });         
      }
  });

  $('.mfsector').click(function(event) {  //on click of ANY CHANNEL - make sure SELECT ALL deselected
    	$('#selectallsectors').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });

  //Channels
  $('#selectallchannels').click(function(event) {  //on click 
      if(this.checked) { // check select status
          $('.mfchannel').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "checkbox1"               
          });
      }else{
          $('.mfchannel').each(function() { //loop through each checkbox
              this.checked = false; //deselect all checkboxes with class "checkbox1"                       
          });         
      }
  });

  $('.mfchannel').click(function(event) {  //on click of ANY CHANNEL - make sure SELECT ALL deselected
    	$('#selectallchannels').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with id "sectors_other"                       
      });        
  });    


  // SUBMIT FORM ON FILTER SELECT
  $('.filterform :checkbox').on('click', function(e) {
    $('#filters-form').submit();
  });
  

  // ADDING CUSTOM CHANNELS
  $('#btnSave').click(function() {
    if ($('#ccName').val()) {
      addCheckbox($('#ccName').val());
    };
  });

  $('#customchannellist').on( "click", "input", function() {
    $( this ).parent('span').remove();
  });

  $('#ccName').on('click focusin', function() {
    this.value = '';
  });


  // // LOGO PREVIEW
  // $("#brand_logo").change(function(){
  //     if (this.files && this.files[0]) {
  //         var reader = new FileReader();
  //         reader.onload = function (e) {
  //             $('#logo-preview').attr('src', e.target.result);
  //         }
  //         reader.readAsDataURL(this.files[0]);
  //     }
  // });
  // $("#distributor_logo").change(function(){
  //     if (this.files && this.files[0]) {
  //         var reader = new FileReader();
  //         reader.onload = function (e) {
  //             $('#logo-preview').attr('src', e.target.result);
  //         }
  //         reader.readAsDataURL(this.files[0]);
  //     }
  // });



});


$(document).foundation({
  accordion: {
    // specify the class used for accordion panels
    // content_class: 'content',
    // specify the class used for active (or open) accordion panels
    // active_class: 'active',
    // allow multiple accordion panels to be active at the same time
    multi_expand: false,
    // allow accordion panels to be closed by clicking on their headers
    // setting to false only closes accordion panels when another is opened
    toggleable: true
  }
});

function addCheckbox(name) {
  var container = $('#customchannellist');
  var inputs = container.find('input');
  var id = inputs.length+1;

  $('<span />', { id: 'ccspan'+id }).appendTo(container)
  $('<input />', { type: 'checkbox', id: 'cb'+id, value: name, name: 'customchannels['+id+']', checked: 'checked', class: 'customchannelinput' }).appendTo( '#' + 'ccspan' + id );
  $('<label />', { 'for': 'cb'+id, text: name }).appendTo( '#' + 'ccspan' + id );
}

// INITIALIZE GALLERIA SLIDESHOW
function profileGalleryHeight () {
  var topBarHeight = $('.top-bar').height();
  var subHeaderHeight = $('.marketplace-header').height();
  var windowHeight = $(window).height();
  var minHeight = windowHeight - (topBarHeight + subHeaderHeight);
  $('.gallery-window').css( "min-height", minHeight );  
}

// INITIALIZE GALLERIA SLIDESHOW
function initializeGallery (className,galleryHeight) {
  galleryHeight = (typeof galleryHeight === 'undefined') ? 400 : galleryHeight;
  Galleria.run(className, {
      showInfo: false,
      height: galleryHeight,
      wait: true
  })  
}



/*ALL ITEMS IN HERE ARE RE-INITIALIZED UPON AJAX RETURN*/
function initialize () {

  // FINAL TILES

  $('#profile_gallery').finalTilesGallery({
    margin:  2,
    imageSizeFactor: [[4000, .4],[1024, .4],[800, .3],[600, .3],[480, .3]],
    gridSize: 100,
    allowEnlargement: true
  });

  // // FOR PROFILE DIV BACKGROUND

  // $(".galleria-product-photos.distributor-default").backstretch( '/images/crate.jpg', {fade: 500});

  // $(".galleria-product-photos.brand-default").backstretch( '/images/brand.jpg', {fade: 500});

  // Date Picker

  $('.datepick').fdatepicker({
    format: "mm-dd-yyyy",
    startView: 0,
    minViewMode: 2
  });


  // Autocomplete 

  // Select all on focus (note: makes it so that one can't select a part of an input, 
  // but can only ever select all... shouldn't be a problem, hopefully??)

  // for COUNTRY autocomplete
  var countriesArray = $.map(countries, function (value, key) { return { value: value, data: key }; });

  $('.country-autocomplete, .country-autocomplete-multi').on('focus',
    function (e) {
      $(this).on('mouseup',
        function() {
          $(this).select();
          return false;
        })
      .select();
    });

  $('.country-autocomplete').devbridgeAutocomplete({
    lookup: countriesArray,
    minChars: 0,
    // delimiter: ',',
    // onSelect: function (suggestion) {
    //     // $('#selection').html('You selected: ' + suggestion.value + ', ' + suggestion.data);
    //     $('#<%=id_name%>_selected').val(suggestion.data);
    // },
    showNoSuggestionNotice: true,
    noSuggestionNotice: 'Sorry, no matching results',
    tabDisabled: true
  });

  $('.country-autocomplete-multi').devbridgeAutocomplete({
    lookup: countriesArray,
    minChars: 0,
    delimiter: ', ',
    // onSelect: function (suggestion) {
    //     // $('#selection').html('You selected: ' + suggestion.value + ', ' + suggestion.data);
    //     $('#<%=id_name%>_selected').val(suggestion.data);
    // },
    showNoSuggestionNotice: true,
    noSuggestionNotice: 'Sorry, no matching results',
    tabDisabled: true
  });

  $('.tags-input').devbridgeAutocomplete({
    serviceUrl: '/tags/new',
    minChars: 0,
    delimiter: ', ',
    // showNoSuggestionNotice: true,
    // noSuggestionNotice: 'Sorry, no matching results',
    triggerSelectOnValidInput: false,
    tabDisabled: true
  });

  $('#article-featured-brands-input').devbridgeAutocomplete({
    serviceUrl: '/brands/list',
    minChars: 0,
    delimiter: ', ',
    showNoSuggestionNotice: true,
    noSuggestionNotice: 'Sorry, no matching results',
    triggerSelectOnValidInput: true,
    tabDisabled: true,
    onSelect: function (suggestion) {
      $('#fb-id').val(suggestion.data);
    }
  });


  // FILE UPLOAD

  // FOR VERIFICATION IMAGES UPLOAD
  $('#distributor_verification_business_certificate, #retailer_verification_business_certificate').change(function() { 
      // select the form and submit
      $('#business-registration-form').submit(); 
  });
  // FOR VERIFICATION IMAGES UPLOAD
  $('#distributor_verification_location_photo, #retailer_verification_location_photo').change(function() { 
      // select the form and submit
      $('#location-form').submit(); 
  });
  // FOR VERIFICATION IMAGES UPLOAD
  $('#distributor_verification_brand_display_photo, #retailer_verification_brand_display_photo').change(function() { 
      // select the form and submit
      $('#brand-display-form').submit(); 
  });
  $('#distributor_logo, #brand_logo, #retailer_logo').change(function() { 
      // select the form and submit
      $('#company-info-form').submit(); 
  });     
  $('#distributor_logo, #brand_logo, #retailer_logo').change(function() { 
      // select the form and submit
      $('#b-or-d-admin-update-logo-upload').submit(); 
  });
  // FOR BRAND PHOTO UPLOAD
  $('#brand_photo_photo').change(function() { 
      // select the form and submit
      $('#brand-photo-upload').submit(); 
  });
  // FOR ARTICLE PHOTO UPLOAD
  $('#article_photo_photo').change(function() { 
      // select the form and submit
      $('#article-photo-upload').submit(); 
  });
  // FOR PRODUCT PHOTO UPLOAD
  $('.product-photo-photo').change(function() { 
      // select the form and submit
      var thisForm = $(this).parents('form');
      $(thisForm).submit(); 
  });

}


$(document)
  .ajaxStart(function () {
    $('.ajax-wait').show();
    $('.overlay#ajax-wait-overlay').show();
  })
  .ajaxStop(function () {
    $('.ajax-wait').hide();
    $('.overlay#ajax-wait-overlay').hide();
  });

function toggleTopBar(thisOne) {
  var thisBar = "#topbar-" + thisOne
  console.log(thisBar);
  $(thisBar).slideUp();
  $('#toggle-topbar').on('click', function(e){
    e.preventDefault();
    $(thisBar).slideToggle();
    setTimeout(function(){
      $(thisBar).slideUp();
    }, 5000);
  })
}


jQuery.fn.visible = function() {
    return this.css('visibility', 'visible');
};

jQuery.fn.invisible = function() {
    return this.css('visibility', 'hidden');
};

jQuery.fn.visibilityToggle = function() {
    return this.css('visibility', function(i, visibility) {
        return (visibility == 'visible') ? 'hidden' : 'visible';
    });
};

