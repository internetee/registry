(function() {
  var ready;

  ready = function() {
    $('.selectize').selectize({
      allowEmptyOption: true
    });
    return $('form').each(function() {
      return $(this).validate();
    });
  };

  $(document).ready(ready);

  $(document).on('page:load', ready);

}).call(this);
