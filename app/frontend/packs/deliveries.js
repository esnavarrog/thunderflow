$( document ).on('turbolinks:load', common_events)

function captureDeliveriesInfo(integration_order_id) {
  const $orderRow = $(`#order-row-${integration_order_id}`)
  const $orderInfo = $(`#order-info-${integration_order_id}`)
  const name = $orderRow.find('[data-info="name"]').text()
  const date = $orderRow.find('[data-info="date"]').text()
  const description = $orderInfo.find('[data-info="description"]').text()
  const contact_name = $orderInfo.find('[data-info="contact_name"]').text()
  const contact_lastname = $orderInfo.find('[data-info="contact_lastname"]').text()
  const email = $orderInfo.find('[data-info="email"]').text()
  const phone_number = $orderInfo.find('[data-info="phone_number"]').text()
  const address_concat = $orderInfo.find('[data-info="address_concat"]').val()
  const latitude = $orderInfo.find('[data-info="latitude"]').val()
  const longitude = $orderInfo.find('[data-info="longitude"]').val()
  const commune = $orderInfo.find('[data-info="commune"]').val()

  return {
    //name,
    //date,
    description,
    contact_name,
    contact_lastname,
    email,
    phone_number,
    address_concat,
    latitude,
    longitude,
    commune,
    integration_order_id
  }
}

function createDeliveryInputs(deliveryInfo, index) {
  const {
    integration_order_id
  } = deliveryInfo;

  const inputStrings = Object.keys(deliveryInfo).map((key) => `<input type="hidden" name="delivery[${index}][${key}]" value="${deliveryInfo[key]}">`)

  const elementString = `<div id="form-inputs-${integration_order_id}" class="order-form-inputs">
    ${ inputStrings.join('\n')}
  </div>`

  const $element = $.parseHTML(elementString)
  $('#integration-orders-form').append($element)
}

function validateSaveButton() {
  if ($('.order-row:has(.select-order-checkbox:checked)').length) {
    $('#proccess-orders-from').removeAttr('disabled')
  } else {
    $('#proccess-orders-from').attr('disabled', 'disabled')
  }
}

