$(window).load ->
  $('.selectize').selectize({
    allowEmptyOption: true
  })
  $('.selectize_create').selectize({
    allowEmptyOption: true, create: true
  })

  $('[data-toggle="popover"]').popover()

  $('[data-toggle="tooltip"]').tooltip()

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

# https://github.com/codemirror/CodeMirror/blob/master/mode/sql/index.html
window.init_sql_editor = (mime, tables) ->
  editor = CodeMirror.fromTextArea $('#report_sql_query').get(0),
    mime: mime
    hint: CodeMirror.hint.sql
    matchBrackets: true
    smartIndent: true
    autofocus: true
    theme: 'base16-light'
    lineNumbers: true
    mode: "text/x-sql"
    tabSize: 4
    height: 'auto'
    extraKeys:
      "Esc": 'autocomplete'
      "Ctrl": 'autocomplete'
      "Ctrl-Space": 'autocomplete'
      "Ctrl-Enter": ->
        $(editor.getInputField()).parents('form').submit()
    hintOptions:
      tables: tables

  editor.setSize('100%', '300')
  editor.focus()
