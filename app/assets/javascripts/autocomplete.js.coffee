class @Autocomplete
  @bindTypeahead: (obj) ->
    Autocomplete.toggleOkFeedbacksOnLoad(obj)
    # Autocomplete.toggleOkFeedback(obj.hiddenSelector)
    $(obj.selector).typeahead(
      highlight: true,
      hint: false
    ,
      displayKey: "display_key"
      source: Autocomplete.constructSourceAdapter(obj.remote)
    ).on('typeahead:selected', (e, item) ->
      parent = $(e.currentTarget).parents('div.has-feedback')
      jObj = parent.find(obj.hiddenSelector).val item.id
      Autocomplete.toggleOkFeedback(jObj)
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

  @toggleOkFeedback: (jObj) ->
    ok = jObj.parents('div.has-feedback').find('.js-typeahead-ok')
    remove = jObj.parents('div.has-feedback').find('.js-typeahead-remove')

    if jObj.val()
      ok.removeClass('hidden')
      remove.addClass('hidden')
    else
      remove.removeClass('hidden')
      ok.addClass('hidden')

  @toggleOkFeedbacksOnLoad: (obj) ->
    $.each $(obj.hiddenSelector), (k, v) ->
      Autocomplete.toggleOkFeedback($(v))

  @bindContactSearch: ->
    Autocomplete.bindTypeahead
      remote: '/admin/contacts/search'
      selector: '.js-contact-typeahead'
      hiddenSelector: '.js-contact-id'

  @bindRegistrarSearch: ->
    Autocomplete.bindTypeahead
      remote: '/admin/registrars/search'
      selector: '.js-registrar-typeahead'
      hiddenSelector: '.js-registrar-id'
