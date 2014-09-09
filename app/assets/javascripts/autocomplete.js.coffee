class @Autocomplete
  @bindTypeahead: (obj) ->
    $(obj.selector).typeahead(
      highlight: true,
      hint: false
    ,
      displayKey: "display_key"
      source: Autocomplete.constructSourceAdapter(obj.remote)
    ).on('typeahead:selected', (e, item) ->
      $(obj.hiddenSelector).val item.id

      ok = $(obj.hiddenSelector).parent('div.has-feedback').find('.js-typeahead-ok')
      remove = $(obj.hiddenSelector).parents('div.has-feedback').find('.js-typeahead-remove')

      ok.removeClass('hidden')
      remove.addClass('hidden')
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
