
$( document ).on('turbolinks:load', common_events)

function common_events(){

    $('body').on('change', '.selected-branch-resource', function(){
        let branchId = $(this).val();
        $.ajax({
            method: 'GET',
            url: '/branch_address',
            dataType: 'json',
            data: {id:branchId},
            success: function(data){
                if (!$('#address-branch-selected').hasClass('active')){
                    $('#address-branch-selected').addClass('active')
                }
                $('#address-branch-selected').html(data["address_concat"])
            }
        })
    })

    $('body').on('keyup', '#resource_web_address', function(e){
        let url = $(e.target).val();
        if (/^https:\/\//.test(url)){
            $(e.target).removeClass('is-invalid')
        }else{
            if(!$(e.target).hasClass('is-invalid')){
                $(e.target).addClass('is-invalid')
            }
        }
    })

}