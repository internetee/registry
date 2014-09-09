registrarSource = new Bloodhound(
  datumTokenizer: (d) ->
    Bloodhound.tokenizers.whitespace d.display_key

  queryTokenizer: Bloodhound.tokenizers.whitespace
  remote: "/admin/registrars/search?q=%QUERY"
)

registrarSource.initialize()
$(".js-registrars-typeahead").typeahead(
  highlight: true,
  hint: false
,
  displayKey: "display_key"
  source: registrarSource.ttAdapter()
).on('typeahead:selected', (e, obj) ->
  $('input[name="domain[registrar_id]"]').val obj.id
  $('.js-registrar-selected').removeClass('hidden')
  $('.js-registrar-unselected').addClass('hidden')
)
