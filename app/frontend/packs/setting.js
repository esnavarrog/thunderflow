$(document).on('turbolinks:load', events )

function events() {
    $('body').on('change', '.save-setting', function(){
        let data = {};
        data[$(this).data('key')] = $(this).val();
        $.ajax({
            url: $(this).data('url'),
            method: 'PUT',
            dataType: 'script',
            data: data,
            success: function(data){
                $('#liveToast').toast('show');
                $('#liveToast').find('strong').html('Actualizado');
                $('#liveToast').find('small').html(new Date().toLocaleString());
                $('#liveToast').find('.toast-body').html('Se actualizó correctamente la configuración');
            },
            error: function(data){
                $('#liveToast').toast('show');
                $('#liveToast').find('strong').html('Error');
                $('#liveToast').find('small').html(new Date().toLocaleString());
                $('#liveToast').find('small').html('No se pudo actualizar la configuración');
                $('#liveToast').find('.toast-body').html('No se pudo actualizar la configuración');
            }
        })
    })
}