$ ->
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

  $('[data-legal-document]').each (i, fileInput)->
    minSize = 3 * 1024 # 3kB
    maxSize = 8 * 1024 * 1024; # 8 MB
    $(fileInput).closest('form').submit (e) ->
      if (files = fileInput.files).length
        fileSize = files[0].size
        if fileSize < minSize
          alert 'Document size should be more than 3kB'
          return false
        else if fileSize > maxSize
          alert 'Document size should be less than 8MB'
          return false
