$(document).on 'page:change', ->
  $('.selectize').selectize({
    allowEmptyOption: true
  })

  $('.js-datepicker').datepicker({
    showAnim: "",
    autoclose: true,
    dateFormat: "dd.mm.yy",
    changeMonth: true,
    changeYear: true
  })

  # client side validate all forms
  $('form').each ->
    $(this).validate()
