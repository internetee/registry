class @Autocomplete
  constructor: ->
    @buildAutocomplete(el) for el in document.querySelectorAll('[data-autocomplete]')

  buildAutocomplete: (el)->
    name = el.dataset.autocomplete[1..-1].replace(/\//g, "_") # cahcing

    $(el).typeahead 'destroy'
    $(el).typeahead(
      name: name,
      highlight: true,
      hint: false
    ,
      displayKey: "display_key"
      source: (query, syncResults)->
        $.getJSON "#{el.dataset.autocomplete}?query=#{query}", (data)->
          syncResults(data)


    ).on('typeahead:selected', (e, item) ->
      console.log e.currentTarget.id
      orig = document.querySelector('#' + e.currentTarget.id.replace(/_helper$/, ''))
      orig.value = item.value
    )

$(document).on "ready page:load", ->
  new Autocomplete