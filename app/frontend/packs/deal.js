$( document ).on('turbolinks:load', common_events)

$(document).on('turbolinks:before-cache', function() {
    $('.js-basic-single').select2('destroy');
} );

function common_events(){

    $(".datetimepicker-range").flatpickr({
        dateFormat: "d-m-Y",
        mode: "range",
        locale: "es"
    });

    function datetimePickerTime(){
        $(".datetimepicker-time").flatpickr({
            dateFormat: "H:i",
            noCalendar: true,
            locale: "es",
            time_24hr: true,
            enableTime: true
        });
    }
    window.datetimePickerTime = datetimePickerTime;

    $('body').on('change', '.select_company_deal', function(){
        $('.loader-tracking').removeClass('d-none')
        let param = $(this).data('param')
        let object;
        if(param == "company_id"){
            object = {company_id:$(this).val()}
        }else{
            object = {branch_id:$(this).val()}
        }
        $.ajax({
            type:  'GET',
            dataType: 'script',
            url:$(this).data('url'),
            data:object
        })
    })

    $('body').on('click', '.save-prices', function(){
        let id = $(this).data('id');
        let input_price = $("#price-"+id).val();
        let input_price_deliver = $("#price-deliver-"+id).val();
        let url = "/save_prices";
        if(input_price && input_price_deliver){
            $.ajax({
                type: 'put',
                dataType: 'script',
                url: url,
                data:{
                    price: input_price,
                    price_deliver: input_price_deliver,
                    id:id
                }
            })
        }else{
            swal({
                title:'No se puede guardar', 
                text:'Es necesario que ambos precios estén agregados', 
                icon:'warning', 
                dangerMode: true, 
                button:"Aceptar"
            })
        }
    })

    $('body').on('click', '.edit-prices', function(){
        let id = $(this).data('id');
        $('#price-'+id).toggleClass('disabled');
        $('#price-deliver-'+id).toggleClass('disabled');
    })

    $('body').on('click', '#get-result', function(){
        let ids = []
        let elements = $('.prices-deliveries')
        for (let i = 0; i < elements.length; i++) {
            ids.push($(elements[i]).data('id'))
        }
        console.log(ids)
        console.log(ids.length)
        let url = $(this).data('url');
        let company_id = $(this).data('company');
        let id = $(this).data('id');
        let action_name = $(this).data('action');
        $.ajax({
            type: "GET",
            dataType: "script",
            url: url,
            data:{
                ids: ids,
                company_id:company_id,
                id:id,
                action:action_name
            }
        })
    })

    $('body').on('click', "[data-toggle='disabled']", function(){
        $(this).parent().find('input').toggleClass('disabled');
    })
    $('body').on('click', "[data-toggle='modal']", function(){
        let target = $(this).data('target');
        $(target).modal('show');
    })

    $('.js-basic-single').select2();

    $('body').on('keyup', '.select-range', function(event) {
        event.preventDefault();
        let input = $(this)
        if (event.which == 13) {
            $('.flatpickr-calendar').removeClass('open');
            sendRange(input)
        }
    })

    $('body').on('click', '.search', function() {
        let input = $(this).parent().find('input');
        sendRange(input)
    })

    function sendRange(input) {
        $.ajax({
            type: 'GET',
            dataType: 'script',
            url: $(input).data('url'),
            data:{
                date_range: $(input).val(),
                company_id: $(input).data('company'),
                branch_id: $(input).data('branch'),
            }
        });
    };

    $('body').on('click', '#only-save', function(){
        let form = $(this).parent().parent()
        let input = document.createElement("INPUT");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", "only_save");
        input.setAttribute("value", "true");
        form.append(input);
        if (form.find("input[name='only_save']").val() == "true"){
            form.trigger('submit')
        }
    });

    $('body').on('click', '.delete-delivery', function(){
        let id_delivery = $(this).data('id');
        swal({
            text:'Estas seguro que vas a eliminar la solicitud #' + id_delivery + ' de este cobro? se desvinculará permanentemente de este cobro.',
            icon: 'warning',
            dangerMode:true,
            buttons:{
                cancel: 'Cancelar',
                confirm: 'Si, eliminar'
            }
        }).then((value)=>{
            if(value){
                deleteDelivery(this, id_delivery)
            }
        })
        
    });

    function deleteDelivery(tr_deliver, id_delivery){
        $.ajax({
            url:'/delivery_null_deal',
            type: 'PUT',
            dataType: 'script',
            data:{
                id:id_delivery
            },
            success: function(){
                swal({title:'Eliminamos correctamente del cobro!', button:'Aceptar'})
                let url = $('#calc-deliveries').attr('href');
                $(tr_deliver).parent().parent().fadeOut('slow').remove()
                $.ajax({
                    url: url,
                    type: 'GET',
                    dataType: 'script'
                })
            }
        })
    }

}