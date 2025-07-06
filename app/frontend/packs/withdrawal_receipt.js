$( document ).on('turbolinks:load', common_events)

function common_events(){
    $('body').on('change', '#withdrawal_receipt_sender_local_check', function(){
        $('#total-sender-withdrawal-receipt').html($(this).val() || 0)
    })

    $('body').on('click', '.change-withdrawal-receipt-type', function(){
        let type = $(this).data('type');
        let target = $(this).data('target');
        $(target).val(type)
    })
}
