(function () {
    $.datepicker.setDefaults({
        changeMonth: true,
        changeYear: true,
        duration: 'fast',
        firstDay: 1,
        dateFormat: 'yy-mm-dd',
    });

    var dateFields = $('.datepicker');

    dateFields.datepicker();

    dateFields.each(function () {
        this.autocomplete = 'off';
    });
})();
