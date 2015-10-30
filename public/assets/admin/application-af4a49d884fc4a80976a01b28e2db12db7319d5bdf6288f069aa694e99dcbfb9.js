(function() {
  $(document).on('page:change', function() {
    $('.selectize').selectize({
      allowEmptyOption: true
    });
    $('.js-datepicker').datepicker({
      showAnim: "",
      autoclose: true,
      dateFormat: "dd.mm.yy",
      changeMonth: true,
      changeYear: true
    });
    $('form').each(function() {
      return $(this).validate();
    });
    return $('[data-toggle="popover"]').popover();
  });

}).call(this);
