$(document).on('change', '.save-default-price', function() {
    const url = '/default_profile_prices';
    const profile = $(this).data('profile');
    const price = $(this).val();

    $.ajax({
        url: url,
        method: 'POST',
        data: {
            default_price: {
                name_profile: profile,
                price: price
            }
        }
    });
});