$( document ).on('turbolinks:load', common_events)

function common_events(){
    $('body').on('change', '.box-profile-form input, .box-profile-form select', function(){
        $(this).parent().parent().find("input[type=submit]").trigger('click');
    })
}