function common_events() {
  $('body').on('change', '.select-order-checkbox', function(e) {
    const isChecked = $(this).is(':checked')
    const integrationId = $(this).data('integration-order-id')
    const $orderRow = $(`#order-row-${integrationId}`)
    const $orderInfo = $(`#order-info-${integrationId}`)
    const $addressConcatElement = $orderInfo.find('[data-info="address_concat"]')
    const $communeElement = $orderInfo.find('[data-info="commune"]')

    if ($addressConcatElement.val() || !isChecked) {
      $addressConcatElement.removeClass('is-invalid')
    }else {
      $addressConcatElement.addClass('is-invalid')
    }

    if ($communeElement.val() || !isChecked) {
      $communeElement.removeClass('is-invalid')
    }else {
      $communeElement.addClass('is-invalid')
    }

    if ($addressConcatElement.hasClass('is-invalid') || $communeElement.hasClass('is-invalid')) {
      $(this).prop('checked', false);
      $orderRow.find('.toggle-order-info').removeClass('collapsed')
      $orderInfo.addClass('show')
      validateSaveButton()
      return
    }

    if (isChecked) {
      $addressConcatElement.prop('disabled', true)
      $communeElement.prop('disabled', true)
    } else {
      $addressConcatElement.removeAttr('disabled')
      $communeElement.removeAttr('disabled')
    }

    validateSaveButton()
  })

  $('body').on('submit', '#load-orders-form', function() {
    $('#integration-orders-loader').addClass('d-flex').removeClass('d-none')
    $('#integration-orders-form-container').html('')
  })

  $('body').on('click', '#proccess-orders-from', function() {
    $('#integration-orders-form').find('.order-form-inputs').remove()
    const $deliveriesRows = $('.order-row:has(.select-order-checkbox:checked)')
    const integrationOrdersIds = []
    $deliveriesRows.each((index, node) => {
      const integrationOrderId = $(node).find('.select-order-checkbox').data('integration-order-id')
      integrationOrdersIds.push(integrationOrderId)
    })

    const deliveriesInfo = integrationOrdersIds.map(id => captureDeliveriesInfo(id))
    deliveriesInfo.forEach(createDeliveryInputs)
    $('#integration-orders-form').find('input:submit').trigger('click')
  })

  $('body').on('focus', '.autoplaces:not(.pac-target-input)', function() {
    const search = new google.maps.places.Autocomplete(this)
    const $input = $(this)
    const targetId = $input.data('target')

    search.addListener('place_changed', function(){
      const place = search.getPlace();
      const $latitudeInput = $(`#latitude_${targetId}`)
      const $longitudeInput = $(`#longitude_${targetId}`)
      const $communeInput = $(`#commune_${targetId}`)

      if (!place?.geometry?.viewport) return;

      const latitude = place.geometry.location.lat()
      const longitude = place.geometry.location.lng()

      $latitudeInput.val(latitude)
      $longitudeInput.val(longitude)

      const communeComponent = place.address_components.find((component) => component.types.includes('administrative_area_level_3'))
      const commune = communeComponent?.long_name
      $communeInput.val(commune)
      $communeInput.removeAttr('disabled')
    })
  })

  $('body').on('click', '.toggle-order-info', function() {
    const $target = $(this).data('bs-target')
    const othersToogles = $('.toggle-order-info').filter((_i, elem) => elem != this)
    const othersCollapse = $('.collapse-order-info').filter((_i, elem) => elem != $target[0])
    othersToogles.addClass('collapsed')
    othersCollapse.removeClass('show')
  })

  $('body').on('change', '#select-all-order-checkbox', function() {
    const isChecked = $(this).is(':checked')
    $('.select-order-checkbox').prop('checked', isChecked).trigger('change')
  })

  $('body').on('change', '.filter-deliveries', function(){
    $(this).closest('form').find('button[type="submit"]').trigger('click');
  })

  $('body').on('click', '.button-filter-mobile', function(){
    $('.container-filters-mobile').animate({
      bottom: '55px',
      opacity: 1
    }, 100).css('z-index', 200)
    $('.js-basic-single').select2({
      dropdownParent: $('.container-filters-mobile')
    });
  })

  $('body').on('click', '.close-mobile, .filter-button-date', function(){
    closeFilter()
  })

  $('body').on('click', '.filter-button-date', function(){
    $('.loader').fadeIn('fast')
  })

  $('body').on('click', '.change-show-delivery', function(){
    let showDeliveries = $(this).data('deliveries');
    $('#show-delivery-how').val(showDeliveries);
    $('.change-show-delivery').removeClass('active');
    $(this).addClass('active');
    $('#search-form_top').find('button[type="submit"]').trigger('click');
  })

  $('body').on('change', '#table-limit', function(){
    let form = $('#search-form_top');
    console.log($(this).val())
    form.find('input[name="limit"]').val($(this).val());
    form.find('button[type="submit"]').trigger('click');
  })

  function closeFilter(){
    $('.container-filters-mobile').animate({
      bottom: '-355px',
      opacity: 0
    }, 100).css('z-index', -50)
  }

  $('body').on('change', '.phone-number-validate', function() {
    const $input = $(this);
    const phoneNumber = $input.val().replace(/\D/g, '');
    const $form = $input.closest('form');

    if (phoneNumber.length !== 9) {
      $input.addClass('is-invalid');
      if (!$input.next('.invalid-feedback').length) {
        $input.after('<div class="invalid-feedback">El número telefónico debe tener 9 dígitos</div>');
      }
      $form.find('button[type="submit"], input[type="submit"]').prop('disabled', true);
    } else {
      $input.removeClass('is-invalid');
      $input.next('.invalid-feedback').remove();
      $form.find('button[type="submit"], input[type="submit"]').prop('disabled', false);
    }
  })

}