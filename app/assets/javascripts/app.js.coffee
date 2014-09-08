$(".js-registrars-typeahead").typeahead
  source: (query, process) ->
    $.get "/admin/registrars/search", {query: query}, (data) ->
      process data

$(".js-contacts-typeahead").typeahead
  source: (query, process) ->
    $.get "/admin/contacts/search", {query: query}, (data) ->
      process data

