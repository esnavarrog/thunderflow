$( document ).on('turbolinks:load', common_events)

function common_events(){
    $('body').on('click', '#send-tracking', function(){
        let number_tracking = $('#tracking').val()

        let url = $(this).data('url')
        let dataType = $(this).data('datatype')
        $('#tracking-result').removeClass('d-none')
        $('.loader-tracking').removeClass('d-none')
        $.ajax({
            type: 'GET',
            dataType: dataType,
            url: url,
            data:{number_tracking: number_tracking}
        });
    })


}