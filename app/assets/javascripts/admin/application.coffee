$(window).load ->
  $('.selectize').selectize({
    allowEmptyOption: true
  })
  $('.selectize_create').selectize({
    allowEmptyOption: true, create: true
  })

  $('[data-toggle="popover"]').popover()

  # doublescroll
  $('[data-doublescroll]').doubleScroll({
    onlyIfScroll: false,
    scrollCss:
      'overflow-x': 'auto'
      'overflow-y': 'hidden'
    contentCss:
      'overflow-x': 'auto'
      'overflow-y': 'hidden'
    resetOnWindowResize: true
  })

  positionSlider = ->
    for scroll in document.querySelectorAll('[data-doublescroll]')
      wrapper = scroll.previousSibling
      if $(scroll).offset().top < $(window).scrollTop()
        wrapper.style.position = 'fixed'
        wrapper.style.top      = '-5px'
      else
        wrapper.style.position = 'relative'
        wrapper.style.top      = '0'
    return

  positionSlider()
  $(window).scroll(positionSlider).resize positionSlider
  #due .report-table width: auto top scrollbar appears after resize so we do fake resize action
  $(window).resize()
