$(".js-registrars-typeahead").typeahead
  source: (query, process) ->
    $.get "/admin/registrars/search", {query: query}, (data) ->
      map = {}
      registrars = []

      $.each data, (i, registrar) ->
        map[registrar.id] = registrar
        registrars.push registrar.display

      process registrars
  updater: (item) ->
    $('input[name="domain[registrar_id]"]').val()

$(".js-contacts-typeahead").typeahead
  source: (query, process) ->
    $.get "/admin/contacts/search", {query: query}, (data) ->
      process data

