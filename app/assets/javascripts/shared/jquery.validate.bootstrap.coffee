#= require jquery.validate
#= require jquery.validate.additional-methods

# override jquery validate plugin defaults
$.validator.setDefaults
  highlight: (element) ->
    $(element).closest('.form-group').addClass 'has-error'
    return
  unhighlight: (element) ->
    $(element).closest('.form-group').removeClass 'has-error'
    return
  errorElement: 'span'
  errorClass: 'help-block'
  errorPlacement: (error, element) ->
    if element.parent('.input-group').length
      error.insertAfter element.parent()
    else
      error.insertAfter element
    return

jQuery.validator.addMethod 'lax_email', ((value, element) ->
  @optional(element) or (value.match(new RegExp("@", "g")) || []).length == 1
), 'Please enter a valid email address.'
