$('.auto-form').on('change', function(e){
    var thisForm = $(this).parents('form');
    $(thisForm).submit(); 
});