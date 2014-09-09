class @Autocomplete
  @bindTypeahead: (obj) ->
    Autocomplete.toggleOkFeedback(obj.hiddenSelector)
    $(obj.selector).typeahead(
      highlight: true,
      hint: false
    ,
      displayKey: "display_key"
      source: Autocomplete.constructSourceAdapter(obj.remote)
    ).on('typeahead:selected', (e, item) ->
      $(obj.hiddenSelector).val item.id
      Autocomplete.toggleOkFeedback(obj.hiddenSelector)
    )

  @constructSourceAdapter: (remote) ->
    source = new Bloodhound(
      datumTokenizer: (d) ->
        Bloodhound.tokenizers.whitespace d.display_key

      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote: "#{remote}?q=%QUERY"
    )

    source.initialize()
    source.ttAdapter()

  @toggleOkFeedback: (hiddenSelector) ->
    if $(hiddenSelector).val()
      ok = $(hiddenSelector).parent('div.has-feedback').find('.js-typeahead-ok')
      remove = $(hiddenSelector).parents('div.has-feedback').find('.js-typeahead-remove')

      ok.removeClass('hidden')
      remove.addClass('hidden')
