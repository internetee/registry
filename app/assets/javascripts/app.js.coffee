ready = ->
  Autocomplete.bindTypeahead
    remote: '/admin/registrars/search'
    selector: '.js-registrar-typeahead'
    hiddenSelector: '.js-registrar-id'

  Autocomplete.bindTypeahead
    remote: '/admin/contacts/search'
    selector: '.js-contact-typeahead'
    hiddenSelector: '.js-contact-id'

$(document).ready(ready)
$(document).on('page:load', ready)
