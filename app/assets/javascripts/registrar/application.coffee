$(document).on 'page:change', ->
  # client side validate all forms
  $('form').each ->
    $(this).validate()

  $('.js-contact-form').on 'restoreDefault', (e) ->
    form = $(e.target)
    form.find('.js-ident-tip').hide()
    switch $('.js-ident-country-code option:selected').val()
      when 'EE'
        $('.js-ident-type').find('option[value=birthday]').prop('disabled', true)
      else
        $('.js-ident-type').find('option[value=birthday]').prop('disabled', false)

  $('.js-ident-country-code').change (e) ->
    form = $('.js-contact-form')
    form.trigger 'restoreDefault'

  $('.js-ident-type').change (e) ->
    form = $('.js-contact-form')
    form.trigger 'restoreDefault'

    switch e.target.value
      # when 'bic'
      # when 'priv'
      when 'birthday'
        form.find('.js-ident-tip').show()

  $('.js-contact-form').trigger('restoreDefault')

  $('[data-legal_document]').each (e)->
    fileInput = $(e.target)
    minSize = 1 * 1024 # 100kB
    maxSize = 8 * 1024 * 1024; # 8 MB
    fileInput.parent('form').submit (e) ->
      if (files = fileInput.get(0).files).length
        fileSize = files[0].size
        if fileSize < minSize
          alert 'Document size is less then 100kB bytes'
          return false
        else if fileSize < maxSize
          alert 'Document size is more then 8MB bytes'
          return false
