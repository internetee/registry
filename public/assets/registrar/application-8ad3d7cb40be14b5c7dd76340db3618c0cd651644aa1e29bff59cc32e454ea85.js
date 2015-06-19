(function() {
  $(document).on('page:change', function() {
    $('form').each(function() {
      return $(this).validate();
    });
    $('.js-contact-form').on('restoreDefault', function(e) {
      var form;
      form = $(e.target);
      form.find('.js-ident-tip').hide();
      switch ($('.js-ident-country-code option:selected').val()) {
        case 'EE':
          return $('.js-ident-type').find('option[value=birthday]').prop('disabled', true);
        default:
          return $('.js-ident-type').find('option[value=birthday]').prop('disabled', false);
      }
    });
    $('.js-ident-country-code').change(function(e) {
      var form;
      form = $('.js-contact-form');
      return form.trigger('restoreDefault');
    });
    $('.js-ident-type').change(function(e) {
      var form;
      form = $('.js-contact-form');
      form.trigger('restoreDefault');
      switch (e.target.value) {
        case 'birthday':
          return form.find('.js-ident-tip').show();
      }
    });
    $('.js-contact-form').trigger('restoreDefault');
    return console.log('change');
  });

}).call(this);
