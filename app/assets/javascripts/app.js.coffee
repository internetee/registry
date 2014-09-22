ready = ->
  Autocomplete.bindContactSearch()
  Autocomplete.bindRegistrarSearch()

$(document).ready(ready)
$(document).on('page:load', ready)
