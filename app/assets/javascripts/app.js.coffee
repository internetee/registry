@flash_notice = (msg) ->
  $('#flash').find('div').removeClass('bg-danger')
  $('#flash').find('div').addClass('bg-success')
  $('#flash').find('div').html(msg)
  $('#flash').show()

@flash_alert = (msg) ->
  $('#flash').find('div').removeClass('bg-success')
  $('#flash').find('div').addClass('bg-danger')
  $('#flash').find('div').html(msg)
  $('#flash').show()

ready = ->
  $('.selectize').selectize({
    allowEmptyOption: true
  });

$(document).ready(ready)
$(document).on('page:load', ready)
