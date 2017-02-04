$.datepicker.setDefaults({
  changeMonth: true,
  changeYear: true,
  duration: 'fast',
  dateFormat: 'yy-mm-dd',
});

var dateFields = $('.datepicker');

dateFields.datepicker();

dateFields.each(function () {
  this.autocomplete = 'off';
});
