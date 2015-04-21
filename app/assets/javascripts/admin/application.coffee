ready = ->
  $('.selectize').selectize({
    allowEmptyOption: true
  });

  # client side validate all forms
  $('form').each ->
    $(this).validate()


$(document).ready(ready)
$(document).on('page:load', ready)
