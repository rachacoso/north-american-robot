$(document).ready(function() {
    var text_max = 500;
    $('#brand_brand_positioning, #distributor_company_introduction').on('keyup', function() {
        var text_length = $( this ).val().length;
        var text_remaining = text_max - text_length;
        if (text_remaining < 0) {
					text_remaining = text_remaining * -1
					remaining_or_over = 'characters over'
        } else {
					remaining_or_over = 'characters remaining'
        }
        $('#company-info-feedback').html( text_remaining + ' ' + remaining_or_over );
    });
});