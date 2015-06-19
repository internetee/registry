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
    return $('form').each(function() {
      return $(this).validate();
    });
  });

}).call(this);
