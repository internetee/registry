(function() {
    $.datepicker.setDefaults({
        changeMonth: true,
        changeYear: true,
        duration: 'fast',
        firstDay: 1, // Monday
        dateFormat: 'yy-mm-dd',
    });

    function attachDatePicker() {
        let dateFields = $('.js-datepicker');
        dateFields.datepicker();
    }

    attachDatePicker();
})();
