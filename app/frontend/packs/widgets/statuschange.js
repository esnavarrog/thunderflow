$( document ).on('turbolinks:load', common_events)

function common_events(){
    $('body').on('change', '.select-delivery', add_input)

    if($(':checkbox').is(':checked')){
        add_input()
    }

    $('body').on('change', '.select-all-delivery', function(){
        $(':checkbox').not(this).prop('checked', this.checked);
        let deliveries = $('.select-delivery');
        let container = $('#form-add-delivery');
       for(var i = 0; i < deliveries.length; i++){
           let element = deliveries[i];
           if($(element).is(":checked")){
               var input = document.createElement("input");
               input.type = "hidden";
               input.name = "ids[]";
               input.id = "idstatus-"+$(element).data('id');
               input.value = $(element).data('id');
               $(container).prepend(input);
           }else{
               $('#idstatus-'+$(element).data('id')).remove();
           }
       }
       viewButton()

    })

    $('body').on('click', '#button-send-status, #button-asign-massive', clickSubmit)

    function add_input(){
        let id = $(this).data('id');
        let container = $('#form-add-delivery');
        if($(this).is(":checked")){
            var input = document.createElement("input");
            input.type = "hidden";
            input.name = "ids[]";
            input.id = "idstatus-"+id;
            input.value = id;
            $(container).prepend(input);
        }else{
            $('#idstatus-'+id).remove();
        }
        viewButton()
    }

    function viewButton(){
        let checks = $('.select-delivery')
        let counter = 0;
        for(var i = 0; i < checks.length; i++){
            let element = checks[i];
            if($(element).is(":checked")){
                counter += 1;
            }
        }
        if(counter > 0){
            $('#button-send-status, #button-asign-massive, .container-massive-select').fadeIn('slow')
        }else{
            $('#button-send-status, #button-asign-massive, .container-massive-select').fadeOut('slow')
        }
    }

    function clickSubmit(){
        let form = $('#form-add-delivery')
        let url = $(this).data('url')
        // change action
        form.attr('action', url)
        $('#change-submit').trigger("click")
    }
}


