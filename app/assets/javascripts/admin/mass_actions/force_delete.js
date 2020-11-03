$('input:file').on("change", function() {
    $('input:submit').prop('disabled', !$(this).val());
});
