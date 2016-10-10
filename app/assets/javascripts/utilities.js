$('.auto-form-text').on('change', function(e){
    var thisForm = $(this).parents('form');
    if (typeof timer !== 'undefined') {
        clearTimeout(timer);
    }
    var timer = window.setTimeout( (function( e ) {
        return function() {
            $(thisForm).submit();
        };
    }( e )), 500);
});

$('.auto-form').on('change', function(e){
    var thisForm = $(this).parents('form');
    $(thisForm).submit(); 
});