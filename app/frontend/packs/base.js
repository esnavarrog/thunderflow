import ClipboardJS from 'clipboard';
import { breakpointUp, breakpointDown } from './widgets/breakpoints';

$( document ).on('turbolinks:load', common_events)

function common_events(){

    if (breakpointUp('sm')){
        $('#sidebar').removeClass('active').addClass('d-block').addClass('actives')
    }

    $('body').on('keyup', '.rut-input', function (){
        
        let rut = $(this).val();
        const newRut = rut.replace(/\./g,'').replace(/\-/g, '').trim().toLowerCase();
        const lastDigit = newRut.slice(-1);
        let rutDigits = newRut.slice(0, newRut.length-1)
        let format = '';

        let last3digits= rutDigits.slice(-3)
        while (last3digits.length === 3){
            format = "." + last3digits + format;
            rutDigits = rutDigits.slice(0,-3);
            last3digits= rutDigits.slice(-3)
        }
        format = rutDigits + format;

        $(this).val( format + '-' + lastDigit);

    });

    $('body').on('change', '.region-input', function () {
        $.ajax({
            url: $(this).data("url"),
            dataType: 'script',
            method: "GET",
            data: {region_name: $(this).val()}
        })
    });

    $('body').on('click', '.close-alert', function(){
        $(this).parent().parent().fadeOut('slow');
    })

    $('body').on('change', '#branches', function(){
        let branch_id = $(this).val()
        let url = $(this).data('url')
        if(branch_id == '' || branch_id == undefined){
            $('#data-branch').html('')
        }else{
            $.ajax({
                url:url,
                dataType: 'script',
                method: 'GET',
                data:{
                    branch_id: branch_id
                }
            })
        }
    })

    $(".datetimepicker").flatpickr({
        dateFormat: "d-m-Y",
        locale: "es"
    });

    

    // $('body').on('click', ".filter-button-date", function(e){
    //     let date_start = $("#search-form").find("#date_start").val();
    //     let date_end = $("#search-form").find("#date_end").val();
    //     let button = $('#export-select')
    //     let url = "/request_xlsx.xlsx"
    //     let resultUrl = url + "?" + 'date_start=' + date_start + '&' + 'date_end=' + date_end;
    //     $(button).attr('href', resultUrl);
    // })

    $('body').on('change', '#local', function () {
        $('.time-local').toggleClass('d-none')
    })

    $('#toggle-menu, #toggle-sidebar, .toggle-sidebar').on('click', function () {
        $('#sidebar').toggleClass('active');
    });

    $('#toggle-sidebar, .toggle-sidebar').on('click', function() {
        $('#toggle-sidebar').toggleClass('active');
        $('.toggle-sidebar').toggleClass('active');
        $('#sidebar').toggleClass('d-block');
        $('#sidebar').toggleClass('actives');
    })

    $('body').on('click', '.form-check-input', function() {
        let params = ['delivered', 'retired', 'returned', 'rejected'];
        if(params.includes($(this).val())){
            $('.receive-form').addClass('d-none')
            $('#status_image').attr('required', true)
            if ($(this).val() != 'retired') {
                $('.receive-form').removeClass('d-none')
            } else {
                $('#status_image').attr('required', false)
                $('.receive-form').each(function() {
                    if (!$(this).hasClass('deliver')) {
                        $(this).removeClass('d-none');
                    }
                });
            }
            $('.receive-form').find('input').val('')
        }else{
            $('.receive-form').addClass('d-none')
            $('.receive-form').find('input').val('')
        }
    })

    $('body').on('click', '[data-toggle="tab"]', function (e) {
        const targetId = $(this).data('target')
        const $target = $(targetId)
        $(".btn-form").removeClass('active')
        $('.tab-panel-form').removeClass('show')
        $(this).addClass('active')
        $target.addClass('show')
    })

    $('body').on('click', '#press-submit', function(){
        $('.loading').removeClass('d-none')
        let submit = $(this).data('submit')
        $(submit).click()
    })

    $('.miles').mask("000.000.000.000", {reverse: true});

    // $('body').on('click', '.copy', function () {
    //     let element = $(this);
    //     let text = $(this).data('clipboard-text');
    //     setClipboard(text, element)
    // })

    function setClipboard(text, element) {
        // console.log(text)
        let message = $(element).parent().find('.copy-content')
        navigator.clipboard.write(text).then(
            () => {
                $(message).fadeIn('slow')
                setTimeout(() => {
                    $(message).fadeOut('slow')
                }, 2000)
            },
            () => {
                /* failure */
            }
        );
    }

    $(document).on('click', '.copy', function(){
        let message = $(this).find('.copy-content');
        $(message).fadeIn('slow')
        setTimeout(() => {
            $(message).fadeOut('slow')
        }, 2000)
    })

    function loader() {
        $(".loader").fadeOut(100);
        $("body").removeClass("hidden-loader");
    }

    $('body').on('click', '.loader-click', () => {
        $('.loader').fadeIn()
    })

    $("window").on("load", loader());

    new ClipboardJS('.copy');

    $('.selected-company').on('change', function () {
        let url = $(this).data('url');
        $.ajax({
            url: url,
            dataType: 'script',
            method: 'GET',
            data:{company_id: $(this).val()}
        })
    })

    if ($('#charts-welcome').length == 1){
        $.ajax({
            url: '/charts_welcome',
            dataType: 'script',
            method: 'get'
        })
    }

    if ($('#charts-company').length == 1){
        let companyId = $('#charts-company').data('company');
        $.ajax({
            url: '/charts_company',
            dataType: 'script',
            method: 'get',
            data:{id:companyId}
        })
    }

    $('body').on('change', '#change-chart-deliveries, .change-chart-deliveries', function(){
        let companyId = $('#charts-company').data('company');
        let url = $(this).data('url');
        $.ajax({
            url:url,
            method: 'get',
            dataType: 'script',
            data: {
                chart_date: $(this).val(),
                id:companyId
            }
        })
    })

    $('body').on('change', '.submit-on-change', function() {
        $(this).find(':submit').trigger('click')
    })

    if($('#metrics').length > 0){
        $.ajax({
            url: '/metrics',
            dataType: 'script',
            method: 'get'
        })
    }

    if ($('#modal-message').length > 0){
        swal({
            title:'¡Aviso importante!', 
            text:$('#modal-message').data('message'),
            icon:'warning', 
            dangerMode: true, 
            button:"Aceptar"
        })
    }
    
    launchmap(null, null, 'company_')

    $('body').on('change', '#integration_app_type', function(){
        let typeIntegration = $(this).val();
        console.log(typeIntegration)
        if (typeIntegration == 'shopify'){
            $('.token-view').fadeIn('fast')
            $('.woocommerce').fadeOut('fast')
        }else if(typeIntegration == 'woocommerce'){
            $('.token-view').fadeOut('fast')
            $('.woocommerce').fadeIn('fast')
        }
    })

    $(document).on('click', '.remove-file', function() {
        let item = $(this).parent().parent();
        item.fadeOut(function() {
            $(this).remove();
        });
    });

    $('body').on("click", ".show-invoice-operation", function(){
        let title = $(this).data('title');
        let url = $(this).data('url');
        let $modal = $('#show-archive-modal')
        let url_archive = $(this).data('archive-url')
        $modal.find('.modal-body').html($('<embed></embed>', {
            width: "100%", height: "100vh",
            src : url,
            id: "document-opener"
        }))
        $modal.modal('toggle');
        $modal.find('.modal-dialog').addClass('modal-xl');
        $modal.find('.modal-title').html(title);
        $modal.find('.link-download-archives').attr('data-url', url);
        if (url_archive){
            $modal.find('a[data-method="delete"]').removeClass('d-none').attr('href', url_archive)
        }
    });

    $('body').on('click', '.link-download-archives', function (e) {
        e.preventDefault();
        let url = $(this).data('url')
        window.open(url)
        // location.href = url, '_blank';
    })


    $(document).on('cocoon:after-insert', function(e, insertedItem) {
        var fileInput = insertedItem.find('input[type="file"]');
        fileInput.on('change', function() {
            var fileName = $(this).val().split('\\').pop();
            insertedItem.find('.file-name').text(fileName);
            insertedItem.find('.file-input').hide();
        });
    });

    $('body').on('shown.bs.modal', '#modal', function () {
        $('.js-basic-single-modal').select2({
            dropdownParent: $(this)
        });
    });

    $('body').on('click', '.paginates a', function () {
        $('.loader').fadeIn('fast')
    })

    $('body').on('click', '.sort-table', function() {
        let newDirection;
        const $target = $($(this).data('target'))
        const currentOrder = $target.val()
        const newOrder = $(this).data('order')
        const currentDirection = $(this).data('direction') || $('#direction').val()
        $(this).parents('.table-responsive').scrollTop(0)
    
        if (newOrder !== currentOrder) {
          newDirection = 'asc'
        } else {
          newDirection = currentDirection == 'asc' ? 'desc' : 'asc'
        }
    
        $(this).data('order', newOrder)
        $(this).data('direction', newDirection)
        $target.siblings('input#page').val('1')
        $target.siblings('input#direction').val(newDirection)
        $target.val(newOrder).trigger('change')
    })

    $('body').on('change', '.form-submit-on-change', function() {
        // if datepicker range calendar ready we just rigger the form (db: deals_backoffice)
        if ($(this).attr("data-calendar-datetimepicker-r") == "yes" || $(this).attr("last-input-change-id") != "created_at") {
            $(this).find(':submit').removeAttr('disabled').trigger('click')
        }
    })

    const alerts = document.querySelectorAll('.alert-floating');
    alerts.forEach(alert => {
        setTimeout(() => {
            $(alert).fadeOut('slow', function() {
                $(this).remove();
            });
        }, 5000);
    });

    if($('#show-modal').length){
        console.log('show-modal')
        $.ajax({
            url: '/get_pending_deliveries',
            dataType: 'script',
            method: 'get'
        })
    }
}