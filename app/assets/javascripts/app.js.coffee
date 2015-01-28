ready = ->
  $('.selectize').selectize({
    allowEmptyOption: true
  });

$(document).ready(ready)
$(document).on('page:load', ready)
