#= require nprogress

NProgress.configure
  showSpinner: false

@flash_notice = (msg) ->
  $('#flash').find('div').removeClass('bg-danger')
  $('#flash').find('div').addClass('bg-success')
  $('#flash').find('div').html(msg)
  $('#flash').show()

@flash_alert = (msg) ->
  $('#flash').find('div').removeClass('bg-success')
  $('#flash').find('div').addClass('bg-danger')
  $('#flash').find('div').html(msg)
  $('#flash').show()

$ ->
  today = new Date()
  tomorrow = new Date(today)
  tomorrow.setDate(today.getDate() + 1)

  if $('.js-combobox').length
    $('.js-combobox').select2
      width: "100%"
      selectOnBlur: true
      dropdownAutoWidth: if self==top then true else false
