$( document ).ready(function() {

    initializeAutoForm();

});

function initializeAutoForm() {

    var autoformtimer;
    $('.auto-form-text').unbind('input propertychange').on('input propertychange', function(e){
        var thisForm = $(this).parents('form');        
        if (typeof autoformtimer !== 'undefined') {
            clearTimeout(autoformtimer);
            autoformtimer = null;
        }
        autoformtimer = window.setTimeout( function() {
            $(thisForm).submit();
        }, 750);

    });
    $('.auto-form-text-delay').unbind('input propertychange').on('input propertychange', function(e){
        var thisForm = $(this).parents('form');        
        if (typeof autoformtimer !== 'undefined') {
            clearTimeout(autoformtimer);
            autoformtimer = null;
        }
        autoformtimer = window.setTimeout( function() {
            $(thisForm).submit();
        }, 3000);

    });

    $('.auto-form').unbind('change').on('change', function(e){
        var thisForm = $(this).parents('form');
        $(thisForm).submit();
    });

}