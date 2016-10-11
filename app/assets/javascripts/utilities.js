$( document ).ready(function() {

    initializeAutoForm();

});

function initializeAutoForm() {

    $('.auto-form-text').on('keyup', function(e){
        var thisForm = $(this).parents('form');        
        if (typeof autoformtimer !== 'undefined') {
            clearTimeout(autoformtimer);
            autoformtimer = null;
        }
        var autoformtimer = window.setTimeout( function() {
            $(thisForm).submit();
        }, 2000);
    });

    $('.auto-form').on('change', function(e){
        var thisForm = $(this).parents('form');
        $(thisForm).submit(); 
    });

}