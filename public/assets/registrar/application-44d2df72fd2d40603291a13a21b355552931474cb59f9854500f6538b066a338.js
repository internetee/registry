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
    return $('[data-legal-document]').each(function(i, fileInput) {
      var maxSize, minSize;
      minSize = 1 * 1024;
      maxSize = 8 * 1024 * 1024;
      return $(fileInput).closest('form').submit(function(e) {
        var fileSize, files;
        if ((files = fileInput.files).length) {
          fileSize = files[0].size;
          if (fileSize < minSize) {
            alert('Document size is less then 100kB bytes');
            return false;
          } else if (fileSize > maxSize) {
            alert('Document size is more then 8MB bytes');
            return false;
          }
        }
      });
    });
  });

}).call(this);
