$( document ).ready(function() {

    initializeAutoForm();
    toggleFormText();

});

function showModal(data) {
    $('#modal').html(data);
    $('#modal').fadeIn( 200, function () {
        $('#modal-container').animate( {top: "10%"}, 200 );
    });
    $('#modal-overlay, a.modal-close').on('click', function(e){
        e.preventDefault();
        $('#modal-container').animate( {top: "-50%"}, 200, function() { 
            $('#modal').fadeOut( 200, function() {
                $( this ).empty();
              });
        });
    });
}

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

function toggleFormText() {
    $('.toggle-text').click(function() {
        var onText = $(this).data('on');
        var offText = $(this).data('off');
        if ($(this).is(':checked')) {
            $(this).siblings('label').html(onText);
        } else {
            $(this).siblings('label').html(offText);
        }
    });

